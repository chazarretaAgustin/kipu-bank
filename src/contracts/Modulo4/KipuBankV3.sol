// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// =================================================================================
//                                  IMPORTS
// =================================================================================

// KipuBankV2 Dependencies
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// KipuBankV3 (Uniswap V2) Dependencies
import {IUniswapV2Factory} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

// WETH Interface (required for swapping ETH in V2)
interface IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint256) external;
}

/**
 * @title KipuBankV3
 * @author Chazarreta Agustin
 * @notice DeFi deposit contract. Accepts ETH or ERC20s, converts them to USDC via Uniswap V2,
 * and manages internal USDC accounting, respecting global limits
 * @dev Inherits from Ownable and uses Uniswap V2 Factory/Pairs
 */
contract KipuBankV3 is Ownable {
    using SafeERC20 for IERC20;
    using SafeERC20 for IWETH;

    /*/// TYPES, VARIABLES, CONSTANTS ///*/

    /// @notice Mapping to store each user's balance, standardized in USDC (6 decimals)
    mapping(address => uint256) public s_balancesUSD;

    /// @notice Tracker for the total USDC held by the contract, for the global limit
    uint256 public s_totalBankUSD;

    /// @notice Global bank cap, in USD (6 decimals) and constant
    uint256 public constant BANK_CAP_USD = 10_000 * 10 ** 6; // (assuming 10,000 USD with 6 decimals)

    /// @notice Maximum withdrawal limit per transaction (constant)
    uint256 public constant WITHDRAWAL_LIMIT_PER_TX = 100 * 10 ** 6; // (assuming 100 USD with 6 decimals)

    /// @notice Constant for internal accounting (6 decimals)
    uint8 internal constant ACCOUNTING_DECIMALS = 6;

    // KipuBankV2 Dependencies (Chainlink)
    /// @notice Immutable instance of the Chainlink ETH/USD Data Feed interface.
    AggregatorV3Interface immutable i_ethUsdFeed;
    /// @dev (18 ETH + 8 Feed) - 20 = 6 USD; therefore, the factor is 10^20
    uint256 internal constant ETH_CONVERSION_FACTOR = 1 * 10 ** 20;
    /// @notice Data Feed heartbeat in seconds (1 hour)
    uint16 internal constant ORACLE_HEARTBEAT = 3600;

    // KipuBankV3 Dependencies (Uniswap V2)
    /// @notice Uniswap V2 Factory for getting pairs
    IUniswapV2Factory immutable i_factory;
    /// @notice Immutable instance of the USDC token (the reserve asset)
    IERC20 immutable i_usdc;
    /// @notice Immutable instance of the WETH token (for swapping ETH)
    IWETH immutable i_weth;

    /*/// EVENTS AND CUSTOM ERRORS ///*/

    /// @notice Emitted when a deposit (direct or post-swap) is successful
    event DepositExecuted(
        address indexed user,
        address indexed tokenIn,
        uint256 amountIn,
        uint256 amountUSDReceived
    );
    /// @notice Emitted when a USDC withdrawal is successful
    event WithdrawalExecuted(address indexed user, uint256 amountUSDC);

    // Errors (Reused from KipuBankV2 and new ones)
    error GlobalLimitExceeded();
    error ZeroAmount();
    error WithdrawalLimitExceeded();
    error InsufficientBalance();
    error OracleCompromised();
    error StalePrice();
    error EthTransferFailed(bytes reason);
    error PairDoesNotExist();
    error InsufficientSwapOutput();
    error InvalidToken(); // For duplicate tokens or ETH
    error SwapFailed();

    /*/// MODIFIERS AND ADMIN FUNCTIONS ///*/

    modifier nonZeroAmount(uint256 _amount) {
        if (_amount <= 0) {
            revert ZeroAmount();
        }
        _;
    }

    /*/// CONSTRUCTOR ///*/

    /**
     * @notice Constructor
     * @param _ethUsdFeed Chainlink ETH/USD Data Feed address
     * @param _owner Owner's address (administrator)
     * @param _factory Uniswap V2 Factory address
     * @param _usdc USDC token address (the reserve asset)
     * @param _weth WETH token address (for swapping ETH)
     */
    constructor(
        address _ethUsdFeed,
        address _owner,
        address _factory,
        address _usdc,
        address _weth
    ) Ownable(_owner) {
        i_ethUsdFeed = AggregatorV3Interface(_ethUsdFeed);
        i_factory = IUniswapV2Factory(_factory);
        i_usdc = IERC20(_usdc);
        i_weth = IWETH(_weth);
    }

    /*/// SPECIAL FUNCTIONS ///*/

    /// @notice Rejects any call to an undefined function or ETH sent with data
    fallback() external {
        revert();
    }

    /// @notice
    receive() external payable {
        revert();
    }

    /*/// DEPOSIT FUNCTIONS ///*/

    /**
     * @notice Allows a user to deposit USDC directly (the reserve asset)
     * @param _amount Amount of USDC to deposit (6 decimals)
     */
    function depositUSDC(uint256 _amount) external nonZeroAmount(_amount) {
        // Checks the global bank limit before the transfer
        if (s_totalBankUSD + _amount > BANK_CAP_USD) {
            revert GlobalLimitExceeded();
        }

        s_balancesUSD[msg.sender] += _amount;
        s_totalBankUSD += _amount;

        // Emit event
        emit DepositExecuted(msg.sender, address(i_usdc), _amount, _amount);

        // Transfers the USDC from the user to this contract
        i_usdc.safeTransferFrom(msg.sender, address(this), _amount);
    }

    /**
     * @notice Deposits ETH, swaps it for USDC, and credits the USD balance
     * @param _amountOutMin The minimum USDC amount accepted for the swap
     */
    function depositEthAndSwap(
        uint256 _amountOutMin
    ) external payable nonZeroAmount(msg.value) {
        uint256 amountIn = msg.value;

        // Global Limit Check (Pre-Swap using Chainlink)
        uint256 expectedUSD = getEthValueInUSD(amountIn);
        if (s_totalBankUSD + expectedUSD > BANK_CAP_USD) {
            revert GlobalLimitExceeded();
        }

        // Wrap ETH to WETH
        i_weth.deposit{value: amountIn}();

        // Execute the swap (WETH -> USDC)
        uint256 amountReceivedUSD = _executeSwap(
            address(i_weth),
            address(i_usdc),
            amountIn,
            _amountOutMin
        );

        // Updates balances with the actual swap result
        s_balancesUSD[msg.sender] += amountReceivedUSD;
        s_totalBankUSD += amountReceivedUSD;

        emit DepositExecuted(
            msg.sender,
            address(0),
            amountIn,
            amountReceivedUSD
        );
    }

    /**
     * @notice Deposits any ERC20, swaps it for USDC, and credits the USD balance
     * @param _tokenIn The address of the token to deposit
     * @param _amountIn The amount of Token to deposit
     * @param _amountOutMin The minimum USDC amount accepted
     */
    function depositErc20AndSwap(
        address _tokenIn,
        uint256 _amountIn,
        uint256 _amountOutMin
    ) external nonZeroAmount(_amountIn) {
        if (_tokenIn == address(0) || _tokenIn == address(i_usdc)) {
            revert InvalidToken();
        }

        // Global Limit Check (Post-Swap)
        // The check will be done after the swap

        // Transfer tokens (TokenIn) from the user to this contract
        IERC20(_tokenIn).safeTransferFrom(msg.sender, address(this), _amountIn);

        // Calls the internal swap logic (TokenIn -> USDC)
        uint256 amountReceivedUSD = _executeSwap(
            _tokenIn,
            address(i_usdc),
            _amountIn,
            _amountOutMin
        );

        // Global Limit Check (Post-Swap)
        if (s_totalBankUSD + amountReceivedUSD > BANK_CAP_USD) {
            // Reverts the transaction even if the swap was successful
            revert GlobalLimitExceeded();
        }

        s_balancesUSD[msg.sender] += amountReceivedUSD;
        s_totalBankUSD += amountReceivedUSD;

        emit DepositExecuted(
            msg.sender,
            _tokenIn,
            _amountIn,
            amountReceivedUSD
        );
    }

    /*/// Swap Logic (Internal) ///*/

    /**
     * @notice Internal swap logic using Uniswap V2 Pairs
     * @dev Swaps _tokenIn for _tokenOut (USDC)
     * @return amountOut The amount of USDC received
     */
    function _executeSwap(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _amountOutMin
    ) internal returns (uint256 amountOut) {
        // Get the Pair
        address pairAddress = i_factory.getPair(_tokenIn, _tokenOut);
        if (pairAddress == address(0)) {
            revert PairDoesNotExist();
        }
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);

        // Calculates the expected output amount, using the SwapModule function
        (uint256 reserveIn, uint256 reserveOut) = _getReserves(pair, _tokenIn);
        uint256 amountOutExpected = getAmountOut(
            _amountIn,
            reserveIn,
            reserveOut
        );

        if (amountOutExpected < _amountOutMin) {
            revert InsufficientSwapOutput();
        }

        // Approves the Pair to spend the TokenIn
        IERC20 tokenInContract = IERC20(_tokenIn);
        tokenInContract.approve(pairAddress, _amountIn);
        //SafeERC20.safeApprove(IERC20(_tokenIn), pairAddress, _amountIn);

        // Measures the USDC balance before the swap
        uint256 balanceBefore = i_usdc.balanceOf(address(this));

        // Performs the swap, determines the output amounts for the swap() function
        uint256 amount0Out;
        uint256 amount1Out;
        if (pair.token0() == _tokenIn) {
            amount0Out = 0;
            amount1Out = amountOutExpected;
        } else {
            amount0Out = amountOutExpected;
            amount1Out = 0;
        }

        // Sends the output tokens (USDC) to this contract (address(this))
        try pair.swap(amount0Out, amount1Out, address(this), "") {} catch {
            revert SwapFailed();
        }

        // Measures the USDC balance AFTER the swap
        uint256 balanceAfter = i_usdc.balanceOf(address(this));

        // Calculates the actual result
        amountOut = balanceAfter - balanceBefore;

        if (amountOut < _amountOutMin) {
            revert InsufficientSwapOutput(); // Double-check security post-swap
        }
    }

    /*/// WITHDRAWAL FUNCTIONS ///*/

    /**
     * @notice Allows a user to withdraw their balance (USDC only)
     * @param _amount Amount of USDC to withdraw (6 decimals)
     */
    function withdraw(uint256 _amount) external nonZeroAmount(_amount) {
        uint256 currentBalance = s_balancesUSD[msg.sender];
        if (currentBalance < _amount) revert InsufficientBalance();

        if (_amount > WITHDRAWAL_LIMIT_PER_TX) revert WithdrawalLimitExceeded();

        // Update balances before external interaction
        s_balancesUSD[msg.sender] -= _amount;
        s_totalBankUSD -= _amount;

        // Emits withdrawal executed event
        emit WithdrawalExecuted(msg.sender, _amount);

        // Secure handling of ERC-20 transfer (USDC)
        i_usdc.safeTransfer(msg.sender, _amount);
    }

    /*/// VIEW AND ORACLE FUNCTIONS  ///*/

    /**
     * @notice Returns the user's total balance in USD (6 decimals)
     */
    function getBalance() external view returns (uint256) {
        return s_balancesUSD[msg.sender];
    }

    /**
     * @notice Returns the value in USD (6 decimals) of an ETH amount
     * @param _ethAmount Amount of ETH (18 decimals)
     * @return convertedAmount_ Value in USD (6 decimals)
     */
    function getEthValueInUSD(
        uint256 _ethAmount
    ) public view returns (uint256 convertedAmount_) {
        uint256 ethPriceIn8Decimals = getChainlinkPrice(); // Price Query
        convertedAmount_ =
            (_ethAmount * ethPriceIn8Decimals) /
            ETH_CONVERSION_FACTOR;
    }

    /**
     * @notice Queries the ETH/USD price via Chainlink
     * @return The price of ETH in USD (8 decimals)
     */
    function getChainlinkPrice() public view returns (uint256) {
        (, int256 ethUSDPrice, , uint256 updatedAt, ) = i_ethUsdFeed
            .latestRoundData();
        if (ethUSDPrice <= 0) revert OracleCompromised();
        if (block.timestamp - updatedAt > ORACLE_HEARTBEAT) revert StalePrice();
        return uint256(ethUSDPrice);
    }

    /*/// AUXILIARY FUNCTIONS ///*/

    /**
     * @notice Auxiliary function to calculate the output amount
     * @dev Implements the Uniswap V2 AMM formula: amountOut = (amountIn * 997 * reserveOut) / (reserveIn * 1000 + amountIn * 997)
     */
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        if (amountIn == 0 || reserveIn == 0 || reserveOut == 0) {
            revert InsufficientBalance();
        }

        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = (reserveIn * 1000) + amountInWithFee;

        amountOut = numerator / denominator;
    }

    /**
     * @notice Auxiliary function to get the ordered reserves
     */
    function _getReserves(
        IUniswapV2Pair _pair,
        address _tokenIn
    ) internal view returns (uint256 reserveIn, uint256 reserveOut) {
        (uint256 reserve0, uint256 reserve1, ) = _pair.getReserves();

        if (_pair.token0() == _tokenIn) {
            reserveIn = reserve0;
            reserveOut = reserve1;
        } else {
            reserveIn = reserve1;
            reserveOut = reserve0;
        }
    }
}
