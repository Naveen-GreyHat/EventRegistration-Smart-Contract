# EventRegistration Smart Contract  

A complete blockchain-based event registration system built using **Solidity**, **Hardhat**, and **Ethers.js (v6)**.  
Users can register for an event by paying **0.01 ETH**, and the contract stores the total number of participants.

---

## 🚀 Features
- Users register by paying **exactly 0.01 ETH**
- Prevents duplicate registrations
- Emits `Registered(address user, uint256 time)` on each successful registration
- Tracks the total number of registered participants
- Contract owner = deployer address
- Fully compatible with Hardhat + Ethers v6

---

## 🛠 Tech Stack
- Solidity ^0.8.19  
- Node.js  
- Hardhat  
- Ethers.js v6  
- Hardhat Local Blockchain  

---

## 📂 Project Folder Structure

```

EventRegistration/
│
├── contracts/
│   └── EventRegistration.sol
│
├── scripts/
│   └── deploy.js
│
├── test/
│   └── EventRegistration.test.js (optional)
│
├── hardhat.config.js
├── package.json
└── README.md

````

---

## 📥 Installation & Setup

### 1️⃣ Clone Repository
```bash
git clone https://github.com/Naveen-GreyHat/EventRegistration-Smart-Contract
cd EventRegistration
````

### 2️⃣ Install Dependencies

```bash
npm install
```

---

## ⚡ Hardhat Commands

### 🔹 Compile Smart Contract

```bash
npx hardhat compile
```

### 🔹 Start Local Blockchain (Keep this window open)

```bash
npx hardhat node
```

### 🔹 Deploy Contract (New terminal window)

```bash
npx hardhat run scripts/deploy.js --network localhost
```

Successful deployment output example:

```
🚀 Starting EventRegistration deployment...
💰 Account balance: 10000 ETH
✅ EventRegistration deployed to: 0x5FbDB2315...
🎫 Registration fee: 0.01 ETH
👑 Contract owner: 0xf39F...
```

---

## 🧪 Interacting with the Contract (Hardhat Console)

### 1️⃣ Start Hardhat Console

```bash
npx hardhat console --network localhost
```

### 2️⃣ Load Contract

```javascript
const contract = await ethers.getContractAt(
  "EventRegistration",
  "DEPLOYED_CONTRACT_ADDRESS"
);
```

### 3️⃣ Register User (Pay 0.01 ETH)

```javascript
await contract.register({ value: ethers.parseEther("0.01") });
```

### 4️⃣ Get Total Participants

```javascript
(await contract.getParticipantCount()).toString();
```

### 5️⃣ Check Contract Owner

```javascript
await contract.owner();
```

---

## 🧩 Smart Contract Details

### **Functions**

#### 🟢 register()

Allows a user to register only if:

* Sent value = **0.01 ETH**
* User has **not registered before**

Triggers:

```
event Registered(address user, uint256 time)
```

#### 🟢 getParticipantCount()

Returns:

```
uint256 totalParticipants
```

#### 🟢 owner()

Returns:

```
address contractOwner
```

---

## 📝 Registration Fee Logic

```solidity
require(msg.value == 0.01 ether, "Registration costs 0.01 ETH");
require(!registered[msg.sender], "Already registered");
```

---

## 🧪 Testing (Optional)

If you add test files inside `/test`, run:

```bash
npx hardhat test
```

---

## 🌐 Deploy to Sepolia Testnet (Optional)

Add your RPC + Private key in `.env`, then:

```bash
npx hardhat run scripts/deploy.js --network sepolia
```

---

## 🎯 Conclusion

The **EventRegistration** project demonstrates:

* Smart contract payments
* Event emission
* Wallet-based user identity
* Local blockchain setup
* Ethers v6 deployment + interaction

Perfect for:

* LPU Projects
* Blockchain Assignments
* Portfolio Projects
* Web3 Learning

---
