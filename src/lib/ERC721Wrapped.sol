// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";


contract ERC721Wrapped is ERC721 {

    // ERC721 bridging interface address
    address bridgingInterfaceAddress;

    modifier onlyBridgingInterface() {
        require(
            msg.sender == bridgingInterfaceAddress,
            "ERC721Wrapped::onlyBridgingInterface: not deployer bridging interface "    
        );
        _;
    }

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        bridgingInterfaceAddress = msg.sender;
    }

    function mint(address to, uint256 tokenId) external onlyBridgingInterface {
        _mint(to,tokenId);
    }

    function burn(uint256 tokenId) external onlyBridgingInterface{
        _burn(tokenId);
    }
}