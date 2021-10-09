pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract CardGenerator is VRFConsumerBase{

    bytes32 keyHash;
    uint fee;
    uint randomResult;
    uint nonce;
    uint count;
    uint public cardd;
    uint deckSize = 104;
    
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
    
    function getRandomNumber() public returns(bytes32 requestId){
        require(LINK.balanceOf(address(this)) >= fee,"Low LINK");
        requestId = requestRandomness(keyHash,fee);
        nonce = 0;
        count = 0;
        resetCardCheck();
        return requestId;
    }
    
    function fulfillRandomness(bytes32 requestId, uint randomness) internal override{
        randomResult = randomness;
        emit _randomNumber("Random number generated");
    }
    
    function getCard() public returns(uint){
        require(count < deckSize, "No cards left");
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
    
    function getCardCount(uint _card) internal returns(uint,uint) {
        uint c = (_card % 13) + 1;
        
        if(c == 1){
            return(1,11);
        }
        
        else if(c > 10){
            return(10,10);
        }
        
        else{
            return(c,c);
        }
    }
    
    function resetCardCheck() private{
        for(uint i=0;i<deckSize;i++)
        {
            cardCheck[i] = false;
        }
    }
    
 

}
