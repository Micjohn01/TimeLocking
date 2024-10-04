// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract TimeLock {
    struct Lock {
        uint256 amount;
        uint256 releaseTime;
    }

    mapping(address => Lock[]) public locks;

    event Locked(address indexed user, uint256 amount, uint256 releaseTime);
    event Released(address indexed user, uint256 amount);

    function lock(uint256 _duration) public payable {
        require(msg.value > 0, "Must lock some amount");
        uint256 releaseTime = block.timestamp + _duration;
        locks[msg.sender].push(Lock(msg.value, releaseTime));
        emit Locked(msg.sender, msg.value, releaseTime);
    }

    function release(uint256 _index) public {
        Lock[] storage userLocks = locks[msg.sender];
        require(_index < userLocks.length, "Invalid lock index");
        Lock storage userLock = userLocks[_index];
        require(block.timestamp >= userLock.releaseTime, "Funds are still locked");
        uint256 amount = userLock.amount;
        
        // Remove the lock by swapping with the last element and popping
        userLocks[_index] = userLocks[userLocks.length - 1];
        userLocks.pop();
        
        payable(msg.sender).transfer(amount);
        emit Released(msg.sender, amount);
    }

    function getLocks(address _user) public view returns (uint256[] memory amounts, uint256[] memory releaseTimes) {
        Lock[] storage userLocks = locks[_user];
        amounts = new uint256[](userLocks.length);
        releaseTimes = new uint256[](userLocks.length);
        for (uint256 i = 0; i < userLocks.length; i++) {
            amounts[i] = userLocks[i].amount;
            releaseTimes[i] = userLocks[i].releaseTime;
        }
    }
}