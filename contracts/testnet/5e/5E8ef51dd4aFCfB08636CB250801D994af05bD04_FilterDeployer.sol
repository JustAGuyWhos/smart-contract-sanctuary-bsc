/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8;

interface IFilterManager {
    function feeToAddress() external view returns (address);
    function factoryAddress() external view returns (address);
    function routerAddress() external view returns (address);
    function wethAddress() external view returns (address);
    function tokenMintFee() external view returns (uint);
    function maxOwnerShare() external view returns (uint);
    function tokenTemplateAddress(uint) external view returns (address);
    function isTokenVerified(address) external view returns (bool);
    function setTokenVerified(address) external;
}

interface IERC20 {
    function balanceOf(address) external view returns (uint);
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
    function approve(address, uint) external;
}

interface IFilterRouter {
    function addLiquidity(address, address, uint, uint, uint, uint, address, uint, uint) external returns (uint, uint, uint);
    function addLiquidityETH(address, uint, uint, uint, address, uint, uint) external payable returns (uint, uint, uint);
}

interface IFilterFactory {
    function getPair(address, address) external view returns (address);
}

interface IDeployedToken {
    function initializeToken(string memory, string memory, address, address, uint[] memory) external;
    function initializePair(address) external;
}

contract FilterDeployer {
    IFilterManager filterManager;

    constructor(address _managerAddress) {
        filterManager = IFilterManager(_managerAddress);
    }

    function cloneContract(address _addressToClone) private returns (address) {
        address deployedAddress;
        assembly {
            mstore(0x0, or (0x5880730000000000000000000000000000000000000000803b80938091923cF3, mul(_addressToClone, 0x1000000000000000000)))
            deployedAddress := create(0, 0, 32)
        }
        return deployedAddress;
    }

    function createTokenWithETH(uint _tokenType, string memory _tokenName, string memory _tokenSymbol, uint[] memory _tokenArgs, uint _ownerShare, uint _deadline, uint _liquidityLockTime) public payable {
        require(_ownerShare <= filterManager.maxOwnerShare(), "FilterDeployer: DEV_SHARE_TOO_HIGH");
        require(filterManager.tokenTemplateAddress(_tokenType) != address(0), "FilterDeployer: INVALID_TOKEN_TYPE");
        require(msg.value > 0, "FilterDeployer: NO_ETH_SUPPLIED");

        payable(filterManager.feeToAddress()).transfer((filterManager.tokenMintFee() * address(this).balance) / 1000);

        address deployedTokenAddress = cloneContract(filterManager.tokenTemplateAddress(_tokenType));

        IDeployedToken(deployedTokenAddress).initializeToken(_tokenName, _tokenSymbol, msg.sender, address(this), _tokenArgs);

        IERC20 deployedToken = IERC20(deployedTokenAddress);
        deployedToken.transfer(msg.sender, ((deployedToken.balanceOf(address(this)) * _ownerShare) / 100));

        filterManager.setTokenVerified(deployedTokenAddress);

        IFilterRouter(filterManager.routerAddress()).addLiquidityETH{value: address(this).balance}(
            deployedTokenAddress,
            IERC20(deployedTokenAddress).balanceOf(address(this)),
            0,
            0,
            msg.sender,
            _deadline,
            _liquidityLockTime
        );

        address pairAddress = IFilterFactory(filterManager.factoryAddress()).getPair(filterManager.wethAddress(), deployedTokenAddress);
        IDeployedToken(deployedTokenAddress).initializePair(pairAddress);             
    }

    function createTokenWithAltPair(uint _tokenType, string memory _tokenName, string memory _tokenSymbol, uint[] memory _tokenArgs, address _baseTokenAddress, uint _baseTokenAmount, uint _ownerShare, uint _deadline, uint _liquidityLockTime) public {
        require(_ownerShare <= filterManager.maxOwnerShare(), "FilterDeployer: DEV_SHARE_TOO_HIGH");
        require(filterManager.tokenTemplateAddress(_tokenType) != address(0), "FilterDeployer: INVALID_TOKEN_TYPE");
        require(IERC20(_baseTokenAddress).balanceOf(msg.sender) >= _baseTokenAmount, "FilterDeployer: INSUFFICIENT_BASE_TOKEN_AMOUNT");
        require(filterManager.isTokenVerified(_baseTokenAddress), "FilterDeployer: BASE_TOKEN_NOT_VERIFIED");

        IERC20(_baseTokenAddress).transferFrom(msg.sender, address(this), _baseTokenAmount);
        IERC20(_baseTokenAddress).transfer(filterManager.feeToAddress(), (filterManager.tokenMintFee() * IERC20(_baseTokenAddress).balanceOf(address(this))) / 1000);

        address deployedTokenAddress = cloneContract(filterManager.tokenTemplateAddress(_tokenType));

        IDeployedToken(deployedTokenAddress).initializeToken(_tokenName, _tokenSymbol, msg.sender, address(this), _tokenArgs);

        IERC20 deployedToken = IERC20(deployedTokenAddress);
        deployedToken.transfer(msg.sender, ((deployedToken.balanceOf(address(this)) * _ownerShare) / 100));

        filterManager.setTokenVerified(deployedTokenAddress);

        IERC20(_baseTokenAddress).approve(filterManager.routerAddress(), type(uint).max);

        IFilterRouter(filterManager.routerAddress()).addLiquidity(
            _baseTokenAddress,
            deployedTokenAddress,
            IERC20(_baseTokenAddress).balanceOf(address(this)),
            deployedToken.balanceOf(address(this)),
            0,
            0,
            msg.sender,
            _deadline,
            _liquidityLockTime
        );

        address pairAddress = IFilterFactory(filterManager.factoryAddress()).getPair(_baseTokenAddress, deployedTokenAddress);
        IDeployedToken(deployedTokenAddress).initializePair(pairAddress);        
    }
}