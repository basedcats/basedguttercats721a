// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BasedGutterCats is ERC721A, Ownable {
    constructor(address initialOwner)
        ERC721A("BasedGutterCats", "BGC")
        Ownable(initialOwner)
    {}

    string private _savedBaseURI = "";
    uint256 private _maxMintPerWallet = 5;
    uint256 private _maxFreeMintPerWallet = 1;
    uint256 private _mintPrice = 100000000000000;

    function mint(uint256 quantity) external payable {
        // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`.
        _mint(msg.sender, quantity);
    }

    function freeMintsLeft() public view returns (uint256) {
        return _numberMinted(msg.sender) >= _maxFreeMintPerWallet ? 0 : _maxFreeMintPerWallet - _numberMinted(msg.sender);
    }

    function mintPrice(uint256 quantity)
        public
        view
        virtual
        override
        returns (uint256)
    {
        if (freeMintsLeft() >= quantity)
            return 0;

        return (quantity - freeMintsLeft()) * _mintPrice;
    }

    function maxMintPerWallet() public view virtual override returns (uint256) {
        return _maxMintPerWallet;
    }

    function _sequentialUpTo()
        internal
        view
        virtual
        override
        returns (uint256)
    {
        return 999;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _savedBaseURI;
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _savedBaseURI = baseURI;
    }

    function setMintCount(uint256 newCount) external onlyOwner {
        _maxMintPerWallet = newCount;
    }

    function setFreeMintCount(uint256 newCount) external onlyOwner {
        _maxFreeMintPerWallet = newCount;
    }

    function setMintPrice(uint256 newPrice) external onlyOwner {
        _mintPrice = newPrice;
    }

    function withdrawMoney() external onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }
}
