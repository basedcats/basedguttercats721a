// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FellowApes is ERC721A, Ownable {
    constructor(address initialOwner)
        ERC721A("FellowApes", "FA")
        Ownable(initialOwner)
    {}

    uint256 private constant _collectionSize = 2222;
    uint256 private constant _invalidPrice = 6942069420;

    uint256 private maxDevMint = 2100;
    uint private freeMintPerWallet = 1;
    uint private paidMintPerWallet = 4;
    uint []private stagesMintCounts = [269, 689, 1379, 1779, 2222];
    uint [] private stagesMintPrices = [0, 420000000000000000, 690000000000000000, 990000000000000000, 1234000000000000000];

    string private _activeBaseURI = "";
    uint256 private _mintedTokens = 0;
    uint256 private _currentStage = 0; //max is 4


    /////External Public Functions/////

    function mint(uint256 quantity) external payable {
        require(quantity != 0 && quantity <= mintsLeft() , "Q");

        require(quantity == 1 || _mintedTokens + quantity <= stagesMintCounts[_currentStage], "SQ");

        uint256 totalPrice = mintPrice(quantity);

        require(msg.value >= totalPrice, "P");

        _mint(msg.sender, quantity);

        _mintedTokens = _mintedTokens + quantity;

        if(_currentStage == 0){
            _setAux(msg.sender, 1);
        }

        _currentStage = 0;
        for(uint i = 1; i < 5; i++){
            if(_mintedTokens > stagesMintCounts[i - 1] && _mintedTokens <= stagesMintCounts[i])
                _currentStage = i;
        }

        _refundExtra(totalPrice);
    }

    /////External OnlyOwner Functions/////

    function devMint(uint256 quantity) external onlyOwner {
        require(_numberMinted(msg.sender) + quantity < maxDevMint, "DMF");

        _mint(msg.sender, quantity);
        
        _mintedTokens = _mintedTokens + quantity;
    }

    function setBaseURI(string calldata newURI) external onlyOwner {
        _activeBaseURI = newURI;
    }

    function withdrawMoney() external onlyOwner {
        require(address(this).balance > 0, "W");

        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "WF");
    }


    /////Internal Functions/////

    function _refundExtra(uint256 price) internal {
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
    }


    /////Properties/////

    function mintPrice(uint256 quantity) public view override returns (uint256){
        if(quantity == 0) return _invalidPrice;

        if(_currentStage == 0){
            if(quantity == 1 && _getAux(msg.sender) == 0) return 0;
            else return _invalidPrice;
        }

        //return (quantity - _freeMintsLeft()) * (stagesMintPrices[_currentStage]);

        uint price = (quantity - _freeMintsLeft()) * (stagesMintPrices[_currentStage]);

        if(_getCurrentStage(_mintedTokens + quantity) != _currentStage){ //should never be true for last stage
            uint nextStageMints = (_mintedTokens + quantity) - stagesMintCounts[_currentStage];
            uint thisStageMints = quantity - nextStageMints;
            price = (thisStageMints * stagesMintPrices[_currentStage]) + (nextStageMints * stagesMintPrices[_currentStage + 1]);
            price -= _freeMintsLeft() != 0 ? stagesMintPrices[_currentStage + (thisStageMints != 0 ? 0 : 1)] : 0;
        }

        return price;
           // price (_mintedTokens + quantity) - stagesMintCounts[_currentStage]
        
    }

    function mintsLeft() public view returns (uint256) {
        if(_currentStage == 0){
            if(_getAux(msg.sender) == 0) return 1;
            else return 0;
        }

        return (freeMintPerWallet + paidMintPerWallet) - _postFreeStageMinted();
    }

    function currentStage() public view returns (uint256) {
        return _currentStage;
    }

    function stageZeroMintLeft(address minter) public view returns (uint256) {
        return _currentStage == 0 && _getAux(minter) == 0 ? 1 : 0;
    }

    function maxMintPerWallet() public view virtual override returns (uint256) { //where is it used??
        return paidMintPerWallet; //1 free mint
    }

    function _getCurrentStage(uint count) internal view returns (uint256) {
        uint stage = 0;
        for(uint i = 1; i < 5; i++){
            if(count > (i != 0 ? stagesMintCounts[i - 1] : 0) && count <= stagesMintCounts[i]){
                stage = i;
                break;
            }
        }
        return stage;
    }

    function _freeMintsLeft() internal view returns (uint256) { //doesn't count the stage 0 free mint available to all

        return _currentStage != 0 && _postFreeStageMinted() == 0 ? 1 : 0;
    }

    function _postFreeStageMinted() internal view returns (uint256) {  //number of NFTs the user has minted after statge 0 (free stage)
        return _numberMinted(msg.sender) - (_getAux(msg.sender) == 0 ? 0 : 1);
    }

    function collectionSize() public view virtual returns (uint256) {
        return _collectionSize;
    }

    function _sequentialUpTo() internal view override returns (uint256)
    {
        return collectionSize();
    }

    function _baseURI() internal view override returns (string memory) {
        return _activeBaseURI;
    }

}
