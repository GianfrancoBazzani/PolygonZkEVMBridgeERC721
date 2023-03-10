// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/lib/ERC721Wrapped.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";


contract ERC721WrappedTest is Test{
    
    ERC721Wrapped public tokenContract;

    // Test dummy ERC721
    string public name = "TestNFT";
    string public symbol = "TEST";
    uint32 originNetwork = 0;
    address originTokenAddress = 0x5fAaba1393b5AA5dB9bF23Aa48d2D77429F70B77;
    uint256 public constant tokenId = 56738;

    // Dummy addresses
    address public constant PolygonZkEVMBridgeERC721 = 0xaA3dC168Ff239017C85BdD9473a20bA2092e984f; // Dummy address for testing purposes
    address public constant receiverAddress = 0x50Fc27c707c0f83447939532A8d9218417a21321; // Token receiver address
    
    
    // Events
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);



    function setUp() public {
        // Compute salt for create 2
        bytes32 tokenInfoHash = keccak256(
            abi.encodePacked(originNetwork, originTokenAddress)
        );

        // Deploy an ERC721Wrapped.sol instance by PolygonZkEVMBridgeERC721 address using create2
        vm.prank(PolygonZkEVMBridgeERC721);
        tokenContract = (new ERC721Wrapped){
            salt: tokenInfoHash
        }(name,symbol);

        // Expect transfer event emmision
        vm.expectEmit(true, true, true, false);
        emit Transfer(address(0),receiverAddress,tokenId);

        // Mint token
        vm.prank(PolygonZkEVMBridgeERC721);
        tokenContract.mint(receiverAddress, tokenId);
    }

    function testMintToken() public { // Should mint token  ro reciver address and emit Tansfer event to reciver address

        // Expect transfer event emmision
        vm.expectEmit(true, true, true, false);
        emit Transfer(address(0),receiverAddress,tokenId + 1);

        // Mint token
        vm.prank(PolygonZkEVMBridgeERC721);
        tokenContract.mint(receiverAddress, tokenId + 1); 
    }

    function testFailMintTokenNoOwner() public { // Should fail if minter is not ERC721 bridging interface address
        // Try mint token
        tokenContract.mint(receiverAddress, tokenId + 1);
    }

    function testBurnToken() public { // Should bun token from sender address and emit Transfer event to 0 address
        // Expect transfer event emmision
        vm.expectEmit(true, true, true, false);
        emit Transfer(receiverAddress,address(0),tokenId);

        // Burn token
        vm.prank(PolygonZkEVMBridgeERC721);
        tokenContract.burn(tokenId);
    }

    function testFailBurnTokenNoOwner() public {  // Should fail if burner is not ERC721 bridging interface address
        // Try Burn token
        tokenContract.burn(tokenId);
    }

    function testFailRedeployment() public{ // Should fail always since the contract address is already deployed (The behaviour at collisions is specified by EIP-684)
        // Compute salt for create 2
        bytes32 tokenInfoHash = keccak256(
            abi.encodePacked(originNetwork, originTokenAddress)
        );

        // Deploy an ERC721Wrapped.sol instance by PolygonZkEVMBridgeERC721 address using create2
        vm.prank(PolygonZkEVMBridgeERC721);
        tokenContract = (new ERC721Wrapped){
            salt: tokenInfoHash
        }(name,symbol);
    }
}
