pragma solidity ^0.8.7;

import "./CardGenerator.sol";

contract Game is CardGenerator{
    
    
    uint minBet = 20; //missing function to set minBet ########
    
    uint round; //to keep track of the game no.
    uint betAmount;
    uint[] playerCards; //array to store players Cards
    string[] viewPlayerCards;
    uint[] private dealerCards;// array to store dealers cards
    string[] viewDealerCards;
    address player;
    uint doubleDownFlag;
    uint splitFlag;
    
    enum Results{
        Draw,
        Player,
        Dealer,
        uncertain
    }
    enum Stage{
        start,   
        deal,
        hitStand,
        nextRound
    }
    
    Stage public stage = Stage.start; //to store the stage
    
    Results[] public roundResults; // to store the results of each round
    
    
    
    modifier onlyPlayer() { //modifier to check player 
        require(player == msg.sender, "Not the player who started the game.");
        _;
    }
    
    modifier onlyStage(Stage reqStage) {
        require(stage == reqStage, "Not in this stage.");
        _;
    }
    
    
    function start() onlyStage(Stage.start) public { //to start the game by getting a random number
        getRandomNumber(); //getting random number for the game
        player = msg.sender;
        stage = Stage.deal; // next stage is dealing cards
        round = 0;
    } 
    
    
    
    
    
    function deal(uint _amount) onlyPlayer onlyStage(Stage.deal) public {
        require(_amount >= minBet, "Low bet amount.");
        betAmount = _amount;
        
        dealerCards.push(getCard()); //giving 1 card to dealer
        playerCards.push(getCard());//giving 2 cards to player
        playerCards.push(getCard());
        
        doubleDownFlag = 1;
        
        if((playerCards[0] % 13) == (playerCards[1] % 13)) {
            splitFlag = 1;
        }
        
        (uint sum1Player, uint sum2Player) = countTotal(playerCards);
        
        if(sum1Player == 21 || sum2Player == 21){ //check for blackjack
            checkDealer21();//check for draw
            stage = Stage.nextRound;
        }
        else {
            stage = Stage.hitStand; // next stage is hit/stand if sum is not 21
        }
    }
    
    
    
    function hit() onlyPlayer onlyStage(Stage.hitStand) public {
        
        playerCards.push(getCard()); //giving 1 card to player
        
        doubleDownFlag = 0;
        splitFlag = 0;
        
        (uint sum1Player, uint sum2Player) = countTotal(playerCards); //counting sum for exceding 21 or blackjack
        if(sum1Player > 21 && sum2Player > 21){ //checking for bust
            dealerCards.push(getCard());
            roundResults.push(Results.Dealer); //storing winner
            stage = Stage.nextRound;
        }
        else if(sum1Player == 21 || sum2Player == 21){ //check for blackjack
            checkDealer21(); //check for draw 
            stage = Stage.nextRound;
        }
    }
    
    function stand() onlyPlayer onlyStage(Stage.hitStand) public {
        
        doubleDownFlag = 0;
        splitFlag = 0;
        
        (uint sum1Player, uint sum2Player) = countTotal(playerCards);
        
        if(sum1Player < 21 && sum2Player < 21) {
            checkStand(sum2Player);
        }
        else {
            checkStand(sum1Player);
        }
        
        stage = Stage.nextRound;
    }
    
    function doubleDown(uint _2xbetAmount) onlyPlayer onlyStage(Stage.hitStand) public {
        require(doubleDownFlag == 1, "Can not Double Down");
        require(_2xbetAmount == (2 * betAmount), "Provide the Double Down amount.");
        
        doubleDownFlag = 0;
        splitFlag = 0;
        
        playerCards.push(getCard());
        (uint sum1Player, uint sum2Player) = countTotal(playerCards);
        
        if(sum1Player > 21 && sum2Player > 21){ //checking for bust
            dealerCards.push(getCard());
            roundResults.push(Results.Dealer); //storing winner
        }
        else if(sum1Player == 21 || sum2Player == 21){ //check for blackjack
            checkDealer21(); //check for draw 
        }
        else if(sum1Player < 21 && sum2Player < 21) { //check for stand with both no. below 21
            checkStand(sum2Player);
        }
        else {
            checkStand(sum1Player); // check for stand with 1 no. below 21
        }
        
        stage = Stage.nextRound;
    }
    
    
    
    
    
    
    
    
    
    
    function checkStand(uint _sumPlayer) internal { //error
        
        dealerCards.push(getCard());
        (uint sum1dealer, uint sum2dealer) = countTotal(dealerCards);
        uint f = 0;
        
        if( sum1dealer > _sumPlayer || sum2dealer > _sumPlayer) {
            f = 1;
        }
        else if(sum1dealer == _sumPlayer || sum2dealer == _sumPlayer) {
            f = 2;
        }
        
        
        while( (sum1dealer < _sumPlayer) && (f == 0)) {
            dealerCards.push(getCard());
            (sum1dealer,sum2dealer) = countTotal(dealerCards);
            
            if(sum1dealer >= _sumPlayer || sum2dealer >= _sumPlayer) {
                if(((sum1dealer > _sumPlayer) && (sum1dealer <=21 )) || ((sum2dealer > _sumPlayer) && (sum2dealer <= 21))) {
                    f = 1;
                }
                else if( (sum1dealer == _sumPlayer) || (sum2dealer == _sumPlayer)) {
                    f = 2;
                }
            }
        }
        
        if(f == 1){
            roundResults.push(Results.Dealer);
        }
        else if(f == 2) {
            roundResults.push(Results.Draw);
        }
        else{
            roundResults.push(Results.Player);
        }
    }
    

    function checkDealer21() internal {
        
        if(stage == Stage.deal) {
            dealerCards.push(getCard());
            (uint sum1dealer, uint sum2dealer) = countTotal(dealerCards);
            if(sum1dealer == 21 || sum2dealer == 21) {
                roundResults.push(Results.Draw);
            }
            else {
                roundResults.push(Results.Player);
            }
        }
        else if(stage == Stage.hitStand) {
            (uint sum1dealer, uint sum2dealer) = countTotal(dealerCards);
            uint f = 0;
            
            while(sum1dealer < 21 || sum2dealer < 21) {
                dealerCards.push(getCard());
                (sum1dealer,sum2dealer) = countTotal(dealerCards);
                if(sum1dealer == 21 || sum2dealer == 21) {
                    f = 1;
                    break;
                }
            }
            
            if(f == 1) {
                roundResults.push(Results.Draw);
            }
            else {
                roundResults.push(Results.Player);
            }
        }
    }
    
    /*  i - Cards
        1 - A 
        2 - 2
        3 - 3 
        4 - 4 
        5 - 5 
        6 - 6 
        7 - 7 
        8 - 8 
        9 - 9 
        10 - 10 
        11 - J 
        12 - Q 
        13 - K
    */
    
    function countTotal(uint[] memory _cardArray) pure internal returns(uint,uint) {  // to count the total of the cards 
        uint[14] memory cardCount; //array to store the no. of each cards ...index 0 is left blank
        uint sum1 = 0;
        uint sum2 = 0;
        
        for(uint i=0; i < _cardArray.length; i++) { //storing no. of each cards
            uint card = (_cardArray[i] % 13) + 1;
            cardCount[card]++;
        }
        
        uint faceCardsSum = (cardCount[11] + cardCount[12] + cardCount[13])*10; //total sum of face cards
        uint normalSum = 0;
        
        for(uint i =2; i<= 10;i++){ //sum of common cards
            normalSum += i*cardCount[i];
        }
        
        sum1 = faceCardsSum + normalSum;
        sum2 = faceCardsSum + normalSum;
        
        uint nAce = cardCount[1]; //no. of ace
        
        if(nAce ==1) { //when 1 ace
            sum1 += 1;
            sum2 += 11;
        }
        else if(nAce > 1) { //when more than 1 ace
            sum1 += nAce ;
            sum2 += (nAce + 10);
        }
        
        return (sum1,sum2); //returning both sums ..if ace is not present both will be equal
    }
        
    
    function getPlayerCards() public returns(string[] memory) {
        
        delete viewPlayerCards;
        
        for(uint i=0; i < playerCards.length; i++) { //storing no. of each cards
            (string memory x,) = getCardString(playerCards[i]);
            viewPlayerCards.push(x);
        }
        return viewPlayerCards;
    }
    
    function getDealerCards() public returns(string[] memory) {
        
        delete viewDealerCards;
        
        for(uint i=0; i < dealerCards.length; i++) { //storing no. of each cards
            (string memory x,) = getCardString(dealerCards[i]);
            viewDealerCards.push(x);
        }
        return viewDealerCards;
    }
    
    
    function nextRound() onlyStage(Stage.nextRound) public {
        
        delete playerCards;
        delete dealerCards;
        round ++;
        stage = Stage.deal;
        doubleDownFlag = 0;
        splitFlag = 0;
    }
}
