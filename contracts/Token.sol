// SPDX-License-Identifier: MIT
// This file is for test
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 10000 * (10**18));
    }

    function faucet(address recipient, uint256 amount) external {
        _mint(recipient, amount);
    }
}
