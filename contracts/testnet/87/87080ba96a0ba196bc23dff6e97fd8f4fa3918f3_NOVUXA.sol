// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;



import "./pyo.sol";
import "./dvending.sol";


contract NOVUXA {

   
    mapping(address => uint) public balances;
    address public owner;
    
    
    PYO public token;
    Deelian public token_;

     address private TokenA = 0xb5450ffaf67E289A185C20F643Cd69507617196e; //pyo4/usdt
     address private TokenB = 0x67B9e2984f89f05Ec38c5f83F16D74BcCCb26d4E; //deelian
    // address private Token_ = 0xbc21CCa195c2b9C4E68f84FD951F95040aFD7A6e; //dxly
    uint amountA;
    uint amountB;
    uint novuxa_price;

 

     event Transfer(address indexed from, address indexed to, uint value);
     event Approval(address indexed owner, address indexed spender, uint value);

     constructor() public  {
      owner = msg.sender;
      token = PYO(TokenA);
      token_ = Deelian(TokenB);
      
       amountB =  amountA * (10**(5-4));

   
     }

      
    modifier checkAllowance(uint amountA) {
        require(token.allowance(msg.sender, address(this)) >= amountA, "Error");
        _;
    }


    modifier swap_checkA(uint amountA) {
        require(token.balanceOf(msg.sender) >= amountA, "Your Token Balance is too low to perform the SWAP");
        _;
    }

       modifier swap_checkB(uint amountB) {
        require(token_.balanceOf(msg.sender) >= amountB, "Your Token Balance is too low to perform the SWAP");
        _;
    }

           modifier LPswapA_check(uint amountA) {
        require(token.balanceOf(address(this)) >= amountA, "Not Enough Liquidity For this SWAP");
        _;
    }

           modifier LPswapB_check(uint amountB) {
        require(token_.balanceOf(address(this)) >= amountB, "Not Enough Liquidity For this SWAP");
        _;
    }



    modifier only_novuxa {
         require(msg.sender == owner, "Only Novuxa Contract can perform this action");
                _;
    }



     
    modifier checkAllowance_(uint amountB) {
        require(token_.allowance(msg.sender, address(this)) >= amountB, "Error");
        _;
    }


   function  novuxa_Balance_Token1() external view returns(uint) {
      return token.balanceOf(msg.sender);
      
          }



      function  novuxa_Balance_Token2() external view returns(uint) {
      return token_.balanceOf(msg.sender);
      
    }


      function  LP_Balance_Token1() external view returns(uint) {
      return token.balanceOf(address(this))/10000; // no of decimal
      
    }

      function  LP_Balance_Token2() external view returns(uint) {
      return token_.balanceOf(address(this))/100000; // no of decimal
     
      
    }


    function  nouvaxa_price() external view returns(uint) {


      return token.balanceOf(address(this))/token_.balanceOf(address(this));
      
    }



     
    function SwapAB(uint amountA) public swap_checkA(amountA) {
        token.transferFrom(msg.sender, address(this), amountA);
        uint256 fee = amountA / 1000; // 0.1% swap fee
        uint256 amountq = amountA - fee;
        require(token_.balanceOf(address(this)) >= amountq, "Not Enough Liquidity For this SWAP");
        token_.transferFrom(address(this), msg.sender, amountq*10);
        token.approve(TokenA, amountA);
           
    }


      function SwapBA(uint amountB) public swap_checkB(amountB) {
           token_.transferFrom(msg.sender, address(this), amountB);
           uint256 fee = amountB / 1000; // 0.1% swap fee
           uint256 amountq = amountB - fee;
           require(token.balanceOf(address(this)) >= amountq, "Not Enough Liquidity For this SWAP");
           token.transferFrom(address(this), msg.sender, amountq/10);
           token_.approve(TokenB, amountB);
     
    }



     function approve(address spender, uint256 value) external returns (bool) {
        token.approve(spender, value );
        token_.approve(spender, value );
         return true;
   

}




 function AProvide_Liquidity_Novuxa(uint256 value) external  {
            uint256 fee = value / 1000; // 0.1% swap fee
            uint256 valueq = value + fee;
        token.transferFrom(msg.sender, address(this), valueq);
  
    }




    function BProvide_Liquidity_Novuxa(uint256 value) external  {
            uint256 fee = value / 1000; // 0.1% swap fee
            uint256 valueq = value + fee;
            token_.transferFrom(msg.sender, address(this), valueq);
      //  token.transferFrom(from, to, value);
        //    uint256 fee = value / 100;
        //    uint256 value2 = value - fee;
      //  token_.transfer(msg.sender, value2);
    }

    function Remove_A_Liquidity_Novuxa(uint256 value) external only_novuxa {
            uint256 fee = value / 100; // 1% Liquidity removal fee
            uint256 valueq = value - fee;
            require(block.timestamp >= now + 180 days);
            token.transferFrom(address(this), msg.sender, valueq);
      
    }


       function Remove_B_Liquidity_Novuxa(uint256 value) external only_novuxa {
            uint256 fee = value / 100; // 1% Liquidity removal fee
            uint256 valueq = value - fee;
            require(block.timestamp >= now + 180 days);
            token_.transferFrom(address(this), msg.sender, valueq);
      
    }



}