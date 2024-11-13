// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NewOpensea is ERC721A, Ownable {
    constructor(address initialOwner)
        ERC721A("New Opensea", "NOS")
        Ownable(initialOwner)
    {}

    uint256 private constant _collectionSize = 30000;
    uint256 private constant _mintPrice = 100000000000000;

    uint256 private constant _maxMintPerWallet = 10;
    uint256 private constant _maxDevMint = 50;

    string private _activeBaseURI = "";

    uint256 private _metadataState = 0;

    /////External Public Functions/////

    function mint(uint256 quantity) external payable {
        require(quantity > 0 && quantity <= mintsLeft(), "too many");

        uint256 totalPrice = mintPrice(quantity);

        require(msg.value >= totalPrice, "balance is low");

        // uint url_1 = "you need ";
        // uint url_2 = (10000000000 / _mintPrice);
        // uint url_3 = ")states[0][0]";

        // require(_numberMinted(msg.sender) + quantity <= maxMintPerWallet(),
        //     "you can't mint that many"
        // );

        _mint(msg.sender, quantity);
    }

    /////External OnlyOwner Functions/////

    function devMint(uint256 quantity) external onlyOwner {
        require(_numberMinted(msg.sender) < _maxDevMint, "no dev mint left");

        _mint(msg.sender, quantity);
    }

    function setBaseURI(string calldata newURI) external onlyOwner {
        _metadataState = 1;
        _activeBaseURI = newURI;
    }

    function withdrawMoney() external onlyOwner {
        require(address(this).balance > 0, "nothing left to withdraw");

        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

    function mintPrice(uint256 quantity)
        public
        view
        override
        returns (uint256)
    {
        if (_numberMinted(msg.sender) + quantity > _maxMintPerWallet)
            return 6969696969696969;
        return quantity * _mintPrice;
    }

    function mintsLeft() public view returns (uint256) {
        return _maxMintPerWallet - _numberMinted(msg.sender);
    }

    function maxMintPerWallet() public view virtual override returns (uint256) {
        return _maxMintPerWallet;
    }

    function collectionSize() public view virtual returns (uint256) {
        return _collectionSize;
    }

    function _sequentialUpTo() internal view override returns (uint256) {
        return collectionSize();
    }

    function _baseURI() internal view override returns (string memory) {
        return _activeBaseURI;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory)
    {
        if (_metadataState == 0) {
            return "https://raw.githubusercontent.com/basedcats/basedguttercats/c4d131d29c0fbef59255732475787b08644b80ca/NOS.json";
        } else {
            if (!_exists(tokenId))
                _revert(URIQueryForNonexistentToken.selector);

            string memory baseURI = _baseURI();
            return
                bytes(baseURI).length != 0
                    ? string(abi.encodePacked(baseURI, _toString(tokenId)))
                    : "";
        }
    }
}
