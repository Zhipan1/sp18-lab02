pragma solidity 0.4.19;


contract Betting {
    /* Constructor function, where owner and outcomes are set */
    function Betting(uint[] _outcomes) public {
        numOutcomes = _outcomes.length;
        for (uint i = 0; i < numOutcomes; i++) {
            outcomes[i] = _outcomes[i];
        }
        owner = msg.sender;
    }

    /* Fallback function */
    function() public payable {
        revert();
    }

    /* Standard state variables */
    address public owner;
    address public gamblerA;
    address public gamblerB;
    address public oracle;

    /* Structs are custom data structures with self-defined parameters */
    struct Bet {
        uint outcome;
        uint amount;
        bool initialized;
    }

    /* Keep track of every gambler's bet */
    mapping (address => Bet) bets;
    /* Keep track of every player's winnings (if any) */
    mapping (address => uint) winnings;
    /* Keep track of all outcomes (maps index to numerical outcome) */
    mapping (uint => uint) public outcomes;
    /* Keep track of number of outcomes */
    uint public numOutcomes;

    /* Add any events you think are necessary */
    event BetMade(address gambler);
    event BetClosed();

    /* Uh Oh, what are these? */
    modifier ownerOnly() {
        require(msg.sender == owner);
        _;
    }
    modifier oracleOnly() {
        require(msg.sender == oracle);
        _;
    }
    modifier outcomeExists(uint outcome) {
        bool exists = false;
        for (uint i = 0; i < numOutcomes; i++) {
            if (outcomes[i] == outcome) {
                exists = true;
                break;
            }
        }

        require(exists);
        _;
    }

    /* Owner chooses their trusted Oracle */
    function chooseOracle(address _oracle) public ownerOnly() returns (address) {
        require(_oracle != owner);
        oracle = _oracle;
        return oracle;
    }

    /* Gamblers place their bets, preferably after calling checkOutcomes */
    function makeBet(uint _outcome) public outcomeExists(_outcome) payable returns (bool) {
        require(msg.sender != oracle);
        require(msg.sender != owner);
        require(msg.value > 0);
        Bet memory bet = Bet({ outcome: _outcome, amount: msg.value, initialized: true });

        if (gamblerA == address(0)) {
            gamblerA = msg.sender;
            bets[gamblerA] = bet;
            BetMade(gamblerA);
        } else if (gamblerB == address(0)) {
            require(msg.sender != gamblerA);

            // From spec: If all gamblers bet on the same outcome, reimburse all gamblers their funds
            // exploit: gamblerB bets on whatever outcome gamblerA chooses to reset the contract
            if (bets[gamblerA].outcome == _outcome) {
                contractReset();
                return false;
            }

            gamblerB = msg.sender;
            bets[gamblerB] = bet;
            BetMade(gamblerB);
            BetClosed();
        } else {
            return false;
        }

        return true;
    }

    /* The oracle chooses which outcome wins */
    function makeDecision(uint _outcome) public oracleOnly() outcomeExists(_outcome) {
        require(gamblerA > address(0) && gamblerB > address(0));
        uint totalStake = bets[gamblerA].amount + bets[gamblerB].amount;
        if (bets[gamblerA].outcome == _outcome) {
            winnings[gamblerA] = totalStake;
        } else if (bets[gamblerB].outcome == _outcome) {
            winnings[gamblerB] = totalStake;
        } else {
            winnings[oracle] = totalStake;
        }
    }

    /* Allow anyone to withdraw their winnings safely (if they have enough) */
    function withdraw(uint withdrawAmount) public returns (uint) {
        require(withdrawAmount > 0);
        require(winnings[msg.sender] >= withdrawAmount);
        msg.sender.transfer(withdrawAmount);
        winnings[msg.sender] -= withdrawAmount;
    }

    /* Allow anyone to check the outcomes they can bet on */
    function checkOutcomes(uint outcomeIndex) public view returns (uint) {
        return outcomes[outcomeIndex];
    }

    /* Allow anyone to check if they won any bets */
    function checkWinnings() public view returns(uint) {
        return winnings[msg.sender];
    }

    /* Call delete() to reset certain state variables. Which ones? That's upto you to decide */
    function contractReset() public ownerOnly() {
        delete(gamblerA);
        delete(gamblerB);
        delete(bets[0]);
        delete(bets[1]);
    }
}
