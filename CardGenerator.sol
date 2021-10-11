pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract CardGenerator is VRFConsumerBase{

    bytes32 keyHash;
    uint fee;
    uint private randomResult;
    uint private nonce;
    uint count;
    uint public cardd;
    uint deckSize = (6*52);
    
    mapping(uint => bool) private cardCheck;
    
    event _randomNumber(string msg);
    event _card(string msg, uint c);
        
        //Rinkeby Network
    constructor() VRFConsumerBase(
            0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, // VRF Coordinator
            0x01BE23585060835E02B77ef475b0Cc51aA1e0709  // LINK Token
        ){
        keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
        fee = 0.1 * 10 ** 18; // 0.1 LINK (Varies by network)
        }
    
    function getRandomNumber() internal returns(bytes32 requestId){
        require(LINK.balanceOf(address(this)) >= fee,"Low LINK");
        requestId = requestRandomness(keyHash,fee);
        nonce = 0;
        count = 0;
        resetCardDeck();
        return requestId;
    }
    
    function fulfillRandomness(bytes32 requestId, uint randomness) internal override{ //used by chainlink to send the randomness...is run by getRandomNumber()
        randomResult = randomness;
        emit _randomNumber("Random number generated");
    }
    
    function getCard() internal returns(uint){
        if(count == (deckSize / 2)) {
            resetCardDeck();
        }
        uint randomCardNumber = uint(keccak256(abi.encode(randomResult,nonce)));
        nonce ++;
        uint card = randomCardNumber % deckSize;
        if(cardCheck[card] == false){
            cardCheck[card] = true;
            count ++;
            cardd = card;
            emit _card("Card -",cardd);
            return card;
        }
        else{
            return getCard();
        }
    }
    
    function getCardString(uint _numberCard) pure internal returns(string memory _stringCard, uint suits) {
        uint card = (_numberCard % 13) + 1;
        suits = (_numberCard % 52) / 13;
        
        if(card == 1) {
            return ("A",suits);
        }
        else if(card == 2) {
            return ("2",suits);
        }
        else if(card == 3) {
            return ("3",suits);
        }
        else if(card == 4) {
            return ("4",suits);
        }
        else if(card == 5) {
            return ("5",suits);
        }
        else if(card == 6) {
            return ("6",suits);
        }
        else if(card == 7) {
            return ("7",suits);
        }
        else if(card == 8) {
            return ("8",suits);
        }
        else if(card == 9) {
            return ("9",suits);
        }
        else if(card == 10) {
            return ("10",suits);
        }
        else if(card == 11) {
            return ("J",suits);
        }
        else if(card == 12) {
            return ("Q",suits);
        }
        else if(card == 13) {
            return ("K",suits);
        }
    }
    
        
    
    function resetCardDeck() internal{
        count = 0;
        for(uint i=0;i<deckSize;i++)
        {
            cardCheck[i] = false;
        }
    }
    
 

}
