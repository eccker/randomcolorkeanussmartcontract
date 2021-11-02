//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";


import "base64-sol/base64.sol";

import "hardhat/console.sol";

contract NFT is ERC721URIStorage, VRFConsumerBase, Ownable  {
    address contractAddress;

    uint256 public tokenCounter;

    bytes32 public keyHash;
    uint256 public fee;
    uint256 public priceForMinting;

    string[] public bases;
    string[] public personalities;
    uint256 public breathtakingPowerMax;
    
    
    mapping(bytes32 => address) public requestIdToSender;
    mapping(bytes32 => uint256) public requestIdToTokenId;
    mapping(uint256 => uint256) public tokenIdToRandomNumber;
    mapping(uint256 => bytes32) public tokenIdToRequestId;

    mapping(address => uint256) public senderToTokenId;
 
    event CreatedUnfinishedRandomSVG(uint256 indexed tokenId, uint256 random);
    event CreatedRandomSVG(uint256 indexed tokenId);
    event requestedRandomSVG(uint256 indexed tokenId);

    constructor(address _VRFCoordinator, address _LinkToken, bytes32 _keyHash, uint256 _fee )  VRFConsumerBase(
            _VRFCoordinator, 
            _LinkToken
        )
        ERC721("alfa Random Color Keanus", "alfaRCKS")
    {
        tokenCounter = 0;
        keyHash = _keyHash;
        fee = _fee;
        priceForMinting =  0.00618 ether;  
        bases = ["John", "John", "Kevin", "Lucas", "Kevin", "Lucas","Kevin", "Lucas", "Kevin", "Lucas", "Jack", "Kevin", "Lucas", "Kevin", "Lucas", "Kevin", "Lucas", "Lucas", "Will", "Will","Kevin", "Lucas", "Kevin", "Lucas", "Kevin", "Lucas", "Lucas", "Kevin", "Kevin", "Kevin","John", "John", "Kevin", "Lucas", "Kevin", "Lucas","Kevin", "Lucas", "Kevin", "Lucas", "Jack", "Jack", "Kevin", "Lucas", "Kevin", "Lucas", "Kevin", "Lucas", "Lucas", "Will", "Will","Kevin", "Lucas", "Kevin", "Lucas", "Kevin", "Kevin", "Kevin", "Kevin","John", "John", "Kevin", "Lucas", "Kevin", "Lucas","Kevin", "Lucas", "Kevin", "Lucas", "Jack", "Jack", "Kevin", "Lucas", "Kevin", "Lucas", "Kevin", "Lucas", "Lucas", "Will", "Will","Kevin", "Lucas", "Kevin", "Lucas", "Kevin", "Lucas", "Lucas", "Kevin", "Kevin", "Kevin","John", "John", "Kevin", "Lucas", "Kevin", "Lucas","Kevin", "Lucas", "Kevin", "Lucas", "Jack", "Kevin", "Lucas", "Kevin", "Lucas", "Kevin", "Lucas", "Lucas", "Will", "Will","Kevin", "Lucas", "Kevin", "Lucas", "Kevin", "Lucas", "Lucas", "Kevin", "Kevin","John", "John", "Kevin", "Lucas", "Kevin", "Lucas","Kevin", "Lucas", "Kevin", "Lucas", "Jack", "Kevin", "Lucas", "Kevin", "Lucas", "Kevin", "Lucas", "Lucas", "Will", "Will","Kevin", "Lucas", "Kevin", "Lucas", "Kevin", "Lucas", "Lucas", "Kevin", "Kevin", "Kevin","John", "John", "Kevin", "Lucas", "Kevin", "Lucas","Kevin", "Lucas", "Kevin", "Lucas", "Jack", "Jack", "Kevin", "Lucas", "Kevin", "Lucas", "Kevin", "Lucas", "Lucas", "Will", "Will","Kevin", "Lucas", "Kevin", "Lucas", "Kevin", "Kevin", "Kevin", "Kevin","John", "John", "Kevin", "Lucas", "Kevin", "Lucas","Kevin", "Lucas", "Kevin", "Lucas", "Jack", "Jack", "Kevin", "Lucas", "Kevin", "Lucas", "Kevin", "Lucas", "Lucas", "Will", "Will","Kevin", "Lucas", "Kevin", "Lucas", "Kevin", "Lucas", "Lucas", "Kevin", "Kevin", "Kevin","John", "John", "Kevin", "Lucas", "Kevin", "Lucas","Kevin", "Lucas", "Kevin", "Lucas", "Jack", "Kevin", "Lucas", "Kevin", "Lucas", "Kevin", "Lucas", "Lucas", "Will", "Will","Kevin", "Lucas", "Kevin", "Lucas", "Kevin", "Lucas", "Lucas", "Kevin", "Neo", "Kevin", "Kevin"];

        personalities = ["fun","kind","mysterious","private", "respectul", "loyal", "intelligent","fun","kind","mysterious", "respectul", "loyal", "intelligent","fun","kind","mysterious", "respectul", "loyal", "intelligent","fun","kind","mysterious", "respectul", "loyal", "intelligent","fun","kind","mysterious", "respectul", "loyal", "intelligent","fun","kind","mysterious", "respectul", "loyal", "intelligent"];
        breathtakingPowerMax = 100;
        
    }

    function withdraw() public payable onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function setMintPrice(uint256 _mintPrice) internal {
        priceForMinting =  _mintPrice;
    }

    function getMintPrice() public view returns (uint256){
        return priceForMinting;
    }

    function create() public payable returns (uint256){
        // TODO decode params to modify ayekilua
        require(msg.value >= priceForMinting, "Need to send enough coins");
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK in the contract address to process randomness requests.");
        bytes32 requestId = requestRandomness(keyHash, fee);
        requestIdToSender[requestId] = msg.sender;
        requestIdToTokenId[requestId] = tokenCounter;
        // senderToTokenId[msg.sender] = tokenCounter;
        uint256 tokenId = tokenCounter;
        tokenIdToRequestId[tokenCounter] = requestId;
        tokenCounter = tokenCounter + 1;
        setMintPrice((getMintPrice() * 1001618)/1000000);
        emit requestedRandomSVG(tokenId);
        return tokenId;
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 _requestId, uint256 randomness) internal override {
        _safeMint(requestIdToSender[_requestId], requestIdToTokenId[_requestId]);
        tokenIdToRandomNumber[requestIdToTokenId[_requestId]] = randomness;
        emit CreatedUnfinishedRandomSVG(requestIdToTokenId[_requestId], randomness);
    }

    function finishMint(uint256 tokenId, string memory _svg, string memory _svgname, string memory _description) public returns (uint256 ){
        // uint256 tokenId = senderToTokenId[msg.sender];
        bytes32 requestId = tokenIdToRequestId[tokenId];
        require(bytes(tokenURI(tokenId)).length <= 0, "tokenURI is already set!");
        require(msg.sender == requestIdToSender[requestId], "Not owner of this token");
        require(tokenCounter > tokenId, "TokenId has not been minted yet!");
        require(tokenIdToRandomNumber[tokenId] > 0, "Need to wait for the Chainlink node to respond!");
        uint256 randomNumber = tokenIdToRandomNumber[tokenId];
        // wrap fixed svg arround received _svg
    
        string memory imageURI = svgToImageURI(wrapSVG(_svg, tokenId, _svgname, _description, randomNumber));
        string memory tokenURI = formatTokenURI(imageURI, tokenId, _svgname, _description, randomNumber);
        _setTokenURI(tokenId, tokenURI);
        emit CreatedRandomSVG(tokenId);
        return tokenId;
    }

    function wrapSVG(string memory _svg, uint256 _tokenId,string memory _name, string memory _description, uint256 _randomNumber) public pure returns (string memory){
        string memory baseSVG = string(abi.encodePacked('<svg xmlns:svg="http://www.w3.org/2000/svg" xmlns="http://www.w3.org/2000/svg" height="594" width="420" version="1.1" viewBox="0 0 210 297" id="randomcolorkeanusSVG"><desc>',_description,' - Generative Blockchain Art By Rekcce - Unique Random Number: ',uint2str(_randomNumber),'</desc><title id="randomColorKeanusTitle">Random Color Keanus #',uint2str(_tokenId),' - ',_name,'</title>'));
        string memory closeSVG = "</svg>";
        return string(
                abi.encodePacked(
                    baseSVG,
                    _svg,
                    closeSVG)
        );
    }


    function svgToImageURI(string memory _svg)
        public
        pure
        returns (string memory)
    {
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(
            bytes(string(abi.encodePacked(_svg)))
        );

        return string(
            abi.encodePacked(baseURL, svgBase64Encoded)
        );
    }

    function formatTokenURI(string memory _imageURI, uint256 tokenID, string memory _name, string memory _description, uint256 _random)
        public
        view
        returns (string memory)
    {
        string memory baseURL = "data:application/json;base64,";
        return
            string(
                abi.encodePacked(
                    baseURL,
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name": "Random Color Keanus #', uint2str(tokenID),'. ', _name,'", ',
                                '"description": "Random Color Keanus - Generative Blockchain Art By Rekcce - ', _description,' - Unique Random Number: ',uint2str(_random),' ", ',
                                '"attributes": [',
                                    '{',
                                        '  "trait_type": "Base", ',
                                        '  "value": "', bases[_random % bases.length],'"',
                                    '}, ',
                                    '{',
                                        '  "display_type": "boost_number", ',
                                        '  "trait_type": "Breathtaking Power", ',
                                        '  "value": ',uint2str(uint256(keccak256(abi.encode(_random, breathtakingPowerMax        + 1 ))) % breathtakingPowerMax),
                                    '},',
                                    '{',
                                        '  "trait_type": "Personality", ',
                                        '  "value": "', personalities[_random % personalities.length],'"',
                                    '}',
                                    '],',
                                '"image": "', _imageURI,'"}'
                            )
                        )
                    )
                )
            );
    }

     function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
      if (_i == 0) {
          return "0";
      }
      uint j = _i;
      uint len;
      while (j != 0) {
          len++;
          j /= 10;
      }
      bytes memory bstr = new bytes(len);
      uint k = len;
      while (_i != 0) {
          k = k-1;
          uint8 temp = (48 + uint8(_i - _i / 10 * 10));
          bytes1 b1 = bytes1(temp);
          bstr[k] = b1;
          _i /= 10;
      }
      return string(bstr);
  }
}
