// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import "IFlashLoanRecipient.sol";
import "IBalancerVault.sol";

interface Approval {
    function approve (address spender, uint256 rawAmount) external;
}

interface swapme {
    function setTokenIn(address _tokenIn) external;
    function setTokenOut(address _tokenOut) external;
    function setPoolFee(uint24 _poolFee) external;
    function swapExactInputSingle(uint256 amountIn) external returns (uint256 amountOut);
    function getTokenBalance(address tokenAddress, address account) external returns (uint256);
}

contract BalancerFlashLoan is IFlashLoanRecipient {
    using SafeMath for uint256;
    using SafeMath for uint16;
    IERC20 public token;
    
    address public daiContractAddress = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;
    address public weth9ContractAddress = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270; // Reemplaza con la dirección real
    address public immutable vault;
    address private owner;
    address public meswapContractAddress;

    constructor(address _vault) {
        vault = _vault;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    function setMeSwap(address _meswapContractAddress) external onlyOwner {
        meswapContractAddress = _meswapContractAddress;
    }

    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory
        ) external override {
        for (uint256 i = 0; i < tokens.length; ++i) {
            IERC20 token = tokens[i];
            uint256 amount = amounts[i];
            uint256 feeAmount = feeAmounts[i];

            executedata();
            executeswap();
            executedata2();
            executeswap2();

            token.transfer(vault, amount);
        }
    }

    function flashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        bytes memory userData
    ) external {
        IBalancerVault(vault).flashLoan(
            IFlashLoanRecipient(address(this)),
            tokens,
            amounts,
            userData
        );
    }

    function executedata() public {
        swapme meswap = swapme(meswapContractAddress);
        meswap.setTokenIn(0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063);
        meswap.setTokenOut(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270);
        meswap.setPoolFee(10000);
    }

    function executeswap() public {
        Approval dai = Approval(daiContractAddress);
        dai.approve(address(this), 10000000000000000000000);
        dai.approve(0xBA12222222228d8Ba445958a75a0704d566BF2C8, 10000000000000000000000);
        dai.approve(meswapContractAddress, 10000000000000000000000);

        Approval weth9 = Approval(weth9ContractAddress);
        weth9.approve(address(this), 10000000000000000000000);
        weth9.approve(0xBA12222222228d8Ba445958a75a0704d566BF2C8, 10000000000000000000000);
        weth9.approve(meswapContractAddress, 10000000000000000000000);

        swapme meswap = swapme(meswapContractAddress);
        meswap.swapExactInputSingle(1000000000000000000);
    }

    
    function executedata2() public {
        swapme meswap = swapme(meswapContractAddress);
        meswap.setTokenIn(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270);
        meswap.setTokenOut(0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063);
        meswap.setPoolFee(10000);
    }
    
    // Luego defines executeswap2
    function executeswap2() public {
        Approval dai = Approval(daiContractAddress);
        dai.approve(address(this), 10000000000000000000000);
        dai.approve(vault, 10000000000000000000000);
        dai.approve(meswapContractAddress, 10000000000000000000000);

        Approval weth9 = Approval(weth9ContractAddress);
        weth9.approve(address(this), 10000000000000000000000);
        weth9.approve(vault, 10000000000000000000000);
        weth9.approve(meswapContractAddress, 10000000000000000000000);

        swapme meswap = swapme(meswapContractAddress);
        meswap.swapExactInputSingle(meswap.getTokenBalance(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270, address(this)));
    }

    function getTokenBalance(address tokenAddress, address account) public view returns (uint256) {
    IERC20 token = IERC20(tokenAddress);
    return token.balanceOf(account);
    }

 
    function approve(address spender, IERC20[] memory tokens, uint256[] memory amounts) external {
        require(tokens.length == amounts.length, "Token and amount arrays must have the same length");

        for (uint256 i = 0; i < tokens.length; i++) {
            tokens[i].approve(spender, amounts[i]);
        }
    }

    function withdrawERC20(IERC20[] memory tokens, uint256[] memory amounts) external onlyOwner {
        require(tokens.length == amounts.length, "Token and amount arrays must have the same length");

        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 balance = tokens[i].balanceOf(address(this));
            require(balance >= amounts[i], "Insufficient token balance");

            tokens[i].transfer(msg.sender, amounts[i]);
        }
    }
    
    receive() external payable {
        // Esta función permite que el contrato reciba Ether cuando se le envía directamente.
    }
}
