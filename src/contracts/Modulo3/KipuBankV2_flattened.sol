// File: @openzeppelin/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.4.0) (token/ERC20/IERC20.sol)

pragma solidity >=0.4.16;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

// File: @openzeppelin/contracts/interfaces/IERC20.sol

// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC20.sol)

pragma solidity >=0.4.16;

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol

// OpenZeppelin Contracts (last updated v5.4.0) (utils/introspection/IERC165.sol)

pragma solidity >=0.4.16;

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/interfaces/IERC165.sol

// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC165.sol)

pragma solidity >=0.4.16;

// File: @openzeppelin/contracts/interfaces/IERC1363.sol

// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC1363.sol)

pragma solidity >=0.6.2;

/**
 * @title IERC1363
 * @dev Interface of the ERC-1363 standard as defined in the https://eips.ethereum.org/EIPS/eip-1363[ERC-1363].
 *
 * Defines an extension interface for ERC-20 tokens that supports executing code on a recipient contract
 * after `transfer` or `transferFrom`, or code on a spender contract after `approve`, in a single transaction.
 */
interface IERC1363 is IERC20, IERC165 {
    /*
     * Note: the ERC-165 identifier for this interface is 0xb0202a11.
     * 0xb0202a11 ===
     *   bytes4(keccak256('transferAndCall(address,uint256)')) ^
     *   bytes4(keccak256('transferAndCall(address,uint256,bytes)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256,bytes)'))
     */

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(
        address to,
        uint256 value,
        bytes calldata data
    ) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(
        address from,
        address to,
        uint256 value,
        bytes calldata data
    ) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(
        address spender,
        uint256 value
    ) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @param data Additional data with no specified format, sent in call to `spender`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(
        address spender,
        uint256 value,
        bytes calldata data
    ) external returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol

// OpenZeppelin Contracts (last updated v5.3.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;

/**
 * @title SafeERC20
 * @dev Wrappers around ERC-20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    /**
     * @dev An operation with an ERC-20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(
        address spender,
        uint256 currentAllowance,
        uint256 requestedDecrease
    );

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeCall(token.transferFrom, (from, to, value))
        );
    }

    /**
     * @dev Variant of {safeTransfer} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal returns (bool) {
        return
            _callOptionalReturnBool(
                token,
                abi.encodeCall(token.transfer, (to, value))
            );
    }

    /**
     * @dev Variant of {safeTransferFrom} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal returns (bool) {
        return
            _callOptionalReturnBool(
                token,
                abi.encodeCall(token.transferFrom, (from, to, value))
            );
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 requestedDecrease
    ) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(
                    spender,
                    currentAllowance,
                    requestedDecrease
                );
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     *
     * NOTE: If the token implements ERC-7674, this function will not modify any temporary allowance. This function
     * only sets the "standard" allowance. Any temporary allowance will remain active, in addition to the value being
     * set here.
     */
    function forceApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        bytes memory approvalCall = abi.encodeCall(
            token.approve,
            (spender, value)
        );

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(
                token,
                abi.encodeCall(token.approve, (spender, 0))
            );
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Performs an {ERC1363} transferAndCall, with a fallback to the simple {ERC20} transfer if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferAndCallRelaxed(
        IERC1363 token,
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        if (to.code.length == 0) {
            safeTransfer(token, to, value);
        } else if (!token.transferAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} transferFromAndCall, with a fallback to the simple {ERC20} transferFrom if the target
     * has no code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferFromAndCallRelaxed(
        IERC1363 token,
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        if (to.code.length == 0) {
            safeTransferFrom(token, from, to, value);
        } else if (!token.transferFromAndCall(from, to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} approveAndCall, with a fallback to the simple {ERC20} approve if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * NOTE: When the recipient address (`to`) has no code (i.e. is an EOA), this function behaves as {forceApprove}.
     * Opposedly, when the recipient address (`to`) has code, this function only attempts to call {ERC1363-approveAndCall}
     * once without retrying, and relies on the returned value to be true.
     *
     * Reverts if the returned value is other than `true`.
     */
    function approveAndCallRelaxed(
        IERC1363 token,
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        if (to.code.length == 0) {
            forceApprove(token, to, value);
        } else if (!token.approveAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturnBool} that reverts if call fails to meet the requirements.
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            let success := call(
                gas(),
                token,
                0,
                add(data, 0x20),
                mload(data),
                0,
                0x20
            )
            // bubble errors
            if iszero(success) {
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, returndatasize())
                revert(ptr, returndatasize())
            }
            returnSize := returndatasize()
            returnValue := mload(0)
        }

        if (
            returnSize == 0 ? address(token).code.length == 0 : returnValue != 1
        ) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silently catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(
        IERC20 token,
        bytes memory data
    ) private returns (bool) {
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            success := call(
                gas(),
                token,
                0,
                add(data, 0x20),
                mload(data),
                0,
                0x20
            )
            returnSize := returndatasize()
            returnValue := mload(0)
        }
        return
            success &&
            (
                returnSize == 0
                    ? address(token).code.length > 0
                    : returnValue == 1
            );
    }
}

// File: @chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol

pragma solidity ^0.8.0;

// solhint-disable-next-line interface-starts-with-i
interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(
        uint80 _roundId
    )
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

// File: contracts/KipuBankV2.sol

pragma solidity 0.8.26;

// Importaciones de OpenZeppelin y Chainlink

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
