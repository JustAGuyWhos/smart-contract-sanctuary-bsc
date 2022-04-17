/**
 *Submitted for verification at BscScan.com on 2022-04-16
*/

/**
 *Submitted for verification at Etherscan.io on 2022-01-28
 */

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract AdminPool {
    uint256 poolsCount;
    address public admin;
    uint256 public adminContribution;
    uint256 constant day1 = 86400;
    uint256 constant day2 = 172800;
    uint256 constant day3 = 259200;

    enum POOL_STATE {
        OPEN,
        CLOSED
    }

    mapping(uint256 => User) public user;
    struct User {
        address _address;
        uint256 score;
        bool isClaimed;
    }

    mapping(uint256 => Pool) public pools;
    struct Pool {
        User[] users;
        uint256 pool_id;
        uint256 totalScore;
        POOL_STATE poolState;
        uint256 createTime;
        uint256 totalUsers;
    }

    constructor() {
        admin = msg.sender;
    }

    receive() external payable {
        //require(poolState == POOL_STATE.OPEN);
    }

    function adminWithdraw() public {
        require(msg.sender == admin, "Only admin can withdraw");
        payable(admin).transfer(getBalance());
    }

    function startPool(uint256 pool_id) public payable {
        require(msg.sender == admin, "Only admin can start the pool");
        require(
            msg.value > 0,
            "Please contribute desired amount to start pool"
        );
        bool isFound = false;
        for (uint256 i = 0; i < poolsCount; i++) {
            if (pools[i].pool_id == pool_id) {
                isFound = true;
            }
        }
        if (!isFound) {
            adminContribution += msg.value;
            pools[poolsCount].pool_id = pool_id;
            pools[poolsCount].poolState = POOL_STATE.OPEN;
            pools[poolsCount].totalScore = 0;
            poolsCount++;
        } else {
            // revert("Pool is already started");
        }
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function addScore(User[] calldata scoreData, uint256 pool_id)
        public
        returns (bool)
    {
        require(msg.sender == admin, "Only admin can add score");
        for (uint256 i = 0; i < poolsCount; i++) {
            if (
                pool_id == pools[i].pool_id &&
                pools[i].poolState == POOL_STATE.OPEN
            ) {
                for (uint256 index = 0; index < scoreData.length; index++) {
                    pools[i].totalScore =
                        pools[i].totalScore +
                        scoreData[index].score;
                    pools[i].users.push(User({
                        _address: scoreData[index]._address,
                        score: scoreData[index].score,
                        isClaimed: false
                    }));
                    pools[i].totalUsers = pools[i].totalUsers + 1;
                }
                pools[i].poolState = POOL_STATE.CLOSED;
                pools[i].createTime = block.timestamp;
            }
        }
        return true;
    }

    function claimReward(uint256 pool_id) public {
        for (uint256 poolCount = 0; poolCount < poolsCount; poolCount++) {
            if (
                pool_id == pools[poolCount].pool_id &&
                pools[poolCount].poolState == POOL_STATE.CLOSED
            ) {
                for (uint256 userCount = 0;
                    userCount < pools[poolCount].totalUsers;
                    userCount++) {
                    if (msg.sender == pools[poolCount].users[userCount]._address) {
                        if (
                            pools[poolCount].users[userCount].isClaimed == false
                        ) {
                            if (
                                block.timestamp - pools[poolCount].createTime < day1
                            ) {
                                payable(msg.sender).transfer(
                                    (getBalance() *
                                        (pools[poolCount].users[userCount].score /
                                            pools[poolCount].totalScore) *
                                        70) / 100
                                );
                                pools[poolCount].users[userCount].isClaimed = true;
                            } else if (
                                block.timestamp - pools[poolCount].createTime >
                                day1 &&
                                block.timestamp - pools[poolCount].createTime < day2
                            ) {
                                payable(msg.sender).transfer(
                                    (getBalance() *
                                        (pools[poolCount].users[userCount].score /
                                            pools[poolCount].totalScore) *
                                        80) / 100
                                );
                                pools[poolCount].users[userCount].isClaimed = true;
                            } else if (
                                block.timestamp - pools[poolCount].createTime >
                                day1 &&
                                block.timestamp - pools[poolCount].createTime >
                                day2 &&
                                block.timestamp - pools[poolCount].createTime < day3
                            ) {
                                payable(msg.sender).transfer(
                                    (getBalance() *
                                        (pools[poolCount].users[userCount].score /
                                            pools[poolCount].totalScore) *
                                        90) / 100
                                );
                                pools[poolCount].users[userCount].isClaimed = true;
                            } else {
                                payable(msg.sender).transfer(
                                    (getBalance() *
                                        (pools[poolCount].users[userCount].score /
                                            pools[poolCount].totalScore) *
                                        95) / 100
                                );
                                pools[poolCount].users[userCount].isClaimed = true;
                            }
                        }
                    }
                }
            }
        }
    }

    function claimAllReward() public {
        uint256 totalClaim = 0;
        for (uint256 poolCount = 0; poolCount < poolsCount; poolCount++) {
            if (pools[poolCount].poolState == POOL_STATE.CLOSED) {
                uint256 _totalUsers = pools[poolCount].totalUsers;
                for (
                    uint256 userCount = 0;
                    userCount < _totalUsers;
                    userCount
                ) {
                    if (
                        msg.sender == pools[poolCount].users[userCount]._address
                    ) {
                        totalClaim +=
                                    (getBalance() *
                                        (pools[poolCount]
                                            .users[userCount]
                                            .score /
                                            pools[poolCount].totalScore) *
                                        70) /
                                    100;
                        /*
                        if (
                          pools[poolCount].users[userCount].isClaimed == false
                        ) {
                            if (
                                block.timestamp - pools[poolCount].createTime <
                                day1
                            ) {
                                totalClaim +=
                                    (getBalance() *
                                        (pools[poolCount]
                                            .users[userCount]
                                            .score /
                                            pools[poolCount].totalScore) *
                                        70) /
                                    100;
                            } else if (
                                block.timestamp - pools[poolCount].createTime >
                                day1 &&
                                block.timestamp - pools[poolCount].createTime <
                                day2
                            ) {
                                totalClaim +=
                                    (getBalance() *
                                        (pools[poolCount]
                                            .users[userCount]
                                            .score /
                                            pools[poolCount].totalScore) *
                                        80) /
                                    100;
                            } else if (
                                block.timestamp - pools[poolCount].createTime >
                                day1 &&
                                block.timestamp - pools[poolCount].createTime >
                                day2 &&
                                block.timestamp - pools[poolCount].createTime <
                                day3
                            ) {
                                totalClaim +=
                                    (getBalance() *
                                        (pools[poolCount]
                                            .users[userCount]
                                            .score /
                                            pools[poolCount].totalScore) *
                                        90) /
                                    100;
                            } else {
                                totalClaim +=
                                    (getBalance() *
                                        (pools[poolCount]
                                            .users[userCount]
                                            .score /
                                            pools[poolCount].totalScore) *
                                        95) /
                                    100;
                            }
                            
                        }*/
                    }
                }
            }
        }
        if (totalClaim > 0) {
            payable(msg.sender).transfer(totalClaim);
            for (uint256 poolCount = 0; poolCount < poolsCount; poolCount++) {
                if (pools[poolCount].poolState == POOL_STATE.CLOSED) {
                    for (
                        uint256 userCount = 0;
                        userCount < pools[poolCount].totalUsers;
                        userCount++
                    ) {
                        if (
                            msg.sender ==
                            pools[poolCount].users[userCount]._address
                        ) {
                            if (
                                pools[poolCount].users[userCount].isClaimed ==
                                false
                            ) {
                                pools[poolCount]
                                    .users[userCount]
                                    .isClaimed = true;
                            }
                        }
                    }
                }
            }
        }
    }
}