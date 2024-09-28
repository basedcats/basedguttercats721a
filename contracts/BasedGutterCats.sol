// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BasedGutterCats is ERC721A, Ownable {
    constructor(address initialOwner)
        ERC721A("BasedGutterCats", "BGC")
        Ownable(initialOwner)
    {}

    uint256 private constant _maxMintPerWallet = 5;
    uint256 private constant _maxFreeMintPerWallet = 1;
    uint256 private constant _mintPrice = 100000000000000;

    string private _savedBaseURI = "";
    uint256 private _eligibleBurners = 0;

    function mint(uint256 quantity) external payable {
        uint256 totalPrice = mintPrice(quantity);

        require(msg.value >= totalPrice,
            "you can't afford it");

        require(mintsLeft() >= quantity,
            "you can't mint that many");

        require(_numberMinted(msg.sender) + quantity <= maxMintPerWallet(),
            "you can't mint that many");

        _mint(msg.sender, quantity);

        _refundExtra(totalPrice);

        if (_numberMinted(msg.sender) == maxMintPerWallet()) _eligibleBurners++;
    }

    function burnKitty(uint256 kittyId) external {
        require(address(this).balance > _mintPrice,
            "kitty hell is closed for now");

        require(_numberMinted(msg.sender) == maxMintPerWallet(),
            "you need to save all the kitties you can first");

        require(_numberBurned(msg.sender) == 0,
            "you've already sent a kitty to kitty hell");

        _burn(kittyId, true);

        if (address(this).balance > _mintPrice)
            payable(msg.sender).transfer(_mintPrice);

        _eligibleBurners--;
    }

    function mintPrice(uint256 quantity)
        public
        view
        virtual
        override
        returns (uint256)
    {
        if (_freeMintsLeft() >= quantity) return 0;

        return (quantity - _freeMintsLeft()) * _mintPrice;
    }

    function mintsLeft() public view returns (uint256) {
        return _maxMintPerWallet - _numberMinted(msg.sender);
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

    function _freeMintsLeft() internal view returns (uint256) {
        return _numberMinted(msg.sender) >= _maxFreeMintPerWallet ? 0
                : _maxFreeMintPerWallet - _numberMinted(msg.sender);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _savedBaseURI;
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _savedBaseURI = baseURI;
    }

    /*function setMintCount(uint256 newCount) external onlyOwner {
        _maxMintPerWallet = newCount;
    }*/

    /*function setFreeMintCount(uint256 newCount) external onlyOwner {
        _maxFreeMintPerWallet = newCount;
    }*/

    /*function setMintPrice(uint256 newPrice) external onlyOwner {
        _mintPrice = newPrice;
    }*/

    function withdrawMoney() external onlyOwner {
        require(address(this).balance > 0,
         "nothing left to withdraw");

        uint256 withdrawableAmount = address(this).balance - (_eligibleBurners * _mintPrice);
        require(withdrawableAmount > 0,
            "this money belongs to potential hell kitty enthusiasts who are yet to discover its magic");

        (bool success, ) = msg.sender.call{value: withdrawableAmount}("");
        require(success, "Transfer failed.");
    }

    function _refundExtra(uint256 price) internal {
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
    }
}
