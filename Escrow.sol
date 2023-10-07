// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

contract EscrowContract is Ownable {
    address public strTokenAddress;
    uint256 public strTokenPrice;
    uint256 public adminFeePercentage = 5; // 5% admin fee

    IUniswapV2Router02 public uniswapRouter;
    IUniswapV2Pair public lpToken;

    mapping(address => Transaction[]) public userTransactions;

    struct Transaction {
        bool isBuy;
        uint256 amount;
        uint256 timestamp;
    }

    constructor(
        address _strTokenAddress,
        uint256 _initialStrTokenPrice,
        address _uniswapRouterAddress
        // address _lpTokenAddress
    ) Ownable(msg.sender) {
        strTokenAddress = _strTokenAddress;
        strTokenPrice = _initialStrTokenPrice;
        uniswapRouter = IUniswapV2Router02(_uniswapRouterAddress);
        // lpToken = IUniswapV2Pair(_lpTokenAddress);
    }



function addTokens(uint256 _amount) external onlyOwner {
    require(_amount > 0, "Amount must be greater than zero");
    IERC20 token = IERC20(strTokenAddress);
    token.approve(address(this), _amount);
    token.transferFrom(owner(), address(this), _amount);
}

    function setAdminFeePercentage(uint256 _feePercentage) external onlyOwner {
        adminFeePercentage = _feePercentage;
    }

    function buyTokens(uint256 _amount) external payable  {
        require(_amount > 0, "Amount must be greater than 0");
        uint256 totalPrice = (_amount * strTokenPrice) / 1e18;
        uint256  fee = (totalPrice * 5 ) / 100;
        uint256 toReceive = totalPrice + fee;
        require(
            msg.value >= toReceive,
            "Insufficient fund sent"
        );
        uint256 amountInWei= _amount*1e18;
        uint256 deadline = block.timestamp + 300; // 5 minutes
        require(
            IERC20(strTokenAddress).approve(address(uniswapRouter), _amount),
            "Approval failed"
        );
        uniswapRouter.addLiquidityETH{value: totalPrice}(
            strTokenAddress,
            _amount,
            0,
            0,
            owner(),
            deadline
        );
        
        payable(owner()).transfer(fee);
         IERC20(strTokenAddress).transfer(
            msg.sender,
            _amount
        );
    }

  
 


}
