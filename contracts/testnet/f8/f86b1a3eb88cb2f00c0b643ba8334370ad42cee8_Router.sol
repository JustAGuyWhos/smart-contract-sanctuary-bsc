/**
 *Submitted for verification at BscScan.com on 2022-12-30
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: r2.sol


pragma solidity ^0.8.0;




contract Router{

    address public constant weth = 0x66147CD18A8862922c0Aed88E1f331442f5b1a1C;
    event internalSwap(bool isDone,address receivingAddress,uint256 amountReceived,uint256 currentStep,uint256 totalStep);
    event refund(bool success,bool isToken,address tokenAddress,address receiverAddress,uint256 tokenAmount);

    function swap(bytes[] memory _data)public payable{

        for(uint256 i=0; i<_data.length;i++){

            (address target, bytes memory callData,uint256 tokenValue) = abi.decode(_data[i],(address,bytes,uint256));
            (bool success,) = target.call{value: tokenValue}(callData);
            require(success,"failed");
        }
    }

    function swapCM(bytes[] memory _data)public payable{

        for(uint256 i=0; i<_data.length;i++){

            (address target, bytes memory callData,uint256 tokenValue,address sendToken) = abi.decode(_data[i],(address,bytes,uint256,address));
            (bool success,) = target.call{value: tokenValue}(callData);

            if(success){
                emit internalSwap(true,msg.sender,tokenValue,i,_data.length);
            }

            else if(!success){

                if(sendToken==weth){

                    (bool successA,) = address(msg.sender).call{value:tokenValue}("");
                    if(successA){
                        emit refund(true,false,weth,msg.sender,tokenValue);
                    }
                    else{
                        emit refund(false,false,weth,msg.sender,tokenValue);
                    }
                }
                else{
                    bool isSuccess = IERC20(sendToken).transfer(msg.sender,tokenValue);
                    if(isSuccess){
                        emit refund(true,true,sendToken,msg.sender,tokenValue);
                    }
                    else{
                        emit refund(false,true,sendToken,msg.sender,tokenValue);
                    }
                }
            }
        }
    }
    receive() external payable{}
}