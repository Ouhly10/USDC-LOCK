// SPDX-License-Identifier: MIT
pragma solidity 0.8.35;

/// @title USDCTimeLockV4
/// @notice Locks USDC or USDT — whichever the caller chooses per lock — for a beneficiary
///         until a chosen unlock time, inside ONE shared contract instead of one separately
///         deployed instance per token. Nobody — not even the contract deployer — can withdraw
///         before that time, and only the beneficiary can withdraw after it.
/// @dev This is V3's logic unchanged, restructured so a single deployment (constructor takes
///      BOTH the USDC and USDT addresses) serves every lock for both tokens, instead of one
///      instance per token. Each lock now records which of the two tokens it holds.
///      Two defense-in-depth additions versus the original V2 contract (V2's logic was already
///      safe, these are extra insurance, not fixes to a known bug):
///        1. `_safeTransfer`/`_safeTransferFrom` tolerate tokens that don't strictly return a
///           bool on transfer (some deployed USDT contracts historically don't), instead of a
///           plain interface call that would revert on missing return data.
///        2. An explicit `nonReentrant` guard on the three state-changing functions, on top of
///           the checks-effects-interactions ordering already used throughout.
contract USDCTimeLockV4 {
    struct Lock {
        address beneficiary;
        address token;
        uint256 amount;
        uint256 unlockTime;
        bool withdrawn;
    }

    /// @notice The two ERC-20 tokens this contract accepts. Fixed at deployment.
    address public immutable usdc;
    address public immutable usdt;

    /// @notice Number of locks ever created in this contract (also the next lock's id).
    uint256 public lockCount;

    /// @notice lockId => Lock details.
    mapping(uint256 => Lock) public locks;

    event Locked(uint256 indexed id, address indexed beneficiary, address indexed token, uint256 amount, uint256 unlockTime);
    event ToppedUp(uint256 indexed id, uint256 addedAmount, uint256 newTotal);
    event Withdrawn(uint256 indexed id, address indexed beneficiary, uint256 amount);

    uint256 private _reentrancyStatus = 1; // 1 = unlocked, 2 = locked

    modifier nonReentrant() {
        require(_reentrancyStatus == 1, "Reentrant call");
        _reentrancyStatus = 2;
        _;
        _reentrancyStatus = 1;
    }

    /// @param _usdc Address of the USDC token on this network.
    /// @param _usdt Address of the USDT token on this network.
    constructor(address _usdc, address _usdt) {
        require(_usdc != address(0) && _usdt != address(0), "Zero token address");
        require(_usdc != _usdt, "Tokens must differ");
        usdc = _usdc;
        usdt = _usdt;
    }

    function _isAllowedToken(address token) private view returns (bool) {
        return token == usdc || token == usdt;
    }

    /// @notice Creates a new lock, pulling `amount` of `token` from the caller into this
    ///         contract to be held for `beneficiary` until `unlockTime`.
    /// @dev Caller must have approved this contract for at least `amount` beforehand.
    ///      `token` must be exactly the configured USDC or USDT address.
    function lock(address token, address beneficiary, uint256 amount, uint256 unlockTime) external nonReentrant {
        require(_isAllowedToken(token), "Unsupported token");
        require(beneficiary != address(0), "Zero beneficiary");
        require(unlockTime > block.timestamp, "Must be future");
        require(amount > 0, "Amount > 0");

        uint256 id = lockCount;
        locks[id] = Lock({
            beneficiary: beneficiary,
            token: token,
            amount: amount,
            unlockTime: unlockTime,
            withdrawn: false
        });
        lockCount = id + 1;

        _safeTransferFrom(token, msg.sender, address(this), amount);

        emit Locked(id, beneficiary, token, amount, unlockTime);
    }

    /// @notice Adds more of the lock's token to an existing, not-yet-matured, not-yet-withdrawn lock.
    /// @dev Anyone may top up any lock (e.g. the "Chip in" feature) — funds still only ever go
    ///      to that lock's original beneficiary once it matures.
    function topUp(uint256 lockId, uint256 amount) external nonReentrant {
        Lock storage l = locks[lockId];
        require(amount > 0, "Amount > 0");
        require(!l.withdrawn, "Already withdrawn");
        require(block.timestamp < l.unlockTime, "Not mature");

        l.amount += amount;

        _safeTransferFrom(l.token, msg.sender, address(this), amount);

        emit ToppedUp(lockId, amount, l.amount);
    }

    /// @notice Withdraws a matured lock's full balance to its beneficiary.
    /// @dev Only the beneficiary can call this, and only after `unlockTime`. State is updated
    ///      before the external transfer (checks-effects-interactions).
    function withdraw(uint256 lockId) external nonReentrant {
        Lock storage l = locks[lockId];
        require(l.beneficiary == msg.sender, "Not beneficiary");
        require(block.timestamp >= l.unlockTime, "Not mature");
        require(!l.withdrawn, "Already withdrawn");

        l.withdrawn = true;

        _safeTransfer(l.token, l.beneficiary, l.amount);

        emit Withdrawn(lockId, l.beneficiary, l.amount);
    }

    /// @notice Reads back a lock's details.
    /// @return beneficiary The address entitled to withdraw once matured.
    /// @return token The ERC-20 token this lock holds (usdc or usdt).
    /// @return amount The total token amount currently held for this lock.
    /// @return unlockTime The unix timestamp after which withdrawal is allowed.
    /// @return withdrawn Whether this lock has already been withdrawn.
    function getLock(uint256 id)
        external
        view
        returns (address beneficiary, address token, uint256 amount, uint256 unlockTime, bool withdrawn)
    {
        Lock storage l = locks[id];
        return (l.beneficiary, l.token, l.amount, l.unlockTime, l.withdrawn);
    }

    // ── internal safe-transfer helpers ──
    // Tolerate ERC-20 tokens that don't strictly return a bool (some non-standard deployments
    // of USDT historically don't), by accepting either no return data or a true bool, and
    // always requiring the call itself to succeed.

    function _safeTransfer(address token, address to, uint256 amount) private {
        (bool ok, bytes memory data) =
            token.call(abi.encodeWithSignature("transfer(address,uint256)", to, amount));
        require(ok && (data.length == 0 || abi.decode(data, (bool))), "Transfer failed");
    }

    function _safeTransferFrom(address token, address from, address to, uint256 amount) private {
        (bool ok, bytes memory data) =
            token.call(abi.encodeWithSignature("transferFrom(address,address,uint256)", from, to, amount));
        require(ok && (data.length == 0 || abi.decode(data, (bool))), "TransferFrom failed");
    }
}
