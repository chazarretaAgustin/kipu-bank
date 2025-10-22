// SPDX-License-Identifier: MIT (licencia)
pragma solidity 0.8.26;

// Importaciones de OpenZeppelin y Chainlink
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol"; // Imports the Ownable contract from OpenZeppelin, for using the onlyOwner modifier (Access Control)
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol"; // Multi-token Support: ERC-20 interface
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol"; // Security and efficiency for transfers
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol"; // Data Oracles

/**
 * @title KipuBankV2
 * @author Chazarreta Agustin
 * @notice Deposit contract that supports ETH and ERC20, with USD-based accounting and security limits.
 * @dev Inherits from Ownable for administrative access control.
 */
contract KipuBankV2 is Ownable {
    using SafeERC20 for IERC20; // To use SafeERC20's safe functions (safeTransfer)

    /*/// TYPES, VARIABLES, CONSTANTS ///*/

    /// @notice Represents the native token (ETH) in multi-token mappings.
    address internal constant ETH_TOKEN_ADDRESS = address(0);

    /**
        @notice Nested mappings: Store each user's balance per token (in token's units)
        mapping(user => mapping(token_address => balance_token_units))
      */
    mapping(address => mapping(address => uint256)) private s_tokenBalances;

    /// @notice Mapping to store the total deposited value by the user, standardized in USD (6 decimals)
    mapping(address => uint256) public s_totalDepositedUSD;

    /// @notice Immutable instance of the Chainlink ETH/USD Data Feed interface.
    AggregatorV3Interface immutable i_ethUsdFeed;

    /// @notice Global bank cap, in USD (6 decimals) and is constant.
    uint256 public constant BANK_CAP_USD = 10_000 * 10 ** 6; // (10,000 USD with 6 decimals)

    /// @notice Maximum withdrawal limit per transaction (constant)
    uint256 public constant WITHDRAWAL_LIMIT_PER_TX = 100 * 10 ** 6; // (100 USD (6 decimals))

    /// @notice Constant for internal accounting: 6 decimals (e.g. USDC)
    uint8 internal constant ACCOUNTING_DECIMALS = 6;

    /// @notice Conversion factor from ETH (18 dec) to accounting USD (6 decimals)
    /// @dev (18 ETH + 8 Feed) - 20 = 6 USD; therefore, the factor is 10^20.
    uint256 internal constant ETH_CONVERSION_FACTOR = 1 * 10 ** 20;

    /// @notice Data Feed heartbeat in seconds (1 hour)
    uint16 internal constant ORACLE_HEARTBEAT = 3600;

    /*/// EVENTS AND CUSTOM ERRORS ///*/

    /// @notice Event emitted when a deposit is successful
    event DepositExecuted(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 amountUSD
    );

    /// @notice Emitted when a withdrawal is successful
    event WithdrawalExecuted(
        address indexed user,
        address indexed token,
        uint256 amount
    );

    /// @notice Error when the total bank limit is exceeded (global cap)
    error GlobalLimitExceeded();

    /// @notice Error when the amount is less than or equal to 0
    error ZeroAmount();

    /// @notice Error when the withdrawal exceeds the per-transaction limit (in accounting USD)
    error WithdrawalLimitExceeded();

    /// @notice Error when the balance to withdraw is insufficient
    error InsufficientBalance();

    /// @notice Error when the oracle's return is incorrect (zero or negative)
    error OracleCompromised();

    /// @notice Error when the oracle's price is too old (stale)
    error StalePrice();

    /// @notice Error for failed ETH transfers
    error EthTransferFailed(bytes reason);

    /// @notice Error for ERC20 transfers that return false
    error ERC20TransferFailed();

    /*/// MODIFIERS AND ADMIN FUNCTIONS ///*/

    /**
     * @notice Modifier to check that the amount is not less than or equal to zero
     * @param _amount Amount to check
     */
    modifier nonZeroAmount(uint256 _amount) {
        if (_amount <= 0) {
            revert ZeroAmount();
        }
        _;
    }

    /**
     * @notice Allows the contract owner (and only the owner) to update the withdrawal limit per transaction
     * @dev Not strictly necessary, as the limit is constant. Can be used for other admin functions.
     * @param _newLimit New maximum withdrawal amount per transaction.
     */
    function adminWithdrawalLimitUpdate(uint256 _newLimit) public onlyOwner {
        // This function could be used to update configuration variables that are not immutable/constant, but depend exclusively on the owner.
        // Since all limits are constant, this function only exists for future extensions of administrative functions and compliance with the Access Control requirement.
    }

    /*/// CONSTRUCTOR ///*/

    /**
     * @notice Constructor
     * @notice Calls the Ownable constructor to indicate who the admin is
     * @param _ethUsdFeed Address of the Chainlink ETH/USD Data Feed
     * @param _owner Address of the owner (administrator)
     */
    constructor(address _ethUsdFeed, address _owner) Ownable(_owner) {
        i_ethUsdFeed = AggregatorV3Interface(_ethUsdFeed); // Immutable Chainlink Oracle Instance
    }

    /*/// SPECIAL FUNCTIONS ///*/

    /**
     * @notice Rejects any call to an undefined function or ETH sent with data.
     */
    fallback() external {
        revert();
    }

    /**
     * @notice Receive: Used for ETH deposits without function data
     */
    receive() external payable {
        _depositEth(msg.value);
    }

    /*/// DEPOSIT FUNCTIONS ///*/

    /**
     * @notice Internal function that allows you to deposit ether.
     * @param _amount Amount of ETH to deposit (in 18 decimals).
     */
    function _depositEth(uint256 _amount) internal nonZeroAmount(_amount) {
        if (msg.value != _amount) revert InsufficientBalance();

        uint256 amountUSD = getEthValueInUSD(_amount); // Determines the deposit value in USD

        // Global Limit Check (uses the USD value)
        if (s_totalDepositedUSD[msg.sender] + amountUSD > BANK_CAP_USD) {
            revert GlobalLimitExceeded();
        }

        s_tokenBalances[msg.sender][ETH_TOKEN_ADDRESS] += _amount; // Updates the user's ETH balance
        s_totalDepositedUSD[msg.sender] += amountUSD; // Updates the user's USD balance

        // Emits deposit executed event
        emit DepositExecuted(msg.sender, ETH_TOKEN_ADDRESS, _amount, amountUSD);
    }

    /**
     * @notice Allows a user to deposit Ether (ETH) into the bank.
     * @dev This function acts as an external wrapper for the internal logic (_depositEth) and ensures msg.value matches _amount.
     * @param _amount The amount of ETH to deposit, which must be equal to msg.value (in 18 decimals, Wei).
     */
    function depositEth(
        uint256 _amount
    ) external payable nonZeroAmount(_amount) {
        if (msg.value != _amount) revert InsufficientBalance();

        _depositEth(_amount);
    }

    /**
     * @notice Allows a user to deposit an ERC-20 token
     * @param _token Address of the ERC-20 token
     * @param _amount Amount of token to deposit
     * @param _amountUSD Deposit value in USD (6 decimals)
     * @dev Accounting is simplified assuming the token is USDC (6 decimals) and its price is 1 USD
     */
    function depositErc20(
        address _token,
        uint256 _amount,
        uint256 _amountUSD
    ) external nonZeroAmount(_amount) {
        if (_token == ETH_TOKEN_ADDRESS) revert ZeroAmount(); // Prevents using this function to deposit ETH

        // Global Limit Check (uses the USD value)
        if (s_totalDepositedUSD[msg.sender] + _amountUSD > BANK_CAP_USD) {
            revert GlobalLimitExceeded();
        }

        s_tokenBalances[msg.sender][_token] += _amount; // Stores in token units
        s_totalDepositedUSD[msg.sender] += _amountUSD; // Stores the total value in USD

        // Emits deposit executed event
        emit DepositExecuted(msg.sender, _token, _amount, _amountUSD);

        //Using SafeERC20
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount); // Transfers the token from the user to the contract using the SafeERC20 function
    }

    /*/// WITHDRAWAL FUNCTIONS ///*/

    /**
     * @notice Allows a user to withdraw a specific token
     * @param _token Address of the token to withdraw (address(0) for ETH)
     * @param _amount Amount to withdraw (in token units)
     */
    function withdraw(
        address _token,
        uint256 _amount
    ) external nonZeroAmount(_amount) {
        // Checks for sufficient balance
        uint256 currentBalance = s_tokenBalances[msg.sender][_token];
        if (currentBalance < _amount) revert InsufficientBalance();

        // Determines the USD value of the requested amount for the limit check
        uint256 amountUSD;
        if (_token == ETH_TOKEN_ADDRESS) {
            amountUSD = getEthValueInUSD(_amount);
        } else {
            amountUSD = _amount; // Assuming USDC (6 dec.) as the only ERC20
        }

        // Verifies withdrawal against the per-transaction limit
        if (amountUSD > WITHDRAWAL_LIMIT_PER_TX)
            revert WithdrawalLimitExceeded();

        //Update balances
        s_tokenBalances[msg.sender][_token] -= _amount;
        s_totalDepositedUSD[msg.sender] -= amountUSD;

        // Emits withdrawal executed event
        emit WithdrawalExecuted(msg.sender, _token, _amount);

        if (_token == ETH_TOKEN_ADDRESS) {
            (bool success, bytes memory reason) = payable(msg.sender).call{
                value: _amount
            }(""); // Secure handling of ETH transfer
            if (!success) {
                // Reverts the state if the transfer fails
                s_tokenBalances[msg.sender][_token] += _amount;
                s_totalDepositedUSD[msg.sender] += amountUSD;
                revert EthTransferFailed(reason);
            }
        } else {
            IERC20(_token).safeTransfer(msg.sender, _amount); // Secure handling of ERC-20 transfer
        }
    }

    /*/// VIEW AND ORACLE FUNCTIONS ///*/

    /**
     * @notice Returns the available balance of a specific token for the caller
     * @param _token Address of the token to query (address(0) for ETH).
     * @return The token balance.
     */
    function getBalance(address _token) external view returns (uint256) {
        return s_tokenBalances[msg.sender][_token];
    }

    /**
     * @notice Returns the total deposited value by the caller in USD (6 decimals)
     */
    function getTotalDepositedUSD() external view returns (uint256) {
        return s_totalDepositedUSD[msg.sender];
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
            ETH_CONVERSION_FACTOR; // Decimal Conversion: (ETH 18 dec * Price 8 dec) / (10^20) = USD 6 dec
    }

    /**
     * @notice Queries the ETH/USD price via Chainlink
     * @return The price of ETH in USD (8 decimals)
     */
    function getChainlinkPrice() public view returns (uint256) {
        (, int256 ethUSDPrice, , uint256 updatedAt, ) = i_ethUsdFeed
            .latestRoundData(); // Oracle call to get price and update timestamp

        if (ethUSDPrice <= 0) revert OracleCompromised(); // Avoids erroneous prices (zero or negative)
        if (block.timestamp - updatedAt > ORACLE_HEARTBEAT) revert StalePrice(); // Avoids stale prices

        return uint256(ethUSDPrice); // Returns the price in uint256 format
    }
}
