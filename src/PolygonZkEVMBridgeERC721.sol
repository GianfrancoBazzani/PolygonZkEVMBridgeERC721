// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "./lib/ERC721Wrapped.sol";
import "./interfaces/IBridgeMessageReceiver.sol";

// Deterministic contract address creation using create 2;
// new_address = keccak256( 0xff ++ address ++ salt ++ keccak256(init_code))[12:]
// where salt will be, chainID
//
// Non deterministic address calculation among networks guarantees the trustless behaviour without the need of an off chain adders synch
//

contract PolygonZkEVMBridgeERC721 is IBridgeMessageReceiver{

    // chainID
    uint32  immutable public  networkID;

    // polygonZkEVMBridgeAddress contract address
    address immutable polygonZkEVMBridgeAddress;

    // Deployer account address
    address immutable deployerAddress;

    // Keccak256(init_code)
    bytes32 immutable initCodeHash;

    modifier onlyPolygonZkEVMBridge {
        require (
            msg.sender ==  polygonZkEVMBridgeAddress,
            "PolygonZkEVMBridgeERC721::onlyPolygonZkEVMBridge: only onlyPolygonZkEVMBridge"
        );
        _;
    }

    constructor(address _polygonZkEVMBridgeAddress, bytes32 _initCodeHash) {
        // Set chainID
        uint32 _chainID;
        assembly{
            _chainID := chainid()
        }
        networkID = _chainID;

        // set polygonZkEVMaddress
        polygonZkEVMBridgeAddress=_polygonZkEVMBridgeAddress;

        // Set deployer account address
        deployerAddress = msg.sender;

        // Set initCodeHash
        initCodeHash = _initCodeHash;
    }

    function bridgeERC721(
        address token,
        uint32 destinationNetwork,
        address destinationAddress,
        uint256 tokenId
    ) public {

        require(
            destinationNetwork != networkID,
            "PolygonZkEVMBridgeERC721::bridgeERC721: Destination cannot be itself"
        );

        // TODO

        // If token, lock and bridge

        // If representer, burn  and bridge

        



    }


    function _claimERC721() internal onlyPolygonZkEVMBridge{
        //TODO

        // If token, unlock

        // If representer
            // If contract non deployed, deploy and mint

            // If contract deployed, mint
    }


    function onMessageReceived(
        address originAddress,
        uint32 originNetwork,
        bytes memory data
    ) external view returns (bool){
        //TODO check that origin Address maches with the deterministic creation
        //new_address = hash(0xFF, deployerAddress, salt = originNetwork, bytecode)
    }
}
