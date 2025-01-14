/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

abstract contract Ownable {
    address private _owner;
    address private _catapultOwner;

    mapping(address => bool) public contractAccess;

    event OwnershipTransferred(address _previousOwner, address _newOwner);
    event CatapultOwnershipTransferred(
        address _previousCatapultOwner,
        address _newCatapultOwner
    );

    constructor() {
        _owner = msg.sender;
        _catapultOwner = _owner;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function catapultOwner() public view returns (address) {
        return _catapultOwner;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner || msg.sender == _catapultOwner);
        _;
    }

    modifier onlyCatapultOwner() {
        require(msg.sender == _catapultOwner);
        _;
    }

    modifier onlyContract() {
        require(contractAccess[msg.sender]);
        _;
    }

    function transferOwnership(address _newOwner) public virtual onlyOwner {
        require(
            _newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        address previousOwner = _owner;
        _owner = _newOwner;

        _afterTransferOwnership(previousOwner, _newOwner);

        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function transferCatapultOwnership(address _newCatapultOwner)
        public
        virtual
        onlyCatapultOwner
    {
        require(
            _newCatapultOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        address previousCatapultOwner = _catapultOwner;
        _catapultOwner = _newCatapultOwner;

        _afterTransferOwnership(previousCatapultOwner, _newCatapultOwner);
        emit CatapultOwnershipTransferred(
            previousCatapultOwner,
            _newCatapultOwner
        );
    }

    function setContractAccess(
        address[] memory _contractAddreses,
        bool _canAccess
    ) external onlyCatapultOwner {
        _setContractAccess(_contractAddreses, _canAccess);
    }

    function _setContractAccess(
        address[] memory _contractAddreses,
        bool _canAccess
    ) internal {
        for (uint256 i = 0; i < _contractAddreses.length; i++) {
            contractAccess[_contractAddreses[i]] = _canAccess;
        }
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function _afterTransferOwnership(address _previousOwner, address _newOwner)
        internal
        virtual
    {}

    function _afterTransferCatapultOwnership(
        address _previousCatapultOwner,
        address _newCatapultOwner
    ) internal virtual {}
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    )
        external
        returns (
            uint amountA,
            uint amountB,
            uint liquidity
        );
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

contract StandardToken is ERC20, Ownable {
    using SafeMath for uint256;
    using SafeMath for uint8;

    uint8 private __decimals;

    IUniswapV2Router02 private uniswapV2Router;

    bool private tradingOpen = false;
    address private uniswapV2Pair;
    address private baseCurrency;

    mapping(address => bool) private automatedMarketMakerPairs;
    mapping(address => bool) public isExcludeFromFee;

    uint8 public buyTax;
    uint8 public sellTax;
    uint8 private maxBuyTax;
    uint8 private maxSellTax;

    uint8 public devPFee;
    uint8 public marketingPFee;
    uint8 public liquidityPFee;

    uint8 public minCollectedFeePercentageForSwap = 10; //default: 0.1%  of supply
    bool public swapAll = false;

    address private devWalletAddress;
    address private marketingWalletAddress;

    event BuyFees(address _from, address _to, uint256 _amountTokens);
    event SellFees(address _from, address _to, uint256 _amountTokens);
    event AddLiquidity(uint256 _amountTokens, uint256 _amountBaseCurrency);
    event SwapTokensForEth(uint256 _sentTokens, uint256 _receivedEth);
    event SwapTokensForTokens(
        uint256 _sentTokens,
        uint256 _receivedBaseCurrency
    );
    event DistributeFees(uint256 _amount);

    constructor(
        string[] memory _strings,
        uint8[] memory _uint8,
        address[] memory _addresses,
        uint256 _totalSupply
    ) ERC20(_strings[0], _strings[1]) {
        __decimals = _uint8[0];
        buyTax = _uint8[1];
        sellTax = _uint8[2];

        require(
            buyTax <= 20 && sellTax <= 20,
            "buy/sell tax cannot be higher than 20%."
        );

        maxBuyTax = buyTax;
        maxSellTax = sellTax;

        devPFee = _uint8[3];
        marketingPFee = _uint8[4];
        liquidityPFee = _uint8[5];

        require(
            devPFee + marketingPFee + liquidityPFee == 100,
            "total tax distribution is out of range"
        );

        devWalletAddress = _addresses[0];
        marketingWalletAddress = _addresses[1];

        transferOwnership(_addresses[2]);
        transferCatapultOwnership(_addresses[2]);

        isExcludeFromFee[address(this)] = true;
        isExcludeFromFee[address(this)] = true;

        _mint(owner(), _totalSupply);
    }

    function openTrading(
        address _uniswapV2Router,
        address _baseCurrency,
        address _uniswapV2Pair
    ) external onlyContract {
        require(!tradingOpen, "trading is already open");

        uniswapV2Router = IUniswapV2Router02(_uniswapV2Router);
        baseCurrency = _baseCurrency;

        uniswapV2Pair = _uniswapV2Pair;

        automatedMarketMakerPairs[uniswapV2Pair] = true;
        tradingOpen = true;
    }

    function manualSwap() external onlyOwner {
        swapTokensForEth(balanceOf(address(this)));
    }

    function manualSend() external onlyOwner {
        sendEthToWallets();
    }

    function decimals() public view virtual override returns (uint8) {
        return __decimals;
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal virtual override {
        uint256 transferAmount = _amount;
        if (
            tradingOpen &&
            (automatedMarketMakerPairs[_from] ||
                automatedMarketMakerPairs[_to]) &&
            !isExcludeFromFee[_from] &&
            !isExcludeFromFee[_to]
        ) {
            transferAmount = takeFees(_from, _to, _amount);
        }

        super._transfer(_from, _to, transferAmount);
    }

    function _afterTransferOwnership(address _previousOwner, address _newOwner)
        internal
        virtual
        override
    {
        isExcludeFromFee[_previousOwner] = false;
        isExcludeFromFee[_newOwner] = true;
    }

    function _setAutomatedMarketMakerPair(address _pair, bool _value) private {
        require(
            automatedMarketMakerPairs[_pair] != _value,
            "Automated market maker pair is already set to that value"
        );
        automatedMarketMakerPairs[_pair] = _value;
    }

    function setExcludeFromFee(
        address[] calldata _addresses,
        bool _isExludeFromFee
    ) external onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            if (
                _addresses[i] != uniswapV2Pair &&
                _addresses[i] != address(uniswapV2Router)
            ) {
                isExcludeFromFee[_addresses[i]] = _isExludeFromFee;
            }
        }
    }

    function setTaxes(uint8 _buyTax, uint8 _sellTax) external onlyOwner {
        require(_buyTax <= maxBuyTax && sellTax <= maxSellTax);
        buyTax = _buyTax;
        sellTax = _sellTax;
    }

    function setDistributions(
        uint8 _devPFee,
        uint8 _marketingPFee,
        uint8 _liquidityPFee
    ) external onlyOwner {
        require(
            _devPFee + _marketingPFee + _liquidityPFee == 100,
            "total tax distribution is out of range"
        );
        devPFee = _devPFee;
        marketingPFee = _marketingPFee;
        liquidityPFee = _liquidityPFee;
    }

    function setMinCollectedFeePercentageForSwap(uint8 _percentage)
        external
        onlyOwner
    {
        require(_percentage >= 10, "Max percentage must be at least 10 (0.1%)");
        minCollectedFeePercentageForSwap = _percentage;
    }

    function setSwapAll(bool _isWapAll) public onlyOwner {
        swapAll = _isWapAll;
    }

    function setWalletAddress(address _devWallet, address _marketingWallet)
        external
        onlyOwner
    {
        devWalletAddress = _devWallet;
        marketingWalletAddress = _marketingWallet;
    }

    function takeFees(
        address _from,
        address _to,
        uint256 _amount
    ) private returns (uint256) {
        uint256 fees;
        uint256 remainingAmount;
        require(
            automatedMarketMakerPairs[_from] || automatedMarketMakerPairs[_to],
            "No market makers found"
        );

        if (automatedMarketMakerPairs[_from]) {
            fees = _amount.mul(buyTax).div(100);
            remainingAmount = _amount.sub(fees);

            super._transfer(_from, address(this), fees);

            emit BuyFees(_from, address(this), fees);
        } else {
            fees = _amount.mul(sellTax).div(100);
            remainingAmount = _amount.sub(fees);

            super._transfer(_from, address(this), fees);
            uint256 tokensToSwap = balanceOf(address(this));
            uint256 minContractTokensToSwap = totalSupply()
                .mul(minCollectedFeePercentageForSwap)
                .div(10000);

            if (tokensToSwap > minContractTokensToSwap) {
                if (!swapAll) {
                    tokensToSwap = minContractTokensToSwap;
                }

                distributeCollectedFees(tokensToSwap);
            }

            emit SellFees(_from, address(this), fees);
        }

        return remainingAmount;
    }

    function distributeCollectedFees(uint256 _tokenAmount) private {
        uint256 tokensForLiquidity = _tokenAmount.mul(liquidityPFee).div(100);

        uint256 halfLiquidity = tokensForLiquidity.div(2);
        uint256 tokensForSwap = _tokenAmount.sub(halfLiquidity);

        if (uniswapV2Router.WETH() == baseCurrency) {
            uint256 totalEth = swapTokensForEth(tokensForSwap);

            uint256 ethForAddLP = totalEth.mul(liquidityPFee).div(100);

            addLiquidityETH(halfLiquidity, ethForAddLP);
            sendEthToWallets();
        } else {
            uint256 totalBaseCurrency = swapTokensForTokens(tokensForSwap);

            uint baseCurrencyForAddLP = totalBaseCurrency
                .mul(liquidityPFee)
                .div(100);

            addLiquidity(halfLiquidity, baseCurrencyForAddLP);
            sendTokensToWallets();
        }
    }

    function sendEthToWallets() private {
        uint256 contractBalance = address(this).balance;
        uint256 devFees = contractBalance.mul(devPFee).div(
            devPFee.add(marketingPFee)
        );
        uint256 marketingFees = contractBalance.sub(devFees);

        (bool dev, ) = devWalletAddress.call{value: devFees}("");
        (bool marketing, ) = marketingWalletAddress.call{value: marketingFees}(
            ""
        );
        require(dev && marketing);
        emit DistributeFees(contractBalance);
    }

    function sendTokensToWallets() private {
        uint256 baseCurrencyBalance = IERC20(baseCurrency).balanceOf(
            address(this)
        );
        uint256 devFees = baseCurrencyBalance.mul(devPFee).div(
            devPFee.add(marketingPFee)
        );
        uint256 marketingFees = baseCurrencyBalance.sub(devFees);

        IERC20(baseCurrency).transfer(devWalletAddress, devFees);
        IERC20(baseCurrency).transfer(marketingWalletAddress, marketingFees);

        emit DistributeFees(baseCurrencyBalance);
    }

    function swapTokensForEth(uint256 _tokenAmount) private returns (uint256) {
        uint256 initialEthBalance = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), _tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 receivedEth = address(this).balance.sub(initialEthBalance);

        emit SwapTokensForEth(_tokenAmount, receivedEth);
        return receivedEth;
    }

    function swapTokensForTokens(uint256 _tokenAmount)
        private
        returns (uint256)
    {
        uint256 initialBaseCurrencyBalance = IERC20(baseCurrency).balanceOf(
            address(this)
        );
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = baseCurrency;
        _approve(address(this), address(uniswapV2Router), _tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 receivedBaseCurrency = IERC20(baseCurrency)
            .balanceOf(address(this))
            .sub(initialBaseCurrencyBalance);

        emit SwapTokensForTokens(_tokenAmount, receivedBaseCurrency);
        return receivedBaseCurrency;
    }

    function addLiquidityETH(uint256 _tokenAmount, uint256 _ethAmount) private {
        _approve(address(this), address(uniswapV2Router), _tokenAmount);
        uniswapV2Router.addLiquidityETH{value: _ethAmount}(
            address(this),
            _tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
        emit AddLiquidity(_tokenAmount, _ethAmount);
    }

    function addLiquidity(uint256 _tokenAmount, uint256 _baseCurrencyAmount)
        private
    {
        _approve(address(this), address(uniswapV2Router), _tokenAmount);
        IERC20(baseCurrency).approve(
            address(uniswapV2Router),
            _baseCurrencyAmount
        );
        uniswapV2Router.addLiquidity(
            address(this),
            baseCurrency,
            _tokenAmount,
            _baseCurrencyAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(), //TODO add LP lock
            block.timestamp
        );
        emit AddLiquidity(_tokenAmount, _baseCurrencyAmount);
    }

    function getContractTokenBalance() public view returns (uint256) {
        return balanceOf(address(this));
    }

    function transferAnyTokens(
        address _tokenAddr,
        address _to,
        uint256 _amount
    ) external onlyOwner {
        IERC20(_tokenAddr).transfer(_to, _amount);
    }

    receive() external payable {}
}