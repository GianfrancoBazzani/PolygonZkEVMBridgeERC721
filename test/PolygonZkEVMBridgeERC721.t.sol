// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

contract PolygonZkEVMBridgeERC721Test is Test{

    // Dummy addresses
    address public constant PolygonZkEVMBridge = 0xaA3dC168Ff239017C85BdD9473a20bA2092e984f; // PolygonZkEVMBridge Address
    address public constant deployerAddress = 0x49e4E68c4b399D79106e2b2B6fF8C3E1f7727C7C; // PolygonZkEVMBridgeERC721 deplyer address

    address public constant receiverAddress = 0x50Fc27c707c0f83447939532A8d9218417a21321; // Token receiver address
    address public constant senderAddress = 0xc2Cf915e00d0ff4CE6b403ede2Aa4FdcB63A0D2f; // Token sender address

    bytes32 initCodeHash = "TO BE SET"; // Hash of PolygonZkEVMBridgeERC721 deployment bytecode

    // chainIDs
    uint32 chain1 = 0;
    uint32 chain2 = 1;
    
    function setUp() public {
        // Deploy instance of Bridge contract in both networks use cheat code  // vm.chainId(uint256)? use creat2
        // Deploy Sample ERC721 in both networks
    }

    function testShouldBridgeFromOrigin() public { // Should bridge token (form origin, lock & bridge)

        // assert that new owner of tokenid is contract
        // assert that bridgeMessage is called well (build a mock reveiver)
        // assert that BridgeERC721Event is emmited well
    }

    function testShouldBridgeToOrigin() public { // Should bridge token (to origin, burn & bridge)
    
        // assert that token is burned
        // assert that bridgeMessage is called well (build a mock reveiver)
        // assert that BridgeERC721Event is emmited well
    }

    function testShouldClaimFromOrigin() public { // Should claim token (from origin, claim & [deploy &] mint)
        
        // assert that token contract is deployed
        // assert that token is minted to address
        // assert that if token contract is deployed directly mints to address
        // assert that ClaimERC721Event is emmited well
    }

    function testShouldClaimToOrigin() public { // Should claim token (To origin, claim & unlock )
        
        // assert that new token owner is destination address
        // assert that ClaimERC721Event is emmited well
    }
}
