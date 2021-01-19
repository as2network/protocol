// SPDX-Licesne-Identifier: GPL-2.0-Only
pragma solidity 0.6.2;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/ownership/Ownable.sol";
import "./ILockable.sol";
import "../imports/Initializable.sol";

// @title Lockable Deposit
// @notice Handles the collateral security deposit and withdrawal process. This deposit will be locked
// - cannot be withdrawn - if the any lockable dependencies (adjudicators) transition into a locked state.
contract LockableDeposit is ILockable, Initializable, Ownable {
    ILockable[] public lockables;
    uint256 public withdrawalPeriod;
    bool public withdrawalInitiated;
    uint256 public withdrawalBlock;

    event RequestWithdraw();
    event CompleteWithdraw();
    event LockableAdded(address lockable);

    // @param _newOwner Authorised user to request and perform withdrawal of security deposit. (Optional: It can be a smart contract)
    // @param _withdrawalPeriod Minimum length of time the security deposit is locked into this contract.
    function initialize(address payable _newOwner, uint256 _withdrawalPeriod) public initializer onlyOwner {
        _transferOwnership(_newOwner);
        withdrawalPeriod = _withdrawalPeriod;
    }

    /**
     * Add a lockable to this deposit. The deposit becomes locked if any of the lockables is
     * locked.
     */
    function addLockable(ILockable lockable) public onlyOwner {
        for (uint256 i = 0; i < lockables.length; i++) {
            require(lockables[i] != lockable, "Lockable already added to deposit.");
        }

        require(!lockable.isLocked(), "Cannot add already locked lockable.");

        lockables.push(lockable);
        emit LockableAdded(address(lockable));
    }

    /**
     * Returns true if all dependent lockables are unlocked, false otherwise.
     */
    function isLocked() public view override returns (bool) {
        for (uint256 i = 0; i < lockables.length; i++) {
            if (lockables[i].isLocked()) return true;
        }
        return false;
    }

    // @dev Owner can request the security deposit to be withdrawn. Kick-starts the withdraw timer.
    function requestWithdrawal() public onlyOwner {
        withdrawalInitiated = true;
        withdrawalBlock = block.number + withdrawalPeriod;
        emit RequestWithdraw();
    }

    // @dev Owner can withdraw coins once the withdrawal timer has expired.
    function withdraw() public onlyOwner {
        require(withdrawalInitiated, "Withdrawal is not initiated.");
        require(block.number > withdrawalBlock, "Withdrawal block has not been reached.");
        require(!isLocked(), "Deposit is locked.");

        withdrawalInitiated = false;
        withdrawalBlock = 0;

        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
        emit CompleteWithdraw();
    }

    // @dev Security deposit can be topped up.
    receive() external payable {}
}
