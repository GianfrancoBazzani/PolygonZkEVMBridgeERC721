// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "./lib/ERC721Wrapped.sol";
import "./interfaces/IBridgeMessageReceiver.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "./interfaces/IPolygonZkEVMBridge.sol";

//TEST
contract PolygonZkEVMBridgeERC721 is IBridgeMessageReceiver{

    //** IMMUTABLES **//

    // chainID
    uint32  immutable public  networkID;

    // polygonZkEVMBridgeAddress contract address
    address immutable polygonZkEVMBridgeAddress;

    // Deployer account address
    address immutable deployerAddress;

    // Keccak256(init_code)
    bytes32 immutable initCodeHash;


    //** MAPPINGS **//

    // Representative tokens contracts
    
    // Wrapped token Address --> Origin token information
    mapping(address => TokenInformation) public ERC721wrappedTokenAddressToTokenInfo;

    // keccak256(OriginNetwork || tokenAddress) --> Wrapped token address
    mapping(bytes32 => address) public tokenInfoToERC721WrappedToken;

    //** STRUCTS **//

    // Wrapped Token information struct
    struct TokenInformation {
        uint32 originNetwork;
        address originTokenAddress;
    }

    //** EVENTS **//

    event BridgeERC721Event(
        uint32    originNetwork,
        address   originTokenAddress,
        string    name,
        string    symbol,
        uint256   tokenId,
        uint32    destinationNetwork,
        address   destinationAddress
    );

    event ClaimERC721Event(
        uint32    originNetwork,
        address   originTokenAddress,
        string    name,
        string    symbol,
        uint256   tokenId,
        uint32    destinationNetwork,
        address   destinationAddress
    );

    //** MODIFIERS **//

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
        address tokenAddress,
        uint32 destinationNetwork,
        address destinationAddress,
        uint256 tokenId
    ) public {

        // init token properties
        uint32 originNetwork;
        address originTokenAddress;
        string memory name;
        string memory symbol;

        // Retireve tokenInformation
        TokenInformation memory tokenInformation = ERC721wrappedTokenAddressToTokenInfo[tokenAddress];

        if(tokenInformation.originTokenAddress != address(0)){
            // Is a Token representer form another network
        
            // Burn the token representer       
            ERC721Wrapped(tokenAddress).burn(tokenId);

            // set token properties
            originNetwork = tokenInformation.originNetwork;
            originTokenAddress = tokenInformation.originTokenAddress;
            name = ERC721Wrapped(tokenAddress).name();
            symbol = ERC721Wrapped(tokenAddress).symbol();

        } else {
            // Is a Token original from this network

            // Lock the token
            IERC721(tokenAddress).transferFrom(msg.sender, address(this) , tokenId);

            // set token properties
            originNetwork = networkID;
            originTokenAddress = tokenAddress;
            name = ERC721(tokenAddress).name();
            symbol = ERC721(tokenAddress).symbol();
        }

        
        // compute address of PolygonZkEVMBridgeERC721 in destination network
        bytes32 digest = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                bytes20(deployerAddress),
                bytes32(uint256(destinationNetwork)), /// PADD ZEROES
                initCodeHash
            )
        );
        address destinationPolygonZkEVMBridgeERC721Address = address(bytes20(digest<<96));

        // Encode msg payload 
        bytes memory metadata = abi.encodePacked(
            originNetwork,
            originTokenAddress,
            name,
            symbol,
            tokenId,
            destinationAddress
        );
        

        // bridge bridge message 
        IPolygonZkEVMBridge(polygonZkEVMBridgeAddress).bridgeMessage(destinationNetwork, destinationPolygonZkEVMBridgeERC721Address , metadata);

        // emit BridgeERC721Event
        emit BridgeERC721Event(
            originNetwork,
            originTokenAddress,
            name,
            symbol,
            tokenId,
            destinationNetwork,
            destinationAddress
        );

    }


    function _claimERC721(bytes memory data) internal onlyPolygonZkEVMBridge{

        // Init token properties
        uint32 originNetwork;
        address originTokenAddress;
        string memory name;
        string memory symbol;
        uint256 tokenId;
        address destinationAddress;

        // Decode message payload
        (
            originNetwork,
            originTokenAddress,
            name,
            symbol,
            tokenId,
            destinationAddress
        ) = abi.decode(data,(
            uint32,
            address,
            string,
            string,
            uint256,
            address
        ));            

        if(originNetwork == networkID) {
            // Is a Token original from this network

            // Unlock the token
            IERC721(originTokenAddress).transferFrom(address(this), destinationAddress , tokenId);
        } else {
            // Is a Token representer form another network

            // Compute salt for create 2
            bytes32 tokenInfoHash = keccak256(
                abi.encodePacked(originNetwork, originTokenAddress)
            );

            // Check if address is in tokenInfoToERC721WrappedToken mapping
            address ERC721WrappedTokenAddress = tokenInfoToERC721WrappedToken[tokenInfoHash];

            if(ERC721WrappedTokenAddress == address(0)){
                // No Token representer deployed

                // Deploy Token representer contract
                ERC721Wrapped tokenContract = (new ERC721Wrapped){
                    salt: tokenInfoHash
                }(name,symbol);

                // Mint Token to destinationAddress
                tokenContract.mint(destinationAddress, tokenId);

                // Fill mappings
                ERC721wrappedTokenAddressToTokenInfo[address(tokenContract)] = TokenInformation(
                    originNetwork,
                    originTokenAddress
                );

                tokenInfoToERC721WrappedToken[tokenInfoHash] = address(tokenContract);

            } else {
                // Token representer already deployed

                // Mint Token to destinationAddress
                ERC721Wrapped(ERC721WrappedTokenAddress).mint(destinationAddress, tokenId);
            }
        }

       // emit BridgeERC721Event
        emit ClaimERC721Event(
            originNetwork,
            originTokenAddress,
            name,
            symbol,
            tokenId,
            networkID,
            destinationAddress
        );
    }


    function onMessageReceived(
        address originAddress,
        uint32 originNetwork,
        bytes memory data
    ) external view returns (bool){

        // Compute deterministic origin address
        bytes32 digest = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                bytes20(deployerAddress),
                bytes32(uint256(originNetwork)),
                initCodeHash
            )
        );
        address deterministicAddress = address(bytes20(digest<<96));
 
        require(
            originAddress == deterministicAddress,
            "PolygonZkEVMBridgeERC721::onMessageReceived: originAddress must be deterministical"
        );

        _claimERC721(data); //TO FIX ?????
    }
}
