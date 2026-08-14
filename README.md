# USDC & USDT Time-Lock

A non-custodial USDC and USDT time-lock built on the Polygon network. Lock any amount until a date and time you choose — no server, no middleman, no company that can touch your funds. Everything runs client-side in the browser and talks directly to a smart contract via ethers.js.

Live app: [usdtimelock.com](https://usdtimelock.com)

## Why this exists

Self-custody is supposed to mean nobody else controls your money — but it also means nothing stops you from moving it the moment willpower runs out. This tool adds that missing piece: once funds are locked, the smart contract is the only judge of when they can move again. There is no override, no admin key, no "just this once."

## Core features

- **Real, enforced discipline.** Funds are held by a dedicated smart contract until the exact unlock date and time you set. No wallet, exchange, or third party — including the developer — has any way to release them early.
- **Dual-token support.** Lock either USDC or USDT, switchable from the same interface.
- **A dedicated contract per lock.** Every lock you create deploys its own independent contract instance on Polygon, scoped to a single beneficiary and a single token.
- **Top up anytime.** Add more balance to an existing lock before its release date without creating a new one or resetting the countdown.
- **Full withdrawal control.** Only the designated beneficiary address can withdraw, and only after the unlock time has passed.
- **Live monitoring.** Track amount, beneficiary, and a running countdown to release for any lock you've created, from the Monitor tab.
- **Multi-wallet support.** Connect with MetaMask, Trust Wallet, or Coinbase Wallet. When no wallet is detected in the current browser, the app opens the page directly inside the chosen wallet's own in-app browser instead of relying on a fragile remote connector.
- **No server, no backend, no account.** A single-page application that runs entirely in the browser. Nothing about your lock is stored anywhere except on-chain.
- **Full on-chain transparency.** Every transaction, every lock, and every withdrawal is verifiable independently on Polygonscan.
- **Mainnet and testnet.** Try the full flow risk-free on Polygon Amoy Testnet before using real funds on Polygon Mainnet.
- **Installable as an app.** Configured as a PWA with home-screen install support on iOS and Android.
- **Light and dark mode**, following the system preference automatically.

## How it works

1. **Create a lock.** Choose the token (USDC or USDT), the amount, the beneficiary address (yourself or someone else), and the exact release date and time. The app deploys a new, dedicated lock contract on Polygon for this lock alone.
2. **Approve, then deposit.** Two on-chain transactions: an Approve transaction authorizing the contract to move the chosen amount, followed by the Lock transaction that actually deposits it. Each costs a small Polygon network fee, typically a fraction of a cent.
3. **Wait it out.** The Monitor tab shows every lock's status, balance, beneficiary, and a live countdown to its release date.
4. **Top up whenever you like.** Add more of the same token to an existing lock at any point before its release, without touching the unlock date.
5. **Withdraw once unlocked.** When the release time arrives, the withdraw button activates and the beneficiary claims the full balance directly to their wallet.

## The smart contract

| Field | Value |
|---|---|
| Contracts | `USDCTimeLock`, `USDTTimeLock` |
| Network (mainnet) | Polygon Mainnet |
| Network (testnet) | Polygon Amoy Testnet |
| Core functions | `lock()`, `topUp()`, `withdraw()`, `getLock()` |
| Events | `Locked`, `Withdrawn`, `ToppedUp` |
| Gas token | POL |


## Wallet connections

The app never asks for a seed phrase, a private key, or any custodial detail. Connecting works one of two ways:

- **Injected provider.** If the page is opened from inside a wallet's own browser (or a desktop extension is present), the connection is immediate and direct — no third-party relay involved.
- **Deep link into the wallet app.** If no wallet is detected in the current browser (for example, plain mobile Safari or Chrome), choosing MetaMask, Trust Wallet, or Coinbase Wallet reopens this same page inside that wallet's dedicated in-app browser, where the connection then becomes direct and injected as above.

This avoids the reliability issues of generic remote wallet connectors, particularly on iOS Safari.

## Security notes

- The storage address created for a lock is a **smart contract, not a personal wallet**. Never send USDC or USDT to it as a plain transfer from an exchange or another wallet — funds sent that way cannot be recovered. Always add balance through the Top Up tab inside the app.

- The address funding or withdrawing a lock needs a small amount of POL to cover Polygon network fees.
- For an extra layer of separation, consider creating a lock from a dedicated wallet with a different beneficiary address than your daily-use wallet.

## Tech stack

- **HTML, CSS, and vanilla JavaScript** — a single-page application, no build step, no framework, no bundler.
- **ethers.js v6** — all contract deployment, reads, and transactions.
- **Polygon Mainnet and Amoy Testnet**, accessed through multiple public RPC endpoints with automatic fallback for reliability.
- **GitHub Pages**, served at [usdtimelock.com](https://usdtimelock.com).

## Getting started

1. Open the app at [usdtimelock.com](https://usdtimelock.com), or serve `index.html` locally from any static file server.
2. Pick a network — Amoy Testnet to try the full flow risk-free, or Mainnet for real funds.
3. Connect a wallet: MetaMask, Trust Wallet, or Coinbase Wallet.
4. From the New Lock tab, create a small test lock to get comfortable with the flow before committing meaningful amounts.
5. Track it from the Monitor tab until release, then withdraw.
## Donate *    
USDC Storage address: 0xA0241d826A466F6FcEDcaF5610c914aA8c334E0b ,
USDT Storage address: 0x704f31256aBdE50cbc7923310A7B9CF9586f9E82 ,
          *Contract addresses, don’t send normal transaction. 🙏🏻

## Disclaimer

This tool interacts directly with smart contracts on a public blockchain. No transaction can be reversed, and no party — including the developer of this tool — can recover funds sent in error. Use it at your own risk, verify contract addresses independently, and start with small amounts on the testnet before using real funds on mainnet.

## License

Copyright 2026. Fully open source — free to use and modify for personal and non-commercial purposes only. Commercial copying or resale is not permitted.
