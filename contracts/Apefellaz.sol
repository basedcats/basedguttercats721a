// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ApeFellaz is ERC721A, Ownable {
    constructor(address initialOwner)
        ERC721A("ApeFellaz", "AF")
        Ownable(initialOwner)
    {}

    uint256 private constant _collectionSize = 2222;
    uint256 private constant _mintPrice = 200000000000000000; //0.1 APE

    uint256 private maxDevMint = 69;
    uint256 private maxFreeMint = 1;
    uint []private maxMintCounts = [269, 689, 1379,
                                     1779, 2222];
    uint256[] private mintPrices = [0, 420000000000000000, 690000000000000000,
                                     990000000000000000, 1234000000000000000];


    string private _activeBaseURI = "";
    uint256 private _eligibleBurners = 0;
    uint256 private _mintedTokens = 0;
    uint256 private _currentStage = 0; //max is "mitPrices" & "maxMintCounts" length

    /////External Public Functions/////


 
    function mint(uint256 quantity) external payable {
        require(quantity > 0 && quantity <= mintsLeft() ,
        "you can't mint that many");

        uint256 totalPrice = mintPrice(quantity);

        require(msg.value >= totalPrice,
         "you can't afford it");

        // uint url_1 = "you need ";
        // uint url_2 = (10000000000 / _mintPrice);
        // uint url_3 = ")states[0][0]";


        // require(_numberMinted(msg.sender) + quantity <= maxMintPerWallet(),
        //     "you can't mint that many"
        // );

        _mint(msg.sender, quantity);

        _refundExtra(totalPrice);

        if (_numberMinted(msg.sender) == maxMintPerWallet()) _eligibleBurners++;
        _mintedTokens = _mintedTokens + quantity;

        _currentStage = 0;

        for(uint i = 1; i < 5; i++){
            if(_mintedTokens > maxMintCounts[i - 1] && _mintedTokens <= maxMintCounts[i])
                _currentStage = i;
        }
    }



    function burnKitty(uint256 kittyId) external {

        require(keccak256(abi.encodePacked(canBurn())) == "Allowed",
         canBurn());

        _burn(kittyId, true);

        payable(msg.sender).transfer(_mintPrice);

        _eligibleBurners--;
    }


    /////External OnlyOwner Functions/////

    function devMint(uint256 quantity) external onlyOwner { //todo test it
        require(_numberMinted(msg.sender) < maxDevMint,
         "no dev mint left");

        _mint(msg.sender, quantity);
    }

    function setBaseURI(string calldata newURI) external onlyOwner {
        _activeBaseURI = newURI;
    }

    function withdrawMoney() external onlyOwner {
        require(address(this).balance > 0, "nothing left to withdraw");

        uint256 withdrawableAmount = address(this).balance -
            (_eligibleBurners * _mintPrice);
        require(
            withdrawableAmount > 0,
            "this money belongs to potential hell kitty enthusiasts who are yet to discover its magic"
        );

        (bool success, ) = msg.sender.call{value: withdrawableAmount}("");
        require(success, "Transfer failed.");
    }


    /////Internal Functions/////

    function _refundExtra(uint256 price) internal {
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
    }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    


    /////Properties/////

    function mintPrice(uint256 quantity) public view override returns (uint256)
    {
        if (_freeMintsLeft() >= quantity) return 0;
        if (_numberMinted(msg.sender) + quantity > maxMintPerWallet())
            return 6969696969696969;
        return (quantity - _freeMintsLeft()) * (mintPrices[_currentStage]);
    }

    function mintsLeft() public view returns (uint256) {
        return maxMintPerWallet() - _numberMinted(msg.sender);
    }

    function maxMintPerWallet() public view virtual override returns (uint256) {
        return 180;
        //return maxMintCounts[_currentStage];
    }
    
    function collectionSize() public view virtual returns (uint256) {
        return _collectionSize;
    }

    function canBurn() public view returns (string memory) {
        if( _numberMinted(msg.sender) < maxMintPerWallet())
            return "Denied: you need to save all the kitties you can first";

        if(_numberBurned(msg.sender) >= 1)
            return "Denied: you've already sent a kitty to kitty hell";

        if( address(this).balance < _mintPrice)
            return "Denied: kitty hell is closed for now";


        return "Allowed";
    }

    function _sequentialUpTo() internal view override returns (uint256)
    {
        return collectionSize();
    }

    function _freeMintsLeft() internal view returns (uint256) { //the first NFT minted by a wallet is alweays free so we just use numberMinted here
        return
            _numberMinted(msg.sender) >= maxFreeMint
                ? 0
                : maxFreeMint - _numberMinted(msg.sender);
    }

    function _baseURI() internal view override returns (string memory) {
        return _activeBaseURI;
    }
    
}
