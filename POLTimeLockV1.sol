// SPDX-License-Identifier: MIT
pragma solidity 0.8.35;

/// @title POLTimeLockV1
/// @notice Locks native POL (the Polygon network's own gas coin) for a beneficiary until a
///         chosen unlock time. Nobody — not even the contract deployer — can withdraw before
///         that time, and only the beneficiary can withdraw after it.
/// @dev Sibling contract to USDCTimeLockV4, but for the native coin instead of an ERC-20.
///      Because POL is native, there is no "approve" step and no token address: `lock`/`topUp`
///      simply take POL as `msg.value` instead of pulling an ERC-20 via transferFrom, and
///      `withdraw` sends it back with a low-level `call`. Everything else — the Lock struct
///      shape, the beneficiary-based lookup model, the checks-effects-interactions ordering,
///      and the `nonReentrant` guard on every state-changing function — mirrors V4 exactly so
///      the two contracts behave the same way from the frontend's point of view.
contract POLTimeLockV1 {
    struct Lock {
        address beneficiary;
        uint256 amount;
        uint256 unlockTime;
        bool withdrawn;
    }

    /// @notice Number of locks ever created in this contract (also the next lock's id).
    uint256 public lockCount;

    /// @notice lockId => Lock details.
    mapping(uint256 => Lock) public locks;

    event Locked(uint256 indexed id, address indexed beneficiary, uint256 amount, uint256 unlockTime);
    event ToppedUp(uint256 indexed id, uint256 addedAmount, uint256 newTotal);
    event Withdrawn(uint256 indexed id, address indexed beneficiary, uint256 amount);

    uint256 private _reentrancyStatus = 1; // 1 = unlocked, 2 = locked

    modifier nonReentrant() {
        require(_reentrancyStatus == 1, "Reentrant call");
        _reentrancyStatus = 2;
        _;
        _reentrancyStatus = 1;
    }

    /// @notice Creates a new lock, holding `msg.value` POL for `beneficiary` until `unlockTime`.
    function lock(address beneficiary, uint256 unlockTime) external payable nonReentrant {
        require(beneficiary != address(0), "Zero beneficiary");
        require(unlockTime > block.timestamp, "Must be future");
        require(msg.value > 0, "Amount > 0");

        uint256 id = lockCount;
        locks[id] = Lock({
            beneficiary: beneficiary,
            amount: msg.value,
            unlockTime: unlockTime,
            withdrawn: false
        });
        lockCount = id + 1;

        emit Locked(id, beneficiary, msg.value, unlockTime);
    }

    /// @notice Adds more POL (`msg.value`) to an existing, not-yet-matured, not-yet-withdrawn lock.
    /// @dev Anyone may top up any lock (e.g. the "Chip in" feature) — funds still only ever go
    ///      to that lock's original beneficiary once it matures.
    function topUp(uint256 lockId) external payable nonReentrant {
        Lock storage l = locks[lockId];
        require(msg.value > 0, "Amount > 0");
        require(!l.withdrawn, "Already withdrawn");
        require(block.timestamp < l.unlockTime, "Not mature");

        l.amount += msg.value;

        emit ToppedUp(lockId, msg.value, l.amount);
    }

    /// @notice Withdraws a matured lock's full POL balance to its beneficiary.
    /// @dev Only the beneficiary can call this, and only after `unlockTime`. State is updated
    ///      before the external transfer (checks-effects-interactions).
    function withdraw(uint256 lockId) external nonReentrant {
        Lock storage l = locks[lockId];
        require(l.beneficiary == msg.sender, "Not beneficiary");
        require(block.timestamp >= l.unlockTime, "Not mature");
        require(!l.withdrawn, "Already withdrawn");

        l.withdrawn = true;
        uint256 amount = l.amount;

        (bool ok, ) = payable(l.beneficiary).call{value: amount}("");
        require(ok, "Transfer failed");

        emit Withdrawn(lockId, l.beneficiary, amount);
    }

    /// @notice Reads back a lock's details.
    /// @return beneficiary The address entitled to withdraw once matured.
    /// @return amount The total POL amount currently held for this lock.
    /// @return unlockTime The unix timestamp after which withdrawal is allowed.
    /// @return withdrawn Whether this lock has already been withdrawn.
    function getLock(uint256 id)
        external
        view
        returns (address beneficiary, uint256 amount, uint256 unlockTime, bool withdrawn)
    {
        Lock storage l = locks[id];
        return (l.beneficiary, l.amount, l.unlockTime, l.withdrawn);
    }

    // No receive()/fallback() on purpose: plain transfers (e.g. from an exchange) must be
    // rejected so users don't accidentally send POL with no lock record and no way back —
    // exactly like the USDC/USDT contract's warning about not sending funds as a bare transfer.
}
