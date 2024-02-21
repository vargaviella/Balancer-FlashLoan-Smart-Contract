# Balancer-FlashLoan-Smart-Contract
This smart contract implements flash loan functionality using Balancer and Uniswap V3. It allows users to borrow tokens from the Balancer vault, execute swaps on Uniswap V3, and repay the loan within the same transaction.

# Features:

Flash Loan Functionality: Users can borrow tokens from the Balancer vault using the flashLoan function.
Swap Execution: The contract executes swaps on Uniswap V3 using the executeswap and executeswap2 functions.
Token Approval: Tokens are approved for transfer using the approve function.
Token Withdrawal: Contract owner can withdraw ERC20 tokens using the withdrawERC20 function.

# Smart Contract Details:

SPDX-License-Identifier: MIT
Solidity Version: ^0.8.0

# Dependencies:

OpenZeppelin Contracts: ERC20 token interfaces and SafeMath library.
Uniswap V3 Periphery: Swap router and transfer helper.
Interfaces: IFlashLoanRecipient, IBalancerVault, Approval, and swapme.

# Usage:

Deploy the smart contract, providing the Balancer vault address.
Set the address of the MeSwap contract using setMeSwap.
Call flashLoan to borrow tokens.
Swaps are executed automatically within the flash loan transaction.
Repay the loan by transferring tokens to the Balancer vault.

# Authors:
Vargaviella

# License:
MIT License

# Contributing:
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

# Acknowledgements:

OpenZeppelin for providing the ERC20 token interfaces and SafeMath library.
Uniswap for the V3 Periphery contracts.
Balancer for the flash loan functionality.
