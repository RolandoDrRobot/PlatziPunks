// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// References
// https://docs.openzeppelin.com/contracts/4.x/api/token/erc721#ERC721
// https://docs.openzeppelin.com/contracts/4.x/api/token/erc721#ERC721Enumerable
// https://docs.openzeppelin.com/contracts/4.x/api/utils#Counters
// https://docs.opensea.io/docs/metadata-standards

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// ERC721Enumerable Expland the posibilities of the 721
// We need It because It has a function that let us know which NFTs an address has
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
// We need to ise these functions to handle counters
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Base64.sol";
// We will have this logic in other contract
import "./PlatziPunksDNA.sol";

contract PlatziPunks is ERC721, ERC721Enumerable, PlatziPunksDNA {
    // State variable
    using Counters for Counters.Counter;
    // The we set the counter variable as private
    Counters.Counter private _idCounter;

    // We pass It as a parameter so we do not hardcode the value when It is first created
    uint256 public maxSupply;

    // Here we are going to map the token ID with the ADN
    mapping(uint256 => uint256) public tokenDNA;

    constructor(uint256 _maxSupply) ERC721("PlatziPunks", "PLPKSR") {
        maxSupply = _maxSupply;
    }

    // _safeMint already comes with 721 BUT It is a private function, so we create this mint function as a security layer
    // The challange here!!! is to make this mint payable papiii 
    function mint() public {
        // .current() comes in Counter
        uint256 current = _idCounter.current();
        // Then validate the maxSupply so we no create more of what is expected
        require(current < maxSupply, "No PlatziPunks left :(");
        tokenDNA[current] = deterministicPseudoRandomDNA(current, msg.sender);
        // First param, the person who is going to receive the NFT
        // Second param, the new token ID for the NFT
        _safeMint(msg.sender, current);
    }

    function _baseURI() internal pure override returns (string memory) {
      return "https://avataaars.io/";
    }

    function _paramsURI(uint256 _dna) internal view returns (string memory) {
      string memory params;
      {
        params = string(
          abi.encodePacked(
            "accessoriesType=",
            getAccesoriesType(_dna),
            "&clotheColor=",
            getClotheColor(_dna),
            "&clotheType=",
            getClotheType(_dna),
            "&eyeType=",
            getEyeType(_dna),
            "&eyebrowType=",
            getEyeBrowType(_dna),
            "&facialHairColor=",
            getFacialHairColor(_dna),
            "&facialHairType=",
            getFacialHairType(_dna),
            "&hairColor=",
            getHairColor(_dna),
            "&hatColor=",
            getHatColor(_dna),
            "&graphicType=",
            getGraphicType(_dna),
            "&mouthType=",
            getMouthType(_dna),
            "&skinColor=",
            getSkinColor(_dna)
          )
        );
      }

      return string(abi.encodePacked(params, "&topType=", getTopType(_dna)));
    }

    function imageByDNA(uint256 _dna) public view returns (string memory) {
      string memory baseURI = _baseURI();
      string memory paramsURI = _paramsURI(_dna);

      return string(abi.encodePacked(baseURI, "?", paramsURI));
    }


    // This allow us to fetch the metadata based in the tokenid
    // It returns the string, in memory because It is only read
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
      // We need to first double check If the token exists with the included function
      require(_exists(tokenId), "ERC721 Metadata: URI query for nonexisting token");

      uint256 dna = tokenDNA[tokenId];
      string memory image = imageByDNA(dna);

      // https://docs.opensea.io/docs/metadata-standards here we have the desired values for Open Sea
      string memory jsonURI = Base64.encode(
        abi.encodePacked(
          '{ "name": "PlatziPunks #',
          tokenId,
          '", "description": "Platzi Punks are randomized Avataaars stored on chain to teach DApp development on Platzi", "image": "',
          image,
          '"}'
        )
      );

      // Here we concatenate with the internet standard
      // string(...) parse to string
      return string(abi.encodePacked("data:application/json;base64,", jsonURI));
    }


    // These are override functions that Enumerable needs
    function _beforeTokenTransfer(
      address from,
      address to,
      uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
      super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
      public
      view
      override(ERC721, ERC721Enumerable)
      returns (bool)
    {
      return super.supportsInterface(interfaceId);
    }
}
