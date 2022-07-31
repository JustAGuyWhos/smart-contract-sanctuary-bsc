/**
 *Submitted for verification at BscScan.com on 2022-07-31
*/

// File: ASSA_lott_new/IERC20.sol



pragma solidity ^0.6.8;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);


    function decimals() external view returns (uint256);


    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}
// File: ASSA_lott_new/Context.sol



pragma solidity 0.6.8;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: ASSA_lott_new/SafeMath.sol



pragma solidity 0.6.8;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: ASSA_lott_new/Assa_Contract.sol




/*
** Create By Assara Team
** https://t.me/ASSARAcommunity
** https://twitter.com/Assarafinance
** https://www.facebook.com/Assarablockchainlottery/
** https://instagram.com/assara_blockchainlottery
** 
** 
** Homepage : https://assara.finance/
** ASSARA Lottery Contract
*/


pragma solidity 0.6.8;





library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }
    
    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}


interface IUniswapV2Pair {
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

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}



contract AssaraLottery is Context, Ownable{
    using SafeMath for uint256;
    using Address for address;

    IUniswapV2Pair public pair;
    IERC20 public token1;
    
    address public token_address ;

    address private _charity_addr = 0x38D2781cB36BFb73a42439Abc9DF914E72b3DA16;
    address public charity_addr = _charity_addr;

    address private _burn_addr = 0x000000000000000000000000000000000000dEaD;
    address public burn_addr = _burn_addr;

    

    event TransferForTicket(address indexed adrx, uint256 amount);
    event BuyTicketandTicketCode(address indexed adrx, uint256 amount, uint64 ticketcodex );
    event WinerAddress(address indexed adrx, uint64 ticketCode, uint256 amount);
    event RemoveFromLockEvent(address indexed adrx, uint256 amount);
    event ChangeCountWinerEvent(uint64 Countx);
    event ChangeCharityAddressEvent(address indexed OldAddress, address indexed NewAddress);
    event ChangeBurnAddresEvent(address indexed OldAddress, address indexed NewAddress);
    event PayLockedTokenandPrizeEvent(address indexed adrx, uint256 LockedToken, uint256 PrizeToken);
    event ChangePriceTicketEvent(uint256 oldPrice, uint256 newPrice, uint256 timeChange);


    uint256 startDate ;

    struct ticketx{
        uint256 id;
        address member_addr;
        bool win;
        uint256 priceticket;
    }
    mapping (uint64 => ticketx) public Tickets;
    mapping (address => uint256) public TokenLockedPerson;

    uint64 public ticketCode = 0;
    uint64 public CountWiner = 3;
    uint64 public CountLott = 0;
    uint64 public CountAward = 0;
    bool private _BuyLocked = false;

    uint256 public lockedToken = 0;
    uint256 private _lockedToken = 0;
    uint256 public lottToken = 0;
    uint256 private _lottToken = 0;
    
    uint256 private _Charity_fee = 0;
    uint256 private _Burn_fee = 0;
    uint256 private _LockedToken_fee = 0;
    uint256 private _Winner_val = 0;
    uint256 private _Each_Winner_val = 0;
    
    uint256 private day = 86400;

    uint256 public PrizeStakePerson = 0;
    uint256 public tokenPersonLocked = 0;

    uint256 public SumTokensPay = 0;
    uint256 public _TotalLockedToken = 0;

    uint256 public PriceofTicket = 10;

    IERC20 public tokenx;

    constructor(address _token_address, address _pairAddress) public{
        startDate = block.timestamp;
        tokenx = IERC20(address(_token_address));
        token_address = _token_address;
        pair = IUniswapV2Pair(_pairAddress);
        token1 = IERC20(pair.token1());
    }


    function BuyTicketNumbers(uint256 numbers, uint256 amount) public returns(uint64){
        uint256 howmuch = HowMuchTokenMustPay();
        uint256 payit = (howmuch * numbers);
        require(amount >= payit , "You do not pay Enough for numbers ticket");
        if (amount >= payit){
            for(uint64 i=0; i < numbers; i++){
                uint256 payx = (amount.mul(10**12).div(numbers).div(10**12));
                TransferToken(payx);
            }
        }
    }


    function TransferToken(uint256 amount) public returns(uint64) {
        uint256 howmuch = HowMuchTokenMustPay();
        require(tokenx.balanceOf(msg.sender) >= amount , "Your balance not Enough");
        uint256 allowance = tokenx.allowance(msg.sender , address(this));
        require(allowance >= howmuch, "Check the token allowance tokenmustpay");
        require(allowance >= amount, "Check the token allowance");
        require(amount  >=  howmuch,"Your Token not Enough");
       return _TransferToken(msg.sender ,amount);
    }


    function _TransferToken(address _adrt, uint256 _amount) private returns (uint64) {
        require(_amount > 0, "You need to sell at least some tokens");
        require(!_BuyLocked, "Buy is Locked");
        uint256 balancebefore = tokenx.balanceOf(address(this));
        tokenx.transferFrom(_adrt, address(this), _amount);
        uint256 balanceafter = tokenx.balanceOf(address(this));

        _amount = balanceafter - balancebefore ; 
        _lockedToken = _amount.mul(500).div(1000);
        TokenLockedPerson[_adrt] = TokenLockedPerson[_adrt].add(_lockedToken);
        lockedToken = lockedToken.add(_lockedToken);
        _lottToken = _amount.sub(_lockedToken);
        lottToken = lottToken.add(_lottToken);
        emit TransferForTicket(_adrt, _amount);
        return _BuyTicket(_adrt,_lottToken);
        
    }

    function _BuyTicket(address _adrt, uint256 _amount) private returns (uint64) {
        Tickets[ticketCode] = ticketx(ticketCode, _adrt , false, _amount);
        emit BuyTicketandTicketCode(_adrt , _amount, ticketCode);
        ticketCode++;
        return (ticketCode);
    }


    function StartLottery(uint64 ig) public{
             require(block.timestamp > startDate + ( day * 7) , "Times is not end");
             require(ticketCode >0 ,"We Need Ticket");
             require(ticketCode >= CountWiner, "Not Enough People");
            _StartLottery(ig);
    }

    function _StartLottery(uint64 _ig) private {
                CountLott++;
                _Charity_fee = lottToken.mul(600).div(10000);
                _LockedToken_fee = lottToken.mul(900).div(10000);
                _Burn_fee = lottToken.mul(100).div(10000);
                tokenx.transfer(_charity_addr, _Charity_fee);

                _Winner_val = lottToken.sub(_Charity_fee).sub(_LockedToken_fee).sub(_Burn_fee);
               lottToken = lottToken.sub(_Winner_val).sub(_Charity_fee).sub(_Burn_fee);

                _Each_Winner_val = _Winner_val.div(CountWiner);
                for(uint64 i=0 ; i < CountWiner ; i++){
                uint64 winnerIndex = random(ticketCode , (i * 7) , _ig);
                if(!Tickets[ticketCode].win){
                    CountAward++;
                    (Tickets[winnerIndex].win)=true;
                    tokenx.transfer((Tickets[winnerIndex].member_addr), _Each_Winner_val);
                    emit WinerAddress((Tickets[winnerIndex].member_addr), winnerIndex, _Each_Winner_val);
                    _Winner_val =  _Winner_val.sub(_Each_Winner_val);
                }else{

                } 
            }
             _PayForLockedTokens(_LockedToken_fee);
    }
        
    function _PayForLockedTokens(uint256 _TotalVal) private {
        _TotalLockedToken = lockedToken;
        for(uint64 i = 0; i < ticketCode; i++){
            if(TokenLockedPerson[(Tickets[i].member_addr)] > 0){
            tokenPersonLocked = TokenLockedPerson[(Tickets[i].member_addr)];
            PrizeStakePerson = tokenPersonLocked.mul(10**12).div(_TotalLockedToken).mul(_TotalVal).div(10**12);
            SumTokensPay = tokenPersonLocked.add(PrizeStakePerson);
            tokenx.transfer((Tickets[i].member_addr), SumTokensPay);
            lockedToken = lockedToken.sub(tokenPersonLocked);
            lottToken = lottToken.sub(PrizeStakePerson);
            emit PayLockedTokenandPrizeEvent((Tickets[i].member_addr), tokenPersonLocked, PrizeStakePerson);
            delete (TokenLockedPerson[(Tickets[i].member_addr)]);
            delete Tickets[i];
            }else{
             delete (TokenLockedPerson[(Tickets[i].member_addr)]);
             delete Tickets[i];   
            }
        }
        _PayFinished();
    }

    function _PayFinished() private {
        ticketCode = 0;
        startDate = block.timestamp;

        if(tokenx.balanceOf(address(this)) > 0 ){
            tokenx.transfer(_burn_addr, tokenx.balanceOf(address(this)));
        } 
        lockedToken = 0;
        lottToken = 0;
            
        SumTokensPay = 0;
    }


    function RemovefromLocked(uint256 amount) public {
        require(TokenLockedPerson[_msgSender()] > 0, "You Have not Locked");
        require(TokenLockedPerson[_msgSender()] >= amount, "You Have not Enough Token");
        _RemovefromLocked(amount);
    }
    function _RemovefromLocked(uint256 _amount) private {
        TokenLockedPerson[_msgSender()] = TokenLockedPerson[_msgSender()].sub(_amount);
        lockedToken = lockedToken.sub(_amount);
        tokenx.transfer(_msgSender(), _amount);
        emit RemoveFromLockEvent(_msgSender(), _amount);
    }

    function TokencLockedCheckView(address adr) public view returns(uint256){
        return TokenLockedPerson[adr];
    }

    function ChangeCountWiner(uint64 amount) public onlyOwner returns (bool) {
        return _ChangeCountWiner(amount);
    }
    function _ChangeCountWiner(uint64 _amount) private returns(bool){
        CountWiner = _amount;
        emit ChangeCountWinerEvent(_amount);
        return true;
    }

    function ChangeCharityAddress(address adr) public onlyOwner returns(bool) {
        return _ChangeCharityAddress(adr);
    }
    function _ChangeCharityAddress(address _adr) private returns(bool) {
        emit ChangeCharityAddressEvent(_charity_addr, _adr);
        _charity_addr = _adr;
        charity_addr = _charity_addr;
        return true;
    }

    function ChangeBurnAddress(address adr) public onlyOwner returns(bool) {
        return _ChangeBurnAddress(adr);
    }
    function _ChangeBurnAddress(address _adr) private returns(bool) {
        emit ChangeBurnAddresEvent(_burn_addr, _adr);
        _burn_addr = _adr;
        burn_addr = _burn_addr;
        return true;
    }


    function SetLockedBuy() public onlyOwner returns(bool){
        return _SetLockedBuy();
    }
    function _SetLockedBuy() private returns(bool){
        _BuyLocked = !_BuyLocked;
    }



    // interanl randomize
    function random(uint64 amount, uint64 ix, uint64 ig) private view returns (uint64) {
        uint rand = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty)))  % amount ;
        rand = (((rand + ix) * ig) % amount);
        return uint64(rand) ;
    }


    // In a very emergency situation
    function WithdrawERC20(IERC20 token) public onlyOwner returns(bool){
        require(token.transfer(msg.sender, token.balanceOf(address(this))), "Transfer failed");
        _PayFinished();
        return true;
    }
    


    function GetPriceDollarToToken(uint amount) public view returns(uint){
        if(pair.token0() == token_address){
         return  getTokenPrice0(amount);
        }else{
         return getTokenPrice1(amount);
        }
    }

    function GetPriceTokenToDollar(uint amount) public view returns(uint){
        if(pair.token0() != token_address){
         return  getTokenPrice0(amount);
        }else{
         return getTokenPrice1(amount);
        }
    }

    function HowMuchTokenMustPay() public view returns(uint){
        uint256 howmuchtoken ;
        if(pair.token0() == token_address){
            howmuchtoken = getTokenPrice0(PriceofTicket);
        }else{
            howmuchtoken = getTokenPrice1(PriceofTicket);
        }
        return howmuchtoken;
    }
    
     // calculate price based on pair reserves
   function getTokenPrice0( uint amount) public view returns(uint)
   {
    (uint Res0, uint Res1,) = pair.getReserves();
    uint res0 = Res0 * (10 ** token1.decimals());
    return ((amount * res0) / Res1); // return amount of token0 needed to buy token1
   }
   
   function getTokenPrice1( uint amount) public view returns(uint)
   {
    (uint Res0, uint Res1,) = pair.getReserves();
    uint res1 = Res1 * (10 ** token1.decimals());
    return ((amount * res1) / Res0); // return amount of token1 needed to buy token0
   }

   function EndTimeForStartLottery() public view returns(uint256){
        return  startDate + ( day * 7);
    }

    function SetDayTime(uint256 amount) external onlyOwner returns(bool){
        return _SetDayTime(amount);
    }

    function _SetDayTime(uint256 _amount) private returns(bool){
        day = _amount;
        return true;
    }

    function ChangePriceTicket(uint256 _amount) public onlyOwner returns(bool){
        emit ChangePriceTicketEvent(PriceofTicket, _amount, block.timestamp);
        PriceofTicket = _amount;
        return true;
    }
}