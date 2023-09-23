// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AVANFT is ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    enum Rank {
        J,
        Q,
        K,
        Joker
    }

    mapping(uint256 => Rank) public tokenRank;
    mapping(Rank => string) public rankToString;
    mapping(Rank => string) public rankToURI;

    event Minted(address indexed to, uint256 tokenId, Rank rank);

    constructor() ERC721("AVA System NFT", "AVANFT") {
        rankToString[Rank.J] = "J";
        rankToString[Rank.Q] = "Q";
        rankToString[Rank.K] = "K";
        rankToString[Rank.Joker] = "Joker";

        // Set default URIs for each rank (you can change these to your actual URIs)
        rankToURI[
            Rank.J
        ] = "ipfs://QmYpAGNazjsNMcuuBPjYTuFz1kuwiCt6u7nDH9Z8fLMiw2";
        rankToURI[
            Rank.Q
        ] = "ipfs://Qmeh2jqYjpSo7TpZBQxiamagR8KUmJ8dwCwwtU1tcE3mkF";
        rankToURI[
            Rank.K
        ] = "ipfs://QmYZ8ZoTH6CXVrrzUJqXd4XTDoQvhNbRpbLe6AQz1KcJm1";
        rankToURI[
            Rank.Joker
        ] = "ipfs://QmQVsXuAEJjwE1dyL9snotsz59WV7jBsF33d7NeBGGAZRW";
    }

    function mint(address to, Rank rank) external onlyOwner {
        _tokenIdCounter.increment();
        uint256 newTokenId = _tokenIdCounter.current();
        _safeMint(to, newTokenId);
        tokenRank[newTokenId] = rank;
        _setTokenURI(newTokenId, rankToURI[rank]);

        emit Minted(to, newTokenId, rank);
    }

    function setRankURI(Rank rank, string memory uri) external onlyOwner {
        rankToURI[rank] = uri;
    }

    function getTokensOfAddress(
        address _address
    ) external view returns (uint256[] memory, string[] memory) {
        uint256 totalTokensOfOwner = balanceOf(_address);
        uint256[] memory tokenIds = new uint256[](totalTokensOfOwner);
        string[] memory ranks = new string[](totalTokensOfOwner);

        for (uint256 i = 0; i < totalTokensOfOwner; i++) {
            uint256 tokenId = tokenOfOwnerByIndex(_address, i);
            tokenIds[i] = tokenId;
            ranks[i] = rankToString[tokenRank[tokenId]];
        }

        return (tokenIds, ranks);
    }

    function getAllTokenOwnersWithRanks()
        external
        view
        returns (uint256[] memory, address[] memory, string[] memory)
    {
        uint256 totalTokens = totalSupply();
        uint256[] memory tokenIds = new uint256[](totalTokens);
        address[] memory owners = new address[](totalTokens);
        string[] memory ranks = new string[](totalTokens);

        for (uint256 i = 0; i < totalTokens; i++) {
            uint256 tokenId = tokenByIndex(i);
            tokenIds[i] = tokenId;
            owners[i] = ownerOf(tokenId);
            ranks[i] = rankToString[tokenRank[tokenId]];
        }

        return (tokenIds, owners, ranks);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721Enumerable, ERC721URIStorage) returns (bool) {
        return
            ERC721Enumerable.supportsInterface(interfaceId) ||
            ERC721URIStorage.supportsInterface(interfaceId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
}
