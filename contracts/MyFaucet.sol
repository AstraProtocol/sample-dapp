// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IERC20 {
    function decimals() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract MyFaucet {
    mapping(address => bool) public alreadyClaimed;
    address public token;  //BUSD
    address public owner;
    
    constructor (address _token) {
        owner = msg.sender;
        token = _token;
    }

    function claimTokens() public {
        require(
            !alreadyClaimed[msg.sender],
            "You have already claimed your 100 tokens !!"
        );

        alreadyClaimed[msg.sender] = true;

        uint256 decimals = IERC20(token).decimals();
        IERC20(token).transfer(msg.sender, 100 * 10 ** decimals);
    }

    function getContractBalance() public view returns (uint256) {
        uint256 decimals = IERC20(token).decimals();
        return IERC20(token).balanceOf(address(this)) / 10 ** decimals;
    }

    function withdrawAll() external {
        require(msg.sender == owner, "Who are you?");
        uint balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(msg.sender, balance);
    }
}