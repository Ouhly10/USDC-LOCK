# 🔒 USDC Savings Tool — Polygon Time-Lock

**A secure, trustless USDC time-lock on the Polygon network — no one can withdraw before the set date, not even you.**

A single-file HTML web app that lets you lock any amount of USDC inside a smart contract on Polygon until a date and time you choose — no server, no middleman. Everything runs directly in your browser and interacts with the smart contract via the ethers.js library.

---

## ✨ Why this tool?

- 💪 **Real financial discipline** — once locked, your funds can't move before the deadline. No "just this once" withdrawals.
- 🔗 **No middleman, no third party** — the smart contract is the only judge; no team or company controls your funds.
- 🌐 **Works anywhere** — a single HTML file that opens in any browser, no install, no account.
- 🌗 **Clean, responsive UI** — light and dark mode support.
- 🧾 **Full transparency** — every transaction is on-chain and verifiable on Polygonscan.

---

## ⚙️ How it works

1. **Create a lock**
   Set the **amount**, the **beneficiary** (yourself or another address), and the **release date & time**. The app deploys a dedicated lock contract on Polygon.

2. **Approve, then deposit**
   Before locking, the contract needs approval to move your USDC (a separate `Approve` transaction), followed by the `Lock` transaction itself — each costs a tiny network fee (~$0.001).

3. **Wait for the unlock date**
   The **Monitor** tab shows the lock's status, amount, beneficiary, and a countdown to the **release date & time**.

4. **Top up anytime**
   You can add more USDC to the same lock at any point before release, without creating a new one.

5. **Withdraw**
   Once the deadline arrives, the withdraw button unlocks and the beneficiary can claim the full balance straight to their wallet.

---

## 🧠 The Smart Contract

| Field | Value |
|---|---|
| **Name** | `USDCTimeLock` |
| **Mainnet** | Polygon Mainnet |
| **Testnet** | Polygon Amoy Testnet |
| **Core functions** | `lock()` · `topUp()` · `withdraw()` · `getLock()` |
| **Events** | `Locked` · `Withdrawn` · `ToppedUp` |
| **Gas token** | POL |

> Every lock you create deploys its own unique contract address — always save a copy of it. It's your only key to tracking or withdrawing from that lock later.

---

## 🖥️ Screens

| Monitor | Deposit |
|---|---|
| View amount, beneficiary, and countdown to withdrawal | Set the lock amount and release date |

*(Add UI screenshots here)*

---

## 🛡️ Important Security Notes

- ⚠️ **The storage address is a smart contract, not a regular wallet.** Never send USDC to it as a plain transfer from a wallet or exchange — any balance sent that way **cannot be recovered**. Always use the "Top Up" tab inside the app itself.
- 🔑 **Save the contract address** as soon as you create a lock. If you lose it, search your wallet's transaction history for the address that created it, under `contract`, `lock`, or `call`.
- ⛽ The address (creator or beneficiary) needs a small amount of **POL** to cover network fees when creating or withdrawing from a lock.
- 🧩 The app supports logging in via a **Seed Phrase** or a **Private Key** directly — both are processed entirely in your browser and never sent to any server.

---

## 🛠️ Tech Stack

- **HTML / CSS / JavaScript** — a single file, no build step, no installed dependencies.
- **[ethers.js](https://docs.ethers.org/)** — for interacting with the network and the smart contract.
- **Polygon Mainnet / Amoy Testnet** — via multiple RPC providers with automatic fallback.

---

## 🚀 Quick Start

1. Open `index.html` in any modern browser.
2. Choose a network: **Mainnet** for real use, or **Testnet** to try it safely first.
3. From the **Deposit** tab, create your first lock with a small amount to get comfortable with the flow.
4. Track your lock from the **Monitor** tab until the release date.

---

## 📜 Disclaimer

This tool interacts directly with a smart contract on a public network (Polygon). No party can reverse a transaction or recover funds sent by mistake. Use it at your own risk, and always start with small amounts on the testnet before using mainnet.
