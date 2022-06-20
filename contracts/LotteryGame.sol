// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LotteryGame { //is ReentrancyGuard {
    bool isClosedGame = false;
    address public owner;
    address public tokenPay;  // owner can deploy ERC20; 0xaE505db78C245893A7D2A4B3CDFE78603d373293
    //100 players, if wanto change number MUST remove 'immutable', and write function to change
    uint8 immutable maxPlayers = 100;
    uint8 immutable dealerCommision = 10; // 10%
    uint8 public counter = 0;
    uint8 ticketWinner;
    uint immutable payAmount = 10 * 1e18;      //  10 BUSD/USDT/... on decimal 18(can auto)

    // user already played
    mapping(address => bool) public played;
    // mapping player to ticket, useful for BE/FE to fetch myTicket;
    mapping(address => uint8) public playersTicket;
    // mapping ticket to list player
    mapping(uint8 => address[]) public ticketHolder;

    event BuyTicket(address indexed from, uint8 ticket);

    constructor (address _tokenPay) {
        owner = msg.sender;
        tokenPay = _tokenPay;
    }

    // modifier
    modifier onlyOwner() {
        require(owner == msg.sender, "only Owner");
        _;
    }
    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }
    modifier isOpen() {
        require(!isClosedGame, "Game is closed");
        _;
    }


    //public/external function: 
    function buyTicket() external isOpen() notContract() {
        // balance > 0
        require(counter < maxPlayers, "Reach max players");
        require(msg.sender != owner, "Dealer cannot play");
        require(!played[msg.sender], "Only play 1 time");
        require(IERC20(tokenPay).balanceOf(msg.sender) >= payAmount, "Not enough balance");
        //
        IERC20(tokenPay).transferFrom(msg.sender, address(this), payAmount); // user MUST approve to spend token
        counter ++;
        uint8 ticket = _getRandomTicket();
        playersTicket[msg.sender] = ticket;
        ticketHolder[ticket].push(msg.sender);
        played[msg.sender] = true;

        emit BuyTicket(msg.sender, ticket);
    }

    // TODO: We should be allow user(winner) can withdraw, then we will dont loss fee tranfer.
    // function claim() external nonReentrant {
    //     require(playersTicket[msg.sender] == ticketWinner, "You are not winner");
    //     address[] storage listWinner = ticketHolder[ticketWinner];
    //     uint balance = IERC20(tokenPay).balanceOf(address(this));
    //     require(balance > 0, "C: Balance is zero");
    //     //
    //     uint amountWinner = balance / listWinner.length;
    //     for (uint8 i = 0; i < listWinner.length; i ++) {
    //         if (listWinner[i] == msg.sender) {
    //             uint dealerGot = amountWinner / dealerCommision;
    //             IERC20(tokenPay).transfer(owner, dealerGot);
    //             IERC20(tokenPay).transfer(listWinner[i], amountWinner - dealerGot);
    //             //remove user winner
    //         }
    //     }
    // }

    function fetchMyTicket() public view returns(uint8) {
        require(played[msg.sender], "You not play yet");
        return playersTicket[msg.sender];
    }

    function fetchTicketWinner() public view returns(uint8) {
        require(isClosedGame, "Game not close yet");
        return ticketWinner;
    }

    function getWinner() public view returns(address[] memory) {
        return ticketHolder[ticketWinner];
    }


    //internal function
    function _isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }

    function _getRandomTicket() internal view returns (uint8) {
        // using block timestamp last 2-digit for ticket
        uint currentBT = block.timestamp;
        return uint8(currentBT % 100);
    }

    function _calculateAndReturnReward() internal {
        require(isClosedGame, "Game MUST closed first");
        address[] storage listWinner = ticketHolder[ticketWinner];
        uint balance = IERC20(tokenPay).balanceOf(address(this));
        require(balance > 0, "B: Balance is zero");
        if (listWinner.length < 1) { // no one winner
            IERC20(tokenPay).transfer(owner, balance);
        }
        else {
            uint dealerGot = balance / dealerCommision;
            uint amountWinner = balance - dealerGot;
            IERC20(tokenPay).transfer(owner, dealerGot);
            if (listWinner.length  == 1) { // 1 winner
                IERC20(tokenPay).transfer(listWinner[0], amountWinner);
            }
            else { // share if more
                uint eachRw = amountWinner / listWinner.length;
                for (uint8 i = 0; i < listWinner.length; i ++) {
                    IERC20(tokenPay).transfer(listWinner[i], eachRw);
                }
            }
        }
        // ensure that only 1 get reward
        delete ticketHolder[ticketWinner];
    }


    //only ADMIN
    function closeGame() external onlyOwner() isOpen() {
        isClosedGame = true;
        // find Winner
        ticketWinner = _getRandomTicket();
        // TODO: We should allow winner claim
        _calculateAndReturnReward();
    }

    function emegencyCase() external onlyOwner() {
        uint balance = IERC20(tokenPay).balanceOf(address(this));
        require(balance > 0, "A: Balance is zero");
        IERC20(tokenPay).transfer(msg.sender, balance);
    }
}