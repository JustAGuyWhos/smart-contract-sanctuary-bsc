pragma solidity =0.7.6;
// Developed by Orcania (https://orcania.io/)

import "OMS.sol";

interface IOCA{
         
    function mint(address user, uint256 amount) external;
  
}

interface ITRAF {

    function balanceOf(address _owner) external view returns (uint256);
    
}

contract OCAmint is OMS {
    IOCA OCA = IOCA(0xa615D774E1E348a3Eb7345fB75781E8BFb2C62D7);
    ITRAF TRAF = ITRAF(0x05dCd27BA7345085237e15719A1B4B1DD312F580);

    uint256 private _price;
    uint256 private _trafPrice;
    uint256 private _wlPrice;

    mapping(address => uint256) private _whiteListed;

    //Read functions=========================================================================================================================
    function price() external view returns (uint256) {return _price;}

    function trafPrice() external view returns (uint256) {return _trafPrice;}

    function wlPrice() external view returns (uint256) {return _wlPrice;}

    function whiteListed(address user) external view returns(bool) {return _whiteListed[user] == 1;}

    //Owner Write Functions========================================================================================================================
    function changeData(uint256 price, uint256 trafPrice, uint256 wlPrice) external Owner {
        _price = price;
        _trafPrice = trafPrice;
        _wlPrice = wlPrice;
    }   

    function addToWhiteList(address[] calldata users) external Owner {
        uint256 length = users.length;

        for(uint256 t; t < length; ++t) {
            _whiteListed[users[t]] = 1;
        }
    }

    function removeFromWhiteList(address[] calldata users) external Owner {
        uint256 length = users.length;

        for(uint256 t; t < length; ++t) {
            _whiteListed[users[t]] = 2;
        }
    }

    //User write functions=========================================================================================================================
    function mint() external payable {
        uint256 price = _price;

        require(msg.value % price == 0);
        uint256 amount = msg.value / price * 1000000000000000000;

        OCA.mint(msg.sender, amount);
    }

    function trafMint() external payable {
        require(TRAF.balanceOf(msg.sender) > 0, "NOT_TRAF_HOLDER");

        uint256 price = _trafPrice;

        require(msg.value % price == 0);
        uint256 amount = msg.value / price * 1000000000000000000;

        OCA.mint(msg.sender, amount);
    }

    function wlMint() external payable {
        require(_whiteListed[msg.sender] == 1, "NOT_WHITE_LISTED");

        uint256 price = _wlPrice;

        require(msg.value % price == 0);
        uint256 amount = msg.value / price * 1000000000000000000;

        OCA.mint(msg.sender, amount);
    }


}