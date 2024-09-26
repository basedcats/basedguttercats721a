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

    uint256 private constant collectionSize = 999;

    function mint(uint256 quantity) external payable {
        // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`.
        _mint(msg.sender, quantity);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _savedBaseURI;
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _savedBaseURI = baseURI;
    }

    function _sequentialUpTo()
        internal
        view
        virtual
        override
        returns (uint256)
    {
        return collectionSize;
    }

    function refundIfOver(uint256 price) private {
        require(msg.value >= price, "Need to send more ETH.");
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
    }
}
