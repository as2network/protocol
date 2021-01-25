# AS2/EDINT Protocol 

> B2B Meta Transaction Messagebus system 


## Meta Transaction Relay

> Example of encoding 
```solidity
keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
````
```solidity
bytes32 constant internal _EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;
```

### ERC-712

In vanilla ERC-20 token contracts, owners may only register approvals by
directly calling a function which uses msg.sender to permission itself. With
meta-approvals, ownership and permissioning are derived from a signature passed
into the function by the caller (sometimes referred to as the relayer).

#### Domain Separator
```ts
keccak256(
  abi.encode(
    keccak256('EIP712Domain(string name,string version,uint256 chainId,address
verifyingContract)'),
    keccak256(bytes(name)),
    keccak256(bytes('1')),
    chainId,
    address(this)
  )
);
```

- name is always Uniswap V2, see name.
- chainId is determined from the ERC-1344 chainid opcode.
- address(this) is the address of the pair, see Pair Addresses.
- Permit Typehash
- keccak256('Permit(address owner,address spender,uint256 value,uint256
= nonce,uint256 deadline)');`

#### Solidity function for encoding array (v4 schema)

```solidity
function hash(string[] calldata array) internal pure returns (bytes32 result) {
    bytes32[] memory _array = new bytes32[](array.length);
    for (uint256 i = 0; i < array.length; ++i) {
        _array[i] = keccak256(bytes(array[i]));
    }
    result = keccak256(abi.encodePacked(_array));
}
````

## Developer Tools 🛠️

- [Truffle](https://trufflesuite.com/)
- [TypeChain](https://github.com/ethereum-ts/TypeChain)
- [Openzeppelin Contracts](https://openzeppelin.com/contracts/)

### Start

Create `.infura` and `.secret` files. Install the dependencies:

```bash
$ yarn
```

### Tests

```bash
$ yarn test
```

### Coverage

```bash
$ yarn coverage
```

## License

GPL-2.0-Only
