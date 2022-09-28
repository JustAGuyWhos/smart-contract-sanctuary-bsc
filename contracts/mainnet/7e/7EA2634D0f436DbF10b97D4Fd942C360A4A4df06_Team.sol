/**
 *Submitted for verification at BscScan.com on 2022-09-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract Team {
    //中介白名单
    address private _WhiteListContract;
    modifier WhiteList {   //中介白名单
        require(_WhiteListContract == msg.sender);
        _;
    }
    //管理员
    address public _owner;
    modifier Owner {   //管理员
        require(_owner == msg.sender);
        _;
    }
    //上下级
    mapping(address => address) private _team;  

    //是否买过火箭
    mapping(address => bool) public _WhetherBoughtRocket;

    event bindingTeam(address _from,address to_);

    /**
    ** 顶级       lord_
    */
    constructor(address lord_) {
        _team[lord_] = lord_;
        _WhetherBoughtRocket[lord_] = true;
        _owner = msg.sender; //默认自己为管理员
    }
    /**
    * 修改管理员
    */
    function setOwner(address owner_) public Owner returns (bool){
        _owner = owner_;
        return true;
    }
    /**
    * 修改中介白名单
    */
    function setWhiteListContract(address WhiteListContract_) public Owner returns (bool){
        _WhiteListContract = WhiteListContract_;
        return true;
    }
    /**
    * 当前中介白名单
    */
    function WhiteListContract() public view returns (address){
        return _WhiteListContract;
    }
    //返回某人的上级
    function team(address from_) public view returns(address){
        return _team[from_];
    }
    //中介合约绑定上级
    function bindingWhite(address from_ , address to_) public WhiteList returns (bool){
        require(_WhetherBoughtRocket[to_], "Team: The superior hasn't bought any rockets");
        require(selTeam(from_,to_), "Team: Failed to bind parent-child relationship");
        _team[from_] = to_;
        _WhetherBoughtRocket[from_] = true;
        emit bindingTeam(from_,to_); 
        return true;
    }
    function selTeam(address from_,address to_) public view returns(bool){
        if(_team[to_] == address(0x00)){
            return false;
        }else{
            if(_team[to_] == to_){
                return true;
            }else{
                if(_team[to_] == from_){
                    return false;
                }else{
                    return selTeam(from_,_team[to_]);
                }
            }
        }
         
    }

 

}