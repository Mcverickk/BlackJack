pragma solidity ^0.8.7;

import "./CardGenerator.sol";

contract Game is CardGenerator{
    
    
    uint minBet = 20; //missing function to set minBet ########
    
    uint round = 0; //to keep track of the game no.
    uint[] public playerCards; //array to store players Cards
    uint[] private dealerCards;// array to store dealers cards
    uint public dealerCardOne = deckSize + 1; // dealers 1st card, deckSize +1 ro avoid misunderstanding at the start
    
    enum Results{
        Player,
        Dealer,
        Draw,
        uncertain
    }
    enum Stage{
        bet,
        deal,
        hitorstand
    }
    
    Stage stage = Stage.bet; //to store the stage
    
    Results[] public roundResults; // to store the results of each round
    
    function bet(uint _amount) public { //to bet an amount to start the game round
        require(_amount >= minBet, "Low bet amount.");
        require(stage == Stage.bet, "Cannot bet now.");
        getRandomNumber(); //getting random number for the game
        stage = Stage.deal; // next stage is dealing cards
    } 
    
    function dealCards() public {
        require(stage == Stage.deal, "Cannot deal."); //to avoid execution at any other stage
        
        dealerCards.push(getCard()); //giving 2 cards both for dealer and player
        dealerCards.push(getCard());
        playerCards.push(getCard());
        playerCards.push(getCard());
        dealerCardOne = dealerCards[0]; // the dealer card visible to players
        stage = Stage.hitorstand; // next stage is hit/stand if sum is not 21
        uint sumPlayer = countTotal(playerCards);
        if(sumPlayer == 21){ //check for blackjack
            if(checkDealer() == 21){//checking for Draw
                roundResults[round] = Results.Draw;
            } 
            else{
                roundResults[round] = Results.Player;
            }
        }
    }
    
    function hit() public {
        require(stage == Stage.hitorstand, "Cannot hit now."); //to avoid execution at any other stage
        
        playerCards.push(getCard()); //giving 1 card to player
        uint sumPlayer = countTotal(playerCards); //counting sum for exceding 21 or blackjack
        if(sumPlayer > 21){
            roundResults[round] = Results.Dealer;
            endRound();
        }
        else if(sumPlayer == 21){ //check for blackjack
            if(checkDealer() == 21){//checking for Draw
                roundResults[round] = Results.Draw;
            } 
            else{
                roundResults[round] = Results.Player;
            }
        }
    }
    
    function stand() public {
        require(stage == Stage.hitorstand, "Cannot stand now."); //to avoid execution at any other stage
        
        uint sumPlayer = countTotal(playerCards); //sum of player
        uint sumDealer = countTotal(dealerCards); // sum of dealer
        if( sumDealer > sumPlayer) { //as dealer hasnt picked any more cards so the max will be 21
              roundResults[round] = Results.Dealer;
        }
        else 
        {
            uint sumDealerFinal = checkDealer(); //requesting Dealer final sum before exceeding 21
            if(sumDealerFinal > sumPlayer) { //Dealer win check
                roundResults[round] = Results.Dealer;
            }
            else { //Player win 
                roundResults[round] = Results.Player;
            }
        }
        
    }
    
    
    
    function checkDealer() internal returns(uint) {
        uint sumDealer = dealerCards[0] + dealerCards[1];
        uint c = 2;
        
        while(sumDealer < 21){ //gives sum greater than equal to 21 
            dealerCards.push(getCard());
            sumDealer += dealerCards[c];
            c++;
        }
        
        if(sumDealer == 21) //if 21 then return as it is
        {
            return sumDealer;
        }
        else{
            return (sumDealer - dealerCards[c - 1]); // return the value just less than 21 #########card waste 
        }
    }
    
    
    
    function countTotal(uint[] memory _cards) internal returns(uint) {
        uint s = 0;
        for(uint i=0; i < _cards.length; i++)
        {
            s += _cards[i];
        }
        return (s);
    }
    
    
    
    function endRound() public {
        delete playerCards;
        delete dealerCards;
        round ++;
        dealerCardOne = deckSize + 1;
        stage = Stage.bet;
    }
}
