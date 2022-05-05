// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;
interface WERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface payment {
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}
import './swapInterface.sol';
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a+b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, 'sub');
        return a-b;
    }   
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {        
        return a*b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, 'div');
        return (a - (a % b)) / b;
    }    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, 'mod');
        return a % b;
    }
}
contract box{  
    using SafeMath for uint256;    
    address owner;
    struct Product {
        uint256 id;
        uint256 price;
    }
    struct Order {
        uint256 productId ;
        uint256 timestamp;
        uint256 price;
    }
    uint256 public destroy = 500;
    address public destroyAddress = address(0x0) ;
    uint256 private lock = 0; 
    Product[] public products;  
    address sendAddress;
    mapping(address=>Order[]) public  OrderList;
    mapping (address => uint256) public ToReceive;  //待领取
    WERC20 payAddress; //付款代币
    WERC20 hostAddress; //主币
    IPancakeRouter02 swapToken; //swap兑换代币

    address[] public path;

    event ProductLog(uint256 indexed id,uint256 indexed price);

    event BuyProduct(address indexed sender, uint256 productId, uint256 price, uint256 bfsPrice , uint256 timestamp); 

    event WithdrawLog(address indexed sender, uint256 num); 

    
    constructor(WERC20 _payAddress, WERC20 _hostAddress, IPancakeRouter02 _swapToken) {
        owner = msg.sender; //发币者
        payAddress = _payAddress;
        hostAddress = _hostAddress;
        swapToken = _swapToken;
        changePayContractApprove(10**28);
    }  
    modifier checkOwner() {
        require(msg.sender == owner);
        _;
    }
    modifier checkSend() {
        require(msg.sender == sendAddress);
        _;
    }
    modifier checkLock() {
        require(lock == 0);
        lock = 1;
        _;
        lock = 0;
    }
    //商品修改
    function updateProduct(uint id,uint _p) checkOwner public returns(bool){
        if(id == 0) {
            id = products.length + 1;
            products.push(Product(id,_p));
        } else {
            products[id.sub(1)] = Product(id,_p);
        }                
        emit ProductLog( id, _p);
        return true; 
    }
    //购买
    function buyProduct(uint256 id) checkLock public payable{
        require(id > 0);
        uint256 _index = id.sub(1);   
        uint256 price = products[_index].price;
        require(price > 0);
        uint256 oldbfs = hostAddress.balanceOf(address(this));
        (bool success, bytes memory returndata) = address(payAddress).call{ value: 0 }(abi.encodeWithSelector(payAddress.transferFrom.selector, msg.sender,address(this), price));  
        if (!success) {
            if (returndata.length > 0) {               
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert('no error0');
            }
        } 
      
        (bool success1, bytes memory returndata1) = address(swapToken).call{ value: 0 }(abi.encodeWithSelector(swapToken.swapExactTokensForTokens.selector, price, 0, path,address(this),block.timestamp.add(5))); 
        if (!success1) {
            if (returndata1.length > 0) {               
                assembly {
                    let returndata_size := mload(returndata1)
                    revert(add(32, returndata1), returndata_size)
                }
            } else {
                revert('no error1');
            }
        } 
        OrderList[msg.sender].push(Order(id,block.timestamp,price));

        uint256 newbfs = hostAddress.balanceOf(address(this)) - oldbfs;

        uint256 destroyNum = newbfs.mul(destroy).div(1000);
        if(destroyNum > 0){
            (bool success2, bytes memory returndata2) = address(hostAddress).call{ value: 0 }(abi.encodeWithSelector(hostAddress.transfer.selector,address(destroyAddress),destroyNum)); 
            if (!success2) {
                if (returndata1.length > 0) {               
                    assembly {
                        let returndata_size := mload(returndata2)
                        revert(add(32, returndata2), returndata_size)
                    }
                } else {
                    revert('no error2');
                }
            } 
        }
        
        emit BuyProduct(msg.sender,id,price, newbfs, block.timestamp);
    }


    //通知佣金
    function updateWaitReceive(address _u,uint _a, uint256 _t) checkSend public {
        if(_t == 1){
            ToReceive[_u] = ToReceive[_u].add(_a);
        }else if(_t == 2){
            ToReceive[_u] = ToReceive[_u].sub(_a);
        }
        
    }
    //用户领取
    function receiveReward() public {
        uint256 num = ToReceive[msg.sender];
        require(num > 0 ,'no bfs'); 
        (bool success, bytes memory returndata) = address(hostAddress).call{ value: 0 }(abi.encodeWithSelector(hostAddress.transfer.selector, msg.sender, num));  
        if (!success) {
            if (returndata.length > 0) {               
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert('no error');
            }
        } 
        ToReceive[msg.sender] = 0;
        emit WithdrawLog(msg.sender,num);
    }


    function withdraw(WERC20 erc20address, uint256 num, address _to) checkOwner public {
        (bool success, bytes memory returndata) = address(erc20address).call{ value: 0 }(abi.encodeWithSelector(erc20address.transfer.selector, _to, num));  
        if (!success) {
            if (returndata.length > 0) {               
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert('no error');
            }
        } 
    }
    function changePayContractApprove(uint _n) internal  {
        (bool success, bytes memory returndata) = address(payAddress).call{ value: 0 }(abi.encodeWithSelector(payAddress.approve.selector, swapToken, _n));  
        if (!success) {
            if (returndata.length > 0) {               
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert('no error');
            }
        }   
    }
    function setOwner(address _a) checkOwner public {
        owner = _a;
    }
    function setSendAddress(address _a) checkOwner public {
        sendAddress = _a;
    }
    function setSwapPhat(address[] memory p) checkOwner public{
        path = p;
    }
    function setDestroy(uint256 p) checkOwner public{
        destroy = p;
    }
    function setDestroyAddress(address _a) checkOwner public{
        destroyAddress = _a;
    }
}