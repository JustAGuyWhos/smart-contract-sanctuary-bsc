// SPDX-License-Identifier: UNLICENSED 
// CCL CONTRACT - The first verification service on Blockchain
// By LOTUS NETWORK

pragma solidity ^0.8.9;

// OpenZeppelin
interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) { return msg.sender; }
    function _msgData() internal view virtual returns (bytes calldata) { return msg.data; }
}

// File: TransferHelper.sol
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }
    
    function safeTransferBaseToken(address token, address payable to, uint value, bool isERC20) internal {
        if (!isERC20) {
            to.transfer(value);
        } else {
            (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
            require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
        }
    }
}

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) { return a + b; }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) { return a - b; }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) { return a * b; }
    function div(uint256 a, uint256 b) internal pure returns (uint256) { return a / b; }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) { return a % b; }

    function sub(
        uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract CCL is Context, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    
   // IERC20 private LTSToken = IERC20(address(0xdBe63523156959AD60b50f63F65D719C367dFcD9)); // LTS CONTRACT
   // IERC20 private WBNBToken = IERC20(address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c)); // WBNB CONTRACT
   IERC20 private LTSToken = IERC20(address(0x2810fCbF6fE41D481f13211f83Ebf6722f64a4ee)); // LTS CONTRACT TEST NET
   IERC20 private WBNBToken = IERC20(address(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd)); // WBNB CONTRACT TEST NET

    uint256 private LTSCost = 1000000 ether; // Fees in LTS 1 Million LTS
    uint256 private BNBCost = 0.5 ether; // Fees in BNB 0.5 BNB
    uint256 private MINIMUMLTS = 250000; // MINIMUM LTS TO ACCSESS EXCLUSIVE FUNCTIONS [250.000 in deployement]

    struct Applications {
        uint256 ID;
        bool isCONTRACT; // User selection. For contracts verifications applicant will have to enter the contract address he which to verify. for wallets verification CCL contract will put a defult value of the wallet that had signed the transaction @note that in contracts verifications requestes, Applicant must sign the transaction from the deployer wallet. (Proof of ownership)
        address requestedADDRESS; // Applicant address
        address contractADDRESS; // For contract verifications 
        string CHAIN;
    }
        // Both fees paid in LTS and BNB will be used in marketing and liquidity refilling to ensure both price stability. 
        // And upwards movement.
        // @note Fees paid in LTS will be 25% less than BNB.
  //  address private constant ltsCCLTransactions = payable (0xBf2fA66baDAd6cEda5f86820c63021809f604811); // Company reserve wallet. Recieve fees paid in LTS
  //  address private constant bnbCCLTransactions = payable (0xeBa3b59Ab378fE8dDe1A2AD449ECa149bc0af54c); // CEO wallet. Recieve fees paid in BNB
    address private constant transactionAddressForTESTNET = payable (0x27873E779cd4c4288F805c90e3FEb77Af94BE2e5); // FOR TEST PURPOSES ONLY 123 ON METAMASK
    uint256 public reqs = 0;  // Total Requestes
    address[] public requestedAddrList;     // Applied addresses array [Public]
    address[] public verifiedWallets;   // Verified wallets array [Wallets verificaton only] [Public]
    address[] public verifiedContracts; // Verified contracts wallet [Contracts and businesses only] [Public]
    address[] public scamAddressContract;
    mapping(address => Applications) private Data;  // UserData Mapping
    mapping (address => bool) private isScam; // Indicates if address was/is involved in a scam or there is an ongoing case
    mapping (address => bool) private isSuspected; // Review of Newly deployed contracts [LTS HOLDER FEATURE]  
    mapping (address => bool) private isVerified; // WE need to check if the public address is verified or not 
    mapping(address => bool) private Requested;     // Indicates if user has an ongoing request
    event NewRequest(address indexed);      // Announce NewRequestes
    event NewWalletVerification(address indexed); // Announce NewVerified Addresses
    event NewContractVerification(address indexed); // Announce NewVerified Contracts
    event LTSFEEUPDATED(uint256 newFee);    // Announce FeeUpdate
    event BNBFEEUPDATED(uint256 newFee);    // Announce FeeUpdate
    event LTSPAYMENT(address indexed sender, address indexed CCLWallet, uint256 fee);
    event BNBPAYMENT(address indexed sender, address indexed BNBWallet, uint256 fee);
    event newSuspection(address indexed suspectedAddress); // Announce suspected addresses in blockchain
    event newScam(address indexed scamAddress); // Announce scam addresses in blockchain

        //  Applicants requests section
    function Request(bool payLTS, bool isContract, address _contract, string memory _Chain) external returns (bool) {
        require(isScam[_contract] = false, "Address belongs to scam addresses");
        require(isVerified[_contract] = false, "Address is already verified");
        require(isSuspected[_contract] = false, "Address is suspected");
        // ALSO MUST PROCESS PAYMENT FIRST TO REVERT AND NOT INSERT DATA TO BLOCKCHAIN IN CASE OF FAILURE
        // MUST CHECK ALLOWANCE FIRST
        /* 
        if(payLTS) {
            checkLTSAllowance(); 
        } else { 
            checkWBNBAllowance();
        } */
        // IF ALLOWANCE > PAYMENT = PROCESS PAYMENT
        // PAYMENT SECTION
        if(payLTS) { 
            payAmountLTS();
        } else { 
            payInWBNB();
        }

        Applications storage applications = Data[_msgSender()];
        applications.ID = reqs;
        applications.requestedADDRESS = _msgSender();
        applications.isCONTRACT = isContract;
        if (isContract) {
            applications.contractADDRESS = _contract;
        } else { 
            applications.contractADDRESS = _msgSender();
        }
        applications.CHAIN = _Chain;

        // Emittion
        reqs += 1;
        Requested[_msgSender()] = true;
        emit NewRequest(_msgSender());
        return true;
    }

    function lastApplications(address _addr) external view returns (address, bool,address, string memory) {
        address requestedRAddress = Data[_addr].requestedADDRESS;
        bool isContract = Data[_addr].isCONTRACT;
        address contractAddress = Data[_addr].contractADDRESS;
        string memory _Chain = Data[_addr].CHAIN;
        return (requestedRAddress, isContract, contractAddress, _Chain);
    }
        // Check for lts Holdings [Modifier]
    modifier LTSHOLDER() {
        require(LTSToken.balanceOf(_msgSender()) >= MINIMUMLTS * (10 ** 18) , "THIS FEATURE REQUIRES LTS BALANCE TO BE UNLOCKED");
        _;
    }

    function checkLTSAllowance() internal view { require(LTSToken.allowance(_msgSender(), address(this)) >= LTSCost);}
    function checkWBNBAllowance() internal view { require(WBNBToken.allowance(_msgSender(), address(this)) >= BNBCost);}
         // Public checkers for users
    function _isSusAddress(address _addr) external view LTSHOLDER() returns (bool) { return isSuspected[_addr]; } // RETURNS SUSPECTED ADDRESSES/NEWLY DEPLOYED CONTRACTS
    function _isRequestedAddress(address _addr) external view returns (bool) { return Requested[_addr]; } // IF THIS ADDRESS HAS AN ONGOING REQUEST 
    function _isVerfiedAddress(address _addr) external view returns (bool) { return isVerified[_addr]; } // IF THIS ADDRESS IS VERIFIED BY THE CCL 

        //  VERIFICATIONS & CCL MODIFIRES
    function verifyByCCL(address _addr, bool sContract) external nonReentrant() onlyOwner() { 
        require(isScam[_addr] = false, "Address belongs to scam addresses");
        require(isVerified[_addr] = false, "Address is already verified");
        isVerified[_addr] = true;
        if (sContract) { 
            verifiedContracts.push(_addr);
            emit NewContractVerification(_addr);
        } else { 
            verifiedWallets.push(_addr);
            emit NewWalletVerification(_addr);
        }
    }

        // There is an impostor between Us, and this address is kinda SUS
    function addSUS(address _addr) external nonReentrant() onlyOwner() {
        require(isSuspected[_addr] = false, "Address is already in suspection list");
        require(isVerified[_addr] = false, "This address has completed the verification process");
        isSuspected[_addr] = true;
        emit newSuspection(_addr);
    }
    function addScam(address _addr) external onlyOwner() nonReentrant() { 
        require(isVerified[_addr] = false, "This address has completed the verification process");
        require(isScam[_addr] = false, 'This address is already on scam list');
        isScam[_addr] = true;
        emit newScam(_addr);
    }

        // FEES MODIFIRES
    function ltsFee(uint newFee) external nonReentrant() onlyOwner() {
        LTSCost = newFee;
        emit LTSFEEUPDATED(newFee);
    }

    function bnbFEE(uint newFee) external nonReentrant() onlyOwner() { 
        BNBCost = newFee;
        emit BNBFEEUPDATED(newFee);
    }

        // READ VALUES FROM CONTRACT 
    function bnbCosts() external view returns (uint256) { return BNBCost; }
    function ltsCosts() external view returns (uint256) { return LTSCost; }
    function minimumLTSToUnlockFeatures() external view returns (uint256) { return MINIMUMLTS; }

    function payAmountLTS() private { TransferHelper.safeTransferFrom(address(LTSToken), _msgSender(), transactionAddressForTESTNET, LTSCost); }
    function payInWBNB() private { TransferHelper.safeTransferFrom(address(WBNBToken), _msgSender(), transactionAddressForTESTNET, BNBCost); } 
    function payInBNB() private { TransferHelper.safeTransfer(address(WBNBToken), transactionAddressForTESTNET, BNBCost);}

    // FALLBACK
    receive() external payable {}

    function contractTotalBalance() external view returns(uint) {return payable(address(this)).balance;}
    function withdrawContractFunds() external onlyOwner() nonReentrant { payable(owner()).transfer(this.contractTotalBalance());}
}