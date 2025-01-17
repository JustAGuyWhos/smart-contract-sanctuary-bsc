/**
 *Submitted for verification at BscScan.com on 2023-02-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/************************************************************
 *                                                          *
 *        github: https://github.com/Block-Way/             *
 *                                                          *
 ************************************************************
 *                                                          *
 *           H5 app:                                        *
 *                                                          *
 ************************************************************/
 
library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function sqrt3(uint y) internal pure returns (uint z) {
        z = sqrt(y * 10**12);
        z = sqrt(z * 10**6);
        z = sqrt(z * 10**6);
    }

    // decimals = 18;
    // (10**decimals) ** 0.125
    function vote2power(uint y) internal pure returns (uint z) {
        if (y >= 6**8 * 1 ether) {
            z = z * 6 / 100;
        } else {
            z = y * sqrt3(y) / 17782794100;
        }
    }
}

interface IUniswap {
    
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    
    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
}

contract HAB {
    using SafeMath for uint;

    string public constant name = 'Hash Ahead @BSC';
    string public constant symbol = 'HAB';
    uint8 public constant decimals = 18;
    uint  public totalSupply;

    mapping(address => uint) public balanceOf;
    mapping(address => Airdrop) public airdrops;

    mapping(address => mapping(address => uint)) public allowance;

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function pairFor(address factory,bytes memory code_hash) private view returns (address addr) {
        (address token0, address token1) = address(this) < USDT ? (address(this),USDT) : (USDT,address(this));
        addr = address(uint160(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                code_hash
            )))));
    }

    constructor() {
        // local test
        //pair = pairFor(0xdCCc660F92826649754E357b11bd41C31C0609B9,hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f');
        
        // bsc test
        pair = pairFor(0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc,hex'ecba335299a6693cb2ebc4782e74669b84290b6378ea3a3873c7231a8d7d1074');
        
        // bsc main
        //pair = pairFor(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73,hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5');
        
        uint _totalSupply = 1000_000 ether;
        _mint(msg.sender, _totalSupply);
        begin = block.number;
        spreads_length = 1;
        spreads[msg.sender] = Info({
            parent : address(this),
            cycle : 1,
            vote : 0,
            vote_power : 0,
            real_power : 0,
            lock_number : 0,
            child : new address[](0)});
        airdrops[msg.sender].cycle = 1 + 120;
    }

    function _mint(address to, uint value) internal {
        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _approve(address owner, address spender, uint value) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint value) private {        
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferVote(address to, uint value) external returns (bool) {
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(value);
        airdrops[to].vote = airdrops[to].vote.add(value);
        if (spreads[to].parent != address(0)) {
            spreads[to].vote = spreads[to].vote.add(value);
            spreads[to].vote_power = SafeMath.vote2power(spreads[to].vote);
        }
        emit Transfer(msg.sender, address(this), value);
        balanceOf[address(this)] = balanceOf[address(this)].add(value);
        return true;
    }


    function transferFrom(address from, address to, uint value) external returns (bool) {
        if (allowance[from][msg.sender] < (2**256 - 1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        }
        _transfer(from, to, value);
        return true;
    }

    struct LP {
        uint lp;
        uint quantity;
        uint weight;
        uint lock_number;
    }

    struct Airdrop {
        uint cycle;
        uint vote;
    }
    // 
    uint public whole_weight = 0;
    // 
    uint public whole_quantity = 0;
    //
    mapping(address => LP) public lps;

    uint public begin;
    // 
    uint public height = 0;
    //
    uint public constant height_profit = 0.05 ether;
    
    // local test
    //address public constant USDT = 0x6f2fa37EBfaf089C4Fd7e6124C1028306943D11d;
    // bsc test 
    address public constant USDT = 0xc0cf857BdC00c6eF5544aD5E920edd9848CCb9C8;
    // bsc main
    //address public constant USDT = 0x55d398326f99059fF775485246999027B3197955;

    // Local test
    //  Revenue cycle (1 minute)
    //uint public constant cycle_period = 20;
    //uint public constant cycle_profit = 20 * (0.05 ether);

    // test
    //  Revenue cycle (1 day)
    uint public constant cycle_period = 24 * 60 * 20;
    uint public constant cycle_profit = 24 * 60 * 20 * (0.05 ether);

    // production
    /*
    uint public constant cycle_period = 15 * 24 * 60 * 20;
    // 
    uint public constant cycle_profit = 15 * 24 * 60 * 20 * (0.05 ether);
    */
    address public pair;

    function addLiquidity(uint amount) external returns (uint usdt_amount, uint liquidity) { 
        require(spreads[msg.sender].parent != address(0), "Parent address is not a generalization set");
        (uint reserveA, uint reserveB,) = IUniswap(pair).getReserves();
        usdt_amount = address(this) < USDT ? amount.mul(reserveB) / reserveA : amount.mul(reserveA) / reserveB;
        _transfer(msg.sender, pair, amount);
        IUniswap(USDT).transferFrom(msg.sender, pair, usdt_amount);
        liquidity = IUniswap(pair).mint(address(this));

        updateLP();
        lps[msg.sender].lp = lps[msg.sender].lp.add(liquidity);
        lps[msg.sender].lock_number = block.number;
        Add(msg.sender,amount);
    }

    function removeLiquidity(uint liquidity) external returns (uint amountHAH, uint amountUSDT) {
        require(spreads[msg.sender].parent != address(0), "Parent address is not a generalization set");
        require(block.number > (lps[msg.sender].lock_number + cycle_period * 2),"The unlocking date has not yet arrived");
        
        uint lp = lps[msg.sender].lp;
        assert(liquidity <= lp);
        IUniswap(pair).transfer(pair, liquidity);
        (uint amount0, uint amount1) = IUniswap(pair).burn(msg.sender);
        (amountHAH, amountUSDT) = address(this) < USDT ? (amount0, amount1) : (amount1, amount0);
    
        updateLP();
        lps[msg.sender].lp = lp.sub(liquidity);
        Del(msg.sender,lps[msg.sender].quantity.mul(liquidity) / lp);
    }

    function updateLP() private {
        if (whole_weight > 0) {
            uint add_height = block.number.sub(begin.add(height));
            if (add_height > 0) {
                height = height.add(add_height);
                whole_quantity = whole_quantity.add(add_height.mul(height_profit));
            }
        }
    }

    function Add(address addr,uint q) private {
        if (whole_quantity > 0) {
            uint x = whole_weight.mul(q) / whole_quantity;
            whole_quantity = whole_quantity.add(q);
            whole_weight = whole_weight.add(x);
            lps[addr].quantity = lps[addr].quantity.add(q);
            lps[addr].weight = lps[addr].weight.add(x);
        } else {
            whole_quantity = q;
            whole_weight = q;
            lps[addr].weight = q;
            lps[addr].quantity = q;
        }
    }

    function Del(address addr,uint q) private {
        uint quantity = lps[addr].quantity;
        if (quantity > 0) {
            if (q > quantity) {
                q = quantity;
            }
            uint weight = lps[addr].weight;
            uint new_weight = weight.mul(q) / quantity;
            uint out_quantity = whole_quantity.mul(new_weight) / whole_weight;
            _mint(msg.sender,out_quantity.sub(q));
            
            lps[addr].weight = weight.sub(new_weight);
            lps[addr].quantity = quantity.sub(q);
            whole_weight  = whole_weight.sub(new_weight);
            whole_quantity = whole_quantity.sub(out_quantity);
        }
    }

    struct Info {
        address parent;
        address[] child;
        //       
        uint cycle;
        // Voting
        uint vote;
        // Voting power
        uint vote_power;
        // Real computing power
        uint real_power;
        // Voting lock number
        uint lock_number;
    }

    mapping(address => Info) public spreads;
    uint public spreads_length;
}

contract Mining is HAB
{
    using SafeMath for uint;
    bytes32 private DOMAIN_SEPARATOR;

    //keccak256("popularize(address addr)");
    bytes32 private constant PERMIT_TYPEHASH = 0x21cf163f92d861d4d1aca6cf2580b603353711f20e52675c104cd16e528edf30;

    //keccak256("setChild(address addr_old,address addr_new)");
    bytes32 private constant PERMIT_TYPEHASH_SETCHILD = 0x9d76e746d4f1502d91350b8de3086a0a837140a295a5bc95668fa2a961dca549;

    struct power_profit {
        uint power;
        uint profit;
    }
    
    uint public whole_power = 0;
    mapping(uint => power_profit) public power_profit_whole;
    uint public cycle = 1;
  
    event Popularize(address indexed parent, address indexed children,uint indexed cycle,uint timestamp);
    
    /**
     * @dev constructor
     */
    constructor() {
        uint chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                keccak256(bytes(name)),
                keccak256(bytes('1')),
                chainId,
                address(this)
            )
        );
        emit Popularize(address(this), msg.sender,cycle,block.timestamp);
    }

    function popularizeFast(address addr,address temp,
        uint8 addr_v, bytes32 addr_r, bytes32 addr_s,
        uint8 temp_v, bytes32 temp_r, bytes32 temp_s)
        external returns (bool ret)
    {
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, temp))
            )
        );
        require(addr == ecrecover(digest, addr_v, addr_r, addr_s),"signature data1 error");
        require(temp == ecrecover(keccak256(abi.encodePacked(msg.sender)),temp_v, temp_r, temp_s),"signature data2 error");
        return popularize(addr);
    }

    function popularize(address addr,uint8 v, bytes32 r, bytes32 s) external returns (bool ret)
    {
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, msg.sender))
            )
        );
        require(addr == ecrecover(digest, v, r, s),"signature data error");
        return popularize(addr);
    }

    /**
     * @dev popularize
     */
    function popularize(address addr) private returns (bool ret)
    {
        require(spreads[msg.sender].parent != address(0), "Parent address is not a generalization set");
        require(spreads[addr].parent == address(0), "Address has been promoted");
        require(spreads[msg.sender].child.length < 36,"Promotion data cannot be greater than 36");
        spreads[addr] = Info({
            parent : msg.sender,
            cycle : cycle,
            vote : airdrops[addr].vote,
            vote_power : SafeMath.vote2power(airdrops[addr].vote),
            real_power : 0,
            lock_number : 0,
            child : new address[](0)});
        spreads[msg.sender].child.push(addr);
        spreads_length++;
        airdrops[addr].cycle = cycle + 120;
        emit Popularize(msg.sender,addr,cycle,block.timestamp);
        ret = true;
    }

    function setChild(address addr_old,address addr_new,uint8 v, bytes32 r, bytes32 s) external {
        assert(spreads[addr_old].parent == msg.sender && spreads[addr_new].parent == address(0));
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH_SETCHILD,addr_old,addr_new))
            )
        );
        require(addr_old == ecrecover(digest, v, r, s),"signature data error");
        emit Transfer(addr_old, addr_new, balanceOf[addr_old]);

        spreads[addr_new] = Info({
            parent : spreads[addr_old].parent,
            cycle : spreads[addr_old].cycle,
            vote : spreads[addr_old].vote,
            vote_power : spreads[addr_old].vote_power,
            real_power : spreads[addr_old].real_power,
            lock_number : spreads[addr_old].lock_number,
            child : spreads[addr_old].child});
        for (uint i = 0; i < spreads[msg.sender].child.length; i++) {
            if (spreads[msg.sender].child[i] == addr_old) {
                spreads[msg.sender].child[i] = addr_new;
            }    
        }
        for (uint i = 0; i < spreads[addr_old].child.length; i++) {
            spreads[spreads[addr_old].child[i]].parent = addr_new;
        }
        delete spreads[addr_old];
        
        assert(airdrops[addr_new].cycle == 0 && airdrops[addr_new].vote == 0);
        airdrops[addr_new].cycle = airdrops[addr_old].cycle;
        airdrops[addr_new].vote = airdrops[addr_old].vote;
        airdrops[addr_old].cycle = 0;
        airdrops[addr_old].vote = 0;
        
        assert(balanceOf[addr_new] == 0);
        balanceOf[addr_new] = balanceOf[addr_old];
        balanceOf[addr_old] = 0;
    
        lps[addr_new] = LP({
            lp : lps[addr_old].lp,
            quantity : lps[addr_old].quantity,
            weight : lps[addr_old].weight,
            lock_number : lps[addr_old].lock_number     
        });
        delete lps[addr_old];
    }


    /**
     * @dev voteIn
     */
    function voteIn(uint256 value) external returns (uint ret)
    {
        _update();
        address addr = tx.origin;
        require(spreads[addr].parent != address(0), "Parent address is not a generalization set");
        balanceOf[addr] = balanceOf[addr].sub(value);
        spreads[addr].vote = spreads[addr].vote.add(value);
        spreads[addr].vote_power = SafeMath.vote2power(spreads[addr].vote);
        balanceOf[address(this)] = balanceOf[address(this)].add(value);
        emit Transfer(addr, address(this), value);
        _voteMining(addr);
        ret = value;
    }

    /**
     * @dev voteOut
     */
    function voteOut(uint256 value) external returns (uint ret)
    {
        address addr = tx.origin;
        _update();
        require(spreads[addr].parent != address(0), "Parent address is not a generalization set");
        require(block.number > (spreads[addr].lock_number + cycle_period * 2),"The unlocking date has not yet arrived");
        
        uint vote = airdrops[addr].vote;
        if (vote > 0) {
            if (cycle <= airdrops[addr].cycle) {
                require(spreads[addr].vote.sub(value) >= vote,"Air drop cannot be claimed in advance");
            } else if (cycle <= airdrops[addr].cycle.add(50)) {
                require(spreads[addr].vote.sub(value) >= vote * (airdrops[addr].cycle.add(50).sub(cycle)) / 50,"Too many airdrops");
            }
        }
        spreads[addr].vote = spreads[addr].vote.sub(value);
        spreads[addr].vote_power = SafeMath.vote2power(spreads[addr].vote);
        balanceOf[addr] = balanceOf[addr].add(value);
        balanceOf[address(this)] = balanceOf[address(this)].sub(value);
        emit Transfer(address(this), addr, value);
        ret = value;
    }

    /**
     * @dev voteMining()
     */
    function voteMining() external returns (uint mint,uint f)
    {
        address addr = tx.origin;
        require(spreads[addr].parent != address(0), "Parent address is not a generalization set");
        return _voteMining(addr);
    }

    /**
     * @dev parents(address addr)
     */
    function parents(address addr) private view returns(
        address[] memory addrs,
        uint[] memory powers) 
    {
        uint l = 0;
        address addr_temp = addr;
        while (spreads[addr_temp].parent != address(this)) {
            addr_temp = spreads[addr_temp].parent;
            l++;
        }
        powers = new uint[](l);
        addrs = new address[](l);
        l = 0;
        addr_temp = addr;
        while (spreads[addr_temp].parent != address(this)) {
            addr_temp = spreads[addr_temp].parent;
            addrs[l] = addr_temp;
            uint pow = spreads[addr_temp].vote_power;
            powers[l] = pow;
            l++;
        }
    }

    /**
     * @dev _voteMining
     */
    function _voteMining(address addr) private returns (uint mint,uint f)
    {
        _update();
        if (spreads[addr].cycle < cycle) {
            uint old_cycle = spreads[addr].cycle;
            uint old_profit = power_profit_whole[old_cycle].profit;
            uint old_power = power_profit_whole[old_cycle].power;
            if (old_power > 0 && spreads[addr].real_power > 0) {
                mint = old_profit.mul(spreads[addr].real_power) / old_power;
                _mint(addr,mint);
            }
            spreads[addr].real_power = 0;
            spreads[addr].cycle = cycle;
        }
        uint old_s = spreads[addr].real_power;
        uint s = spreadPower(addr);
        if (s > old_s) {
            whole_power = whole_power.add(s.sub(old_s));
            spreads[addr].real_power = s;
            spreads[addr].lock_number = block.number;
            f = s;
        } else {
            f = 0;
        }
    }

    function _update() private returns (bool) {
        if (block.number > begin.add(cycle.mul(cycle_period))) {
            power_profit_whole[cycle] = power_profit({
                power : whole_power,
                profit : cycle_profit });
            whole_power = 0;
            cycle += 1;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev spreadChild
     */
    function spreadChild(address addr) public view returns (
        address[] memory addrs,
        uint[] memory votes,
        uint[] memory powers) 
    {
        addrs = spreads[addr].child;
        uint n = spreads[addr].child.length;
        votes = new uint[](n);
        powers = new uint[](n);
        for (uint i = 0; i < n; i++) {
            votes[i] = spreads[addrs[i]].vote;
            powers[i] = spreads[addrs[i]].vote_power;
        }
    }

    /**
     * @dev spreadParent(address addr)
     */
    function spreadParent(address addr) external view returns(
        address[] memory addrs,
        uint[] memory powers) 
    {
        if (spreads[addr].parent == address(0) ) {
            return (new address[](0),new uint[](0));
        } else {
            return parents(addr);
        }
    }

    /**
     * @dev spreadPower
     */
    function spreadPower(address addr) public view returns (uint power_)
    {
        uint v = spreads[addr].vote_power;
        uint sum = v.mul(4);
        sum = sum.add(SafeMath.min(v,spreads[spreads[addr].parent].vote_power).mul(2));

        uint n = spreads[addr].child.length;
        for (uint i = 0; i < n; i++) {
            sum = sum.add(SafeMath.min(v,spreads[spreads[addr].child[i]].vote_power));
        }
        power_ = sum;
    }

    function number2timestamp(uint number) private view returns(uint ts) {
        if (block.number > number) {
            ts = block.timestamp - (block.number - number) * 3;
        } else if (block.number < number) {
            ts = block.timestamp + (number - block.number) * 3;
        } else {
            ts = block.timestamp;
        }
    }

    function profit(address addr) external view returns(
        uint lp_value, uint lp_ratio,
        uint pow_value,uint pow_ratio,
        bool reflect,  uint pow_out_time, uint lp_out_time,
        uint number, uint timestamp) 
    {
        number = block.number;
        timestamp = block.timestamp;
        if (lps[addr].weight == 0) {
            lp_value = 0;
            lp_ratio = 0;
        } else {
            uint add = block.number - begin - height;
            lp_value = (whole_quantity + add * height_profit) * lps[addr].weight / whole_weight - lps[addr].quantity;
            if (lp_value == 2**256 - 1) {
                lp_value = 0;
            }
            lp_ratio = lps[addr].weight * 10**6 / whole_weight;
        }
        if (spreads[addr].real_power == 0) {
            pow_value = 0;
            pow_ratio = 0;
        } else {
            if (spreads[addr].cycle == cycle) {
                pow_value = (cycle_profit * spreads[addr].real_power) / whole_power;
                pow_ratio = spreads[addr].real_power * 10**6 / whole_power;
            } else {
                pow_value = cycle_profit * spreads[addr].real_power / power_profit_whole[spreads[addr].cycle].power;
                pow_ratio = spreads[addr].real_power * 10**6 / power_profit_whole[spreads[addr].cycle].power;
            }
        }
        if (spreads[addr].cycle > 0 && block.number > begin + spreads[addr].cycle * cycle_period) {
            reflect = true;
        } else {
            reflect = false;
        }
        if (spreads[addr].lock_number > 0) {
            pow_out_time = number2timestamp(spreads[addr].lock_number + cycle_period * 2);
        } else {
            pow_out_time = 0;
        }
        if (lps[addr].lock_number > 0) {
            lp_out_time = number2timestamp(lps[addr].lock_number + cycle_period * 2);
        } else {
            lp_out_time = 0;
        }
    }
}