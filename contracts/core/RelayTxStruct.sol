// SPDX-Licesne-Identifier: GPL-2.0-Only
pragma solidity 0.6.2;
pragma experimental ABIEncoderV2;

// @title Relay
// @notice Relay tx data structure
contract RelayTxStruct {
    // @dev The relay transaction
    struct RelayTx {
        address to; // Address for external contract
        address payable from; // Address for the user who hired the relayer
        bytes data; // Call data that we need to send. Includes function call name, etc.
        uint256 deadline; // Expiry block number for appointment
        uint256 compensation; // How much should the operator compensation the user by?
        uint256 gasLimit; // How much gas is allocated to this function call?
        uint256 chainId; // ChainID
        address relay; // The relay contract!
    }

    // @return Relay tx hash (bytes32)
    // @dev Pack the encoding when computing the ID.
    function computeRelayTxId(RelayTx memory self) public pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    self.to,
                    self.from,
                    self.data,
                    self.deadline,
                    self.compensation,
                    self.gasLimit,
                    self.chainId,
                    self.relay
                )
            );
    }
}
