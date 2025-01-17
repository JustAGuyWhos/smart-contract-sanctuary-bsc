/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

pragma solidity ^0.8.1;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
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
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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
    mapping(address => bool) public isAdmin;
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    constructor() {
        _transferOwnership(_msgSender());
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    modifier onlyAdmin() {
        require(
            owner() == _msgSender() || isAdmin[_msgSender()],
            "Ownable: Not Admin"
        );
        _;
    }
    function setIsAdmin(address account, bool newValue)
        public
        virtual
        onlyAdmin
    {
        isAdmin[account] = newValue;
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Stake is Ownable {
    using SafeMath for uint256;
    using Address for address;
    struct UserInfo {
        bool isExist;
        bool isValid;
        uint256 invites;
        uint256 balance;
        uint256 rewardTotal;
        uint256 amount;
        uint256 rewardDebt;
        uint256 inviteRewardBalance;
        uint256 inviteRewardTotal;
        address refer;
    }
    mapping(address => mapping(uint256 => address)) public userInvites;
    mapping(address => uint256) public userInviteTotals;
    mapping(address => UserInfo) public users;
    mapping(uint256 => address) public userAdds;
    uint256 public userTotal;
    uint256 private _validMin;
    uint256 private _perBlock;
    uint256 private _rewardPerLP;
    uint256 private _lastRewardBlock;
    uint256 private _rewardTotal;
    uint256 private _withdrawTotal;
    IERC20 private _LP;
    IERC20 private _KING;
    event Deposit(
        address refer,
        address user,
        uint256 amount,
        uint256 amountTotal
    );
    event Relieve(
        address refer,
        address user,
        uint256 amount,
        uint256 amountTotal
    );
    event Withdraw(address user, uint256 amount);
    receive() external payable {}
    function withdrawETH() public onlyAdmin {
        payable(msg.sender).transfer(address(this).balance);
    }
    function withdrawToken(IERC20 token) public onlyAdmin {
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }
    constructor() {
        _lastRewardBlock = block.number;
        _LP = IERC20(0xBdA019A523506bC7B7c092a3B882792E582C039c);
        _KING = IERC20(0xC9Be4a8AEb0F5fE0bde9cdF48ACC4a1505700784);
        _perBlock = 31250000000000;
        _validMin = 100 * 1e18;
    }
    function setRewardDay(uint256 reward) public onlyAdmin {
        updatePool();
        _perBlock = reward / 28800;
    }
    function setValidMin(uint256 valid) public onlyAdmin {
        _validMin = valid;
    }
    function setToken(address token, address lp) public onlyAdmin {
        _LP = IERC20(lp);
        _KING = IERC20(token);
    }
    function getRewardTotal() public view returns (uint256) {
        uint256 cakeReward = _perBlock * (block.number - _lastRewardBlock);
        return _rewardTotal.add(cakeReward);
    }
    function getWithdrawTotal() public view returns (uint256) {
        return _withdrawTotal;
    }
    function getRewardPerLP() public view returns (uint256) {
        uint256 accCakePerShare = _rewardPerLP;
        uint256 lpSupply = _LP.balanceOf(address(this));
        if (block.number > _lastRewardBlock && lpSupply != 0) {
            uint256 cakeReward = _perBlock * (block.number - _lastRewardBlock);
            accCakePerShare = accCakePerShare.add(
                cakeReward.mul(1e12).div(lpSupply)
            );
        }
        return accCakePerShare;
    }
    function getInvites(address account)
        public
        view
        returns (address[] memory invites)
    {
        invites = new address[](userInviteTotals[account]);
        for (uint256 i = 0; i < userInviteTotals[account]; i++) {
            invites[i] = userInvites[account][i + 1];
        }
    }
    function getInvitesInfo(address account)
        public
        view
        returns (address[] memory invites, UserInfo[] memory infos)
    {
        invites = new address[](userInviteTotals[account]);
        infos = new UserInfo[](userInviteTotals[account]);
        for (uint256 i = 0; i < userInviteTotals[account]; i++) {
            invites[i] = userInvites[account][i + 1];
            infos[i] = users[invites[i]];
        }
    }
    function deposit(uint256 amount, address refer) public {
        require(_LP.balanceOf(msg.sender) >= amount, "Insufficient LP");
        if (!users[refer].isExist) {
            users[refer] = UserInfo({
                isExist: true,
                isValid: false,
                invites: 0,
                balance: 0,
                rewardTotal: 0,
                amount: 0,
                rewardDebt: 0,
                inviteRewardBalance: 0,
                inviteRewardTotal: 0,
                refer: address(0)
            });
            userTotal = userTotal.add(1);
            userAdds[userTotal] = refer;
        }
        updatePool();
        UserInfo storage user = users[msg.sender];
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(_rewardPerLP).div(1e12).sub(
                user.rewardDebt
            );
            if (pending > 0) {
                user.balance = user.balance.add(pending);
                user.rewardTotal = user.rewardTotal.add(pending);
            }
        }
        if (amount > 0) {
            _LP.transferFrom(msg.sender, address(this), amount);
            user.amount = user.amount.add(amount);
        }
        user.rewardDebt = user.amount.mul(_rewardPerLP).div(1e12);
        if (!user.isExist) {
            user.isExist = true;
            userTotal = userTotal.add(1);
            userAdds[userTotal] = msg.sender;
        }
        if (
            user.refer == address(0) &&
            refer != address(0) &&
            refer != msg.sender
        ) {
            user.refer = refer;
            userInviteTotals[refer] = userInviteTotals[refer].add(1);
            userInvites[refer][userInviteTotals[refer]] = msg.sender;
        }
        if (
            !user.isValid &&
            user.amount >= _validMin &&
            user.refer != address(0)
        ) {
            user.isValid = true;
            users[user.refer].invites++;
        }
        emit Deposit(user.refer, msg.sender, amount, user.amount);
    }
    function relieve(uint256 amount) public {
        UserInfo storage user = users[msg.sender];
        require(user.amount >= amount, "withdraw: not good");
        updatePool();
        uint256 pending = user.amount.mul(_rewardPerLP).div(1e12).sub(
            user.rewardDebt
        );
        if (pending > 0) {
            user.balance = user.balance.add(pending);
            user.rewardTotal = user.rewardTotal.add(pending);
        }
        if (amount > 0) {
            user.amount = user.amount.sub(amount);
            _LP.transfer(msg.sender, amount);
        }
        user.rewardDebt = user.amount.mul(_rewardPerLP).div(1e12);
        emit Relieve(user.refer, msg.sender, amount, user.amount);
    }
    function withdraw() public {
        UserInfo storage user = users[msg.sender];
        updatePool();
        uint256 pending = user.amount.mul(_rewardPerLP).div(1e12).sub(
            user.rewardDebt
        );
        if (pending > 0) {
            user.balance = user.balance.add(pending);
            user.rewardTotal = user.rewardTotal.add(pending);
        }
        user.rewardDebt = user.amount.mul(_rewardPerLP).div(1e12);
        if (user.inviteRewardBalance > 0) {
            _KING.transfer(msg.sender, user.inviteRewardBalance);
        }
        uint256 amount = user.balance;
        if (user.balance > 0) {
            _KING.transfer(msg.sender, user.balance);
        }
        _withdrawTotal = _withdrawTotal.add(
            user.balance.add(user.inviteRewardBalance)
        );
        user.balance = 0;
        user.inviteRewardBalance = 0;
        _handleInviteReward(msg.sender, amount);
    }
    function getUserPending(address account) external view returns (uint256) {
        UserInfo memory user = users[account];
        uint256 accCakePerShare = _rewardPerLP;
        uint256 lpSupply = _LP.balanceOf(address(this));
        if (block.number > _lastRewardBlock && lpSupply != 0) {
            uint256 cakeReward = _perBlock * (block.number - _lastRewardBlock);
            accCakePerShare = accCakePerShare.add(
                cakeReward.mul(1e12).div(lpSupply)
            );
        }
        return
            user.amount.mul(accCakePerShare).div(1e12).sub(user.rewardDebt).add(
                user.balance
            );
    }
    function getUserReward(address account) external view returns (uint256) {
        UserInfo memory user = users[account];
        uint256 accCakePerShare = _rewardPerLP;
        uint256 lpSupply = _LP.balanceOf(address(this));
        if (block.number > _lastRewardBlock && lpSupply != 0) {
            uint256 cakeReward = _perBlock * (block.number - _lastRewardBlock);
            accCakePerShare = accCakePerShare.add(
                cakeReward.mul(1e12).div(lpSupply)
            );
        }
        return
            user.amount.mul(accCakePerShare).div(1e12).sub(user.rewardDebt).add(
                user.rewardTotal
            );
    }
    function updatePool() public {
        if (block.number <= _lastRewardBlock) {
            return;
        }
        uint256 lpSupply = _LP.balanceOf(address(this));
        if (lpSupply == 0) {
            _lastRewardBlock = block.number;
            return;
        }
        uint256 cakeReward = _perBlock * (block.number - _lastRewardBlock);
        _rewardTotal = _rewardTotal.add(cakeReward);
        _rewardPerLP = _rewardPerLP.add(cakeReward.mul(1e12).div(lpSupply));
        _lastRewardBlock = block.number;
    }
    function _handleInviteReward(address account, uint256 amount) private {
        address refer = users[account].refer;
        uint256 index;
        uint8[12] memory rates = [10, 8, 6, 6, 4, 4, 3, 3, 1, 1, 0, 0];
        uint8[12] memory invites = [1, 2, 3, 3, 4, 4, 5, 5, 6, 6, 0, 0];
        while (refer != address(0) && index < 10) {
            UserInfo storage parent = users[refer];
            if (parent.invites >= invites[index]) {
                uint256 reward = (amount * rates[index]) / 100;
                parent.inviteRewardBalance += reward;
                parent.inviteRewardTotal += reward;
            }
            refer = parent.refer;
            index++;
        }
    }
}