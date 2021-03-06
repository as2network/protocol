// SPDX-Licesne-Identifier: GPL-2.0-Only
pragma solidity 0.6.2;

import "@openzeppelin/contracts/ownership/Ownable.sol";
import "../imports/Initializable.sol";

// @title Payment Deposit: Accept payments from customers or on behalf of customers
contract PaymentDeposit is Initializable, Ownable {
    mapping(address => uint256) public depositors;
    uint256 public uniqueDepositors;

    // We index the sender so that it's easy to look up all deposits
    // from a given sender.
    event Deposit(address indexed sender, uint256 amount, uint256 indexed index);

    // We index the sender so that it's easy to look up all withdraws
    // from a given sender.
    event Withdraw(address indexed sender, uint256 amount);

    // Two-step deployment process.
    function initialize(address _newOwner) internal initializer onlyOwner {
        _transferOwnership(_newOwner);
    }

    /**
     * Supply a deposit for a specified recipient.
     * Caution: The recipient must be an externally owned account as all jobs sent to
     * must be signed and associated with a positive balance in this contract.
     * see `EthSigner` for Java EOA Module
     */
    function depositFor(address recipient) public payable {
        require(msg.value > 0, "No value provided to depositFor.");
        uint256 index = getDepositorIndex(recipient);
        emit Deposit(recipient, msg.value, index);
    }

    /**
     * Sets the depositors index if necessary.
     */
    function getDepositorIndex(address _depositor) internal returns (uint256) {
        if (depositors[_depositor] == 0) {
            uniqueDepositors = uniqueDepositors + 1;
            depositors[_depositor] = uniqueDepositors;
        }

        return depositors[_depositor];
    }

    /*
     * It is only intended for external users who want to deposit via a wallet.
     */
    receive() external payable {
        require(msg.value > 0, "No value provided to fallback.");
        require(tx.origin == msg.sender, "Only EOA can deposit directly.");
        uint256 index = getDepositorIndex(msg.sender);
        emit Deposit(msg.sender, msg.value, index);
    }

    /**
     * Move funds out of the contract
     */
    function withdraw(address payable recipient, uint256 amount) public onlyOwner {
        recipient.transfer(amount);
        emit Withdraw(recipient, amount);
    }

    /**
     * Move funds out of the contract
     * Depositor is the OWNER of the funds being withdrawn.
     * Recipient is the RECEIVER of the funds.
     */
    function withdrawFor(
        address payable depositor,
        address payable recipient,
        uint256 amount
    ) public onlyOwner {
        require(depositors[depositor] > 0, "Depositor has never deposited funds.");
        recipient.transfer(amount);
        emit Withdraw(depositor, amount);
    }

    /**
     * Use admin privileges to migrate a user's deposits to another deposit contract
     */
    function migrate(
        address payable recipient,
        uint256 amount,
        PaymentDeposit otherDeposit
    ) public onlyOwner {
        require(address(this).balance >= amount, "Not enough balance to migrate.");
        otherDeposit.depositFor.value(amount)(recipient);
        emit Withdraw(recipient, amount);
    }
}
