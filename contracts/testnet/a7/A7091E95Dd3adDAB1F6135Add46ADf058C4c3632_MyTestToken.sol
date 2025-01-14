// SPDX-License-Identifier: GPL-2.0-or-later



pragma solidity 0.7.6;
pragma abicoder v2;

abstract contract ERC20Basic {
    uint256 public totalSupply;

    function balanceOf(address who) public view virtual returns (uint256);

    function transfer(address to, uint256 value) public virtual returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

library SafeMath {
    function wmul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function wdiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when wdividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    /**
     * @dev transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value) public override returns (bool) {
        require(_to != address(0), "INVALID_ADDRESS");
        require(_value <= balances[msg.sender], "INSUFFICIENT_FUNDS");

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to] + _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param _owner The address to query the the balance of.
     * @return balance An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address _owner) public view override returns (uint256 balance) {
        return balances[_owner];
    }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
abstract contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view virtual returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public virtual returns (bool);

    function approve(address spender, uint256 value) public virtual returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {
    using SafeMath for uint256;
    mapping(address => mapping(address => uint256)) internal allowed;

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public override returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public override returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public view override returns (uint256) {
        return allowed[_owner][_spender];
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     *
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _addedValue The amount of tokens to increase the allowance by.
     */
    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     *
     * approve should be called when allowed[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}

contract MyTestToken is StandardToken {
    using SafeMath for uint256;
    string public name;
    string public symbol;
    uint8 public decimals;

    address public owner;
    mapping(address => bool) public whitelist;

    mapping(address => mapping(uint256 => bool)) public isSend;

    event Mint(address indexed _to, uint256 _value);
    event Burn(address indexed _to, uint256 _value);

    event sendToken(address indexed recipient, uint256 amount, uint256 uuid);

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        totalSupply = 100000000 * 10**_decimals;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        balances[msg.sender] = totalSupply;
        whitelist[msg.sender] = true;
        owner = msg.sender;
    }

    function setWhitelist(address who, bool enable) public {
        require(msg.sender == owner, "OWNER_ONLY");
        whitelist[who] = enable;
    }

    function mint(address _to, uint256 _value) public {
        require(whitelist[msg.sender] == true, "WHITELISTED_ONLY");
        balances[_to] = balances[_to].add(_value);
        totalSupply = totalSupply.add(_value);
        emit Transfer(address(0), _to, _value);
        emit Mint(_to, _value);
    }

    function sendTokens(
        address recipient,
        uint256 uuid,
        uint256 amount
    ) external {
        require(whitelist[msg.sender] == true, "WHITELISTED_ONLY");
        require(!isSend[recipient][uuid], "token already send");
        balances[recipient] = balances[recipient].add(amount);
        totalSupply = totalSupply.add(amount);
        isSend[recipient][uuid] = true;
        emit Transfer(address(0), recipient, amount);
        emit sendToken(recipient, amount, uuid);
    }

    function burn(address _from, uint256 _value) public {
        require(whitelist[msg.sender] == true, "WHITELISTED_ONLY");
        balances[_from] = balances[_from].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Transfer(_from, address(0), _value);
        emit Burn(_from, _value);
    }
}