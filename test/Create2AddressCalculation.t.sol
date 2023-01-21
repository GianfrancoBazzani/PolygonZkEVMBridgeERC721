// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

// EIP-1014: Skinny CREATE2 
// Deterministic contract address creation using create 2;
// new_address = keccak256( 0xff ++ address ++ salt ++ keccak256(init_code))[12:]

// examples from https://eips.ethereum.org/EIPS/eip-1014

contract Create2AddressCalculationTest is Test{

    function setUp() public {
    }

    function testExampleN0() public{
        
        address _address = 0x0000000000000000000000000000000000000000;
        uint256 salt = 0x0000000000000000000000000000000000000000000000000000000000000000;
        bytes memory init_code = abi.encodePacked(bytes1(0x00));
        address result = 0x4D1A2e2bB4F88F0250f26Ffff098B0b30B26BF38;


        bytes32 digest = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                bytes20(_address),
                bytes32(salt),
                keccak256(init_code)
            )
        );

        
        address newAddress = address(bytes20(digest<<96));
        console.logAddress(newAddress);

        assertEq(result, newAddress);
    }
}
