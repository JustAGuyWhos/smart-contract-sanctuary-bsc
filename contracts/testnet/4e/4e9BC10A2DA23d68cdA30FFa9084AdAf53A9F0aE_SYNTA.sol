pragma solidity 0.8.17;

// ----------------------------------------------------------------------------
// SYNTA token main contract (2022)
//
// Symbol       : SYNTA
// Name         : SYNTA
// Total supply : 300.000.000 (burnable)
// Decimals     : 18
// ----------------------------------------------------------------------------
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function getOwner() external view returns (address);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Ownable {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed from, address indexed to);

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Ownable: Caller is not the owner");
        _;
    }

    function transferOwnership(address transferOwner) external onlyOwner {
        require(transferOwner != newOwner);
        newOwner = transferOwner;
    }

    function acceptOwnership() virtual public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused() {
        require(paused);
        _;
    }

    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }

    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
}

contract SYNTA is IERC20, Ownable, Pausable {
    mapping (address => mapping (address => uint)) private _allowances;
    
    mapping (address => uint) private _unfrozenBalances;

    mapping (address => uint) private _vestingNonces;
    mapping (address => mapping (uint => uint)) private _vestingAmounts;
    mapping (address => mapping (uint => uint)) private _unvestedAmounts;
    mapping (address => mapping (uint => uint)) private _vestingTypes; //0 - multivest, 1 - single vest, > 2 give by vester id
    mapping (address => mapping (uint => uint)) private _vestingReleaseStartDates;
    mapping (address => mapping (uint => uint)) private _vestingSecondPeriods;

    uint private _totalSupply = 300_000_000e18;
    string private constant _name = "SYNTA";
    string private constant _symbol = "SYNTA";
    uint8 private constant _decimals = 18;

    uint public constant vestingSaleSecondPeriod = 6 minutes;

    uint public giveAmount;
    mapping (address => bool) public vesters;

    bytes32 public immutable DOMAIN_SEPARATOR;
    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    mapping (address => uint) public nonces;

    event Unvest(address indexed user, uint amount);

    constructor () {
        _unfrozenBalances[owner] = _totalSupply;

        emit Transfer(address(0), owner, _unfrozenBalances[owner]);

        uint chainId = block.chainid;

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,uint256 chainId,address verifyingContract)'),
                keccak256(bytes(_name)),
                chainId,
                address(this)
            )
        );
        giveAmount = _totalSupply / 10;
    }

    receive() payable external {
        revert();
    }

    function getOwner() public override view returns (address) {
        return owner;
    }

    function approve(address spender, uint amount) external override whenNotPaused returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transfer(address recipient, uint amount) external override whenNotPaused returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) external override whenNotPaused returns (bool) {
        _transfer(sender, recipient, amount);
        
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "SYNTA::transferFrom: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance - amount);

        return true;
    }

    function permit(address owner, address spender, uint amount, uint deadline, uint8 v, bytes32 r, bytes32 s) external whenNotPaused {
        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, amount, nonces[owner]++, deadline));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "SYNTA::permit: invalid signature");
        require(signatory == owner, "SYNTA::permit: unauthorized");
        require(block.timestamp <= deadline, "SYNTA::permit: signature expired");

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    function increaseAllowance(address spender, uint addedValue) external returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) external returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "SYNTA::decreaseAllowance: decreased allowance below zero");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);

        return true;
    }

    function unvest() external whenNotPaused returns (uint unvested) {
        require (_vestingNonces[msg.sender] > 0, "SYNTA::unvest:No vested amount");
        for (uint i = 1; i <= _vestingNonces[msg.sender]; i++) {
            if (_vestingAmounts[msg.sender][i] == _unvestedAmounts[msg.sender][i]) continue;
            if (_vestingReleaseStartDates[msg.sender][i] > block.timestamp) break;
            uint toUnvest = (block.timestamp - _vestingReleaseStartDates[msg.sender][i]) * _vestingAmounts[msg.sender][i] / (_vestingSecondPeriods[msg.sender][i] - _vestingReleaseStartDates[msg.sender][i]);
            if (toUnvest > _vestingAmounts[msg.sender][i]) {
                toUnvest = _vestingAmounts[msg.sender][i];
            } 
            uint totalUnvestedForNonce = toUnvest;
            toUnvest -= _unvestedAmounts[msg.sender][i];
            unvested += toUnvest;
            _unvestedAmounts[msg.sender][i] = totalUnvestedForNonce;
        }
        _unfrozenBalances[msg.sender] += unvested;
        emit Unvest(msg.sender, unvested);
    }

    function give(address user, uint amount, uint vesterId) external {
        require (giveAmount > amount, "SYNTA::give: give finished");
        require (vesters[msg.sender], "SYNTA::give: not vester");
        giveAmount -= amount;
        _vest(user, amount, vesterId, block.timestamp + vestingSaleSecondPeriod, block.timestamp + vestingSaleSecondPeriod);
    }

    function vest(address user, uint amount) external {
        require (vesters[msg.sender], "SYNTA::vest: not vester");
        _vest(user, amount, 1, block.timestamp + vestingSaleSecondPeriod, block.timestamp + vestingSaleSecondPeriod);
    }


    function vestPurchase(address user, uint amount) external {
        require (vesters[msg.sender], "SYNTA::vestPurchase: not vester");
        _transfer(msg.sender, owner, amount);
        _vest(user, amount, 1, block.timestamp + vestingSaleSecondPeriod, block.timestamp + vestingSaleSecondPeriod);
    }

    function burnTokens(uint amount) external onlyOwner returns (bool success) {
        require(amount <= _unfrozenBalances[owner], "SYNTA::burnTokens: exceeds available amount");

        uint256 ownerBalance = _unfrozenBalances[owner];
        require(ownerBalance >= amount, "SYNTA::burnTokens: burn amount exceeds owner balance");

        _unfrozenBalances[owner] = ownerBalance - amount;
        _totalSupply -= amount;
        emit Transfer(owner, address(0), amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint) {
        return _allowances[owner][spender];
    }

    function decimals() external override pure returns (uint8) {
        return _decimals;
    }

    function name() external pure returns (string memory) {
        return _name;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function totalSupply() external view override returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint) {
        uint amount = _unfrozenBalances[account];
        if (_vestingNonces[account] == 0) return amount;
        for (uint i = 1; i <= _vestingNonces[account]; i++) {
            amount = amount + _vestingAmounts[account][i] - _unvestedAmounts[account][i];
        }
        return amount;
    }

    function availableForUnvesting(address user) external view returns (uint unvestAmount) {
        if (_vestingNonces[user] == 0) return 0;
        for (uint i = 1; i <= _vestingNonces[user]; i++) {
            if (_vestingAmounts[user][i] == _unvestedAmounts[user][i]) continue;
            if (_vestingReleaseStartDates[user][i] > block.timestamp) break;
            uint toUnvest = (block.timestamp - _vestingReleaseStartDates[user][i]) * _vestingAmounts[user][i] / (_vestingSecondPeriods[user][i] - _vestingReleaseStartDates[user][i]);
            if (toUnvest > _vestingAmounts[user][i]) {
                toUnvest = _vestingAmounts[user][i];
            } 
            toUnvest -= _unvestedAmounts[user][i];
            unvestAmount += toUnvest;
        }
    }

    function availableForTransfer(address account) external view returns (uint) {
        return _unfrozenBalances[account];
    }

    function vestingInfo(address user, uint nonce) external view returns (uint vestingAmount, uint unvestedAmount, uint vestingReleaseStartDate, uint vestingSecondPeriod, uint vestType) {
        vestingAmount = _vestingAmounts[user][nonce];
        unvestedAmount = _unvestedAmounts[user][nonce];
        vestingReleaseStartDate = _vestingReleaseStartDates[user][nonce];
        vestingSecondPeriod = _vestingSecondPeriods[user][nonce];
        vestType = _vestingTypes[user][nonce];
    }

    function vestingNonces(address user) external view returns (uint lastNonce) {
        return _vestingNonces[user];
    }

    function _approve(address owner, address spender, uint amount) private {
        require(owner != address(0), "SYNTA::_approve: approve from the zero address");
        require(spender != address(0), "SYNTA::_approve: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint amount) private {
        require(sender != address(0), "SYNTA::_transfer: transfer from the zero address");
        require(recipient != address(0), "SYNTA::_transfer: transfer to the zero address");

        uint256 senderAvailableBalance = _unfrozenBalances[sender];
        require(senderAvailableBalance >= amount, "SYNTA::_transfer: amount exceeds available for transfer balance");
        _unfrozenBalances[sender] = senderAvailableBalance - amount;
        _unfrozenBalances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _vest(address user, uint amount, uint vestType, uint vestingReleaseStart, uint vestingReleaseSecondPeriod) private {
        require(user != address(0), "SYNTA::_vest: vest to the zero address");
        require(vestingReleaseStart >= 0, "SYNTA::_vest: vesting release start date should be more then 0");
        require(vestingReleaseSecondPeriod >= vestingReleaseStart, "SYNTA::_vest: vesting release end date should be more then start date");
        uint nonce = ++_vestingNonces[user];
        _vestingAmounts[user][nonce] = amount;
        _vestingReleaseStartDates[user][nonce] = vestingReleaseStart;
        _vestingSecondPeriods[user][nonce] = vestingReleaseSecondPeriod;
        _unfrozenBalances[owner] -= amount;
        _vestingTypes[user][nonce] = vestType;
        emit Transfer(owner, user, amount);
    }

    function multisend(address[] memory to, uint[] memory values) external onlyOwner returns (uint) {
        require(to.length == values.length);
        require(to.length < 100);
        uint sum;
        for (uint j; j < values.length; j++) {
            sum += values[j];
        }
        _unfrozenBalances[owner] -= sum;
        for (uint i; i < to.length; i++) {
            _unfrozenBalances[to[i]] += values[i];
            emit Transfer(owner, to[i], values[i]);
        }
        return(to.length);
    }

    function multivest(address[] memory to, uint[] memory values, uint[] memory vestingReleaseStarts, uint[] memory vestingSecondPeriods) external onlyOwner returns (uint) { 
        require(to.length == values.length);
        require(to.length < 100);
        uint sum;
        for (uint j; j < values.length; j++) {
            sum += values[j];
        }
        _unfrozenBalances[owner] -= sum;
        for (uint i; i < to.length; i++) {
            uint nonce = ++_vestingNonces[to[i]];
            _vestingAmounts[to[i]][nonce] = values[i];
            _vestingReleaseStartDates[to[i]][nonce] = vestingReleaseStarts[i];
            _vestingSecondPeriods[to[i]][nonce] = vestingSecondPeriods[i];
            _vestingTypes[to[i]][nonce] = 0;
            emit Transfer(owner, to[i], values[i]);
        }
        return(to.length);
    }

    function updateVesters(address vester, bool isActive) external onlyOwner { 
        vesters[vester] = isActive;
    }

    function updateGiveAmount(uint amount) external onlyOwner { 
        require (_unfrozenBalances[owner] > amount, "SYNTA::updateGiveAmount: exceed owner balance");
        giveAmount = amount;
    }
    
    function transferAnyERC20Token(address tokenAddress, uint tokens) external onlyOwner returns (bool success) {
        return IERC20(tokenAddress).transfer(owner, tokens);
    }

    function acceptOwnership() public override {
        uint amount = _unfrozenBalances[owner];
        _unfrozenBalances[newOwner] = amount;
        _unfrozenBalances[owner] = 0;
        emit Transfer(owner, newOwner, amount);
        super.acceptOwnership();
    }
}