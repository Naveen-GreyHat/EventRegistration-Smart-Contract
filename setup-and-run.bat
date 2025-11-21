@echo off
chcp 65001 > nul
title EventRegistration dApp - Complete Setup
color 0A

echo.
echo ========================================
echo    EventRegistration dApp - One Click Setup
echo ========================================
echo.

:: Check if Node.js is installed
echo [1/6] Checking Node.js installation...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ ERROR: Node.js is not installed or not in PATH
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)
echo ✅ Node.js is installed

:: Check if Hardhat node is already running
echo [2/6] Checking if Hardhat node is running...
netstat -ano | findstr :8545 >nul
if %errorlevel% equ 0 (
    echo ✅ Hardhat node is already running
    goto :DEPLOY_CONTRACT
)

:: Start Hardhat node in new window
echo [3/6] Starting Hardhat node...
start "Hardhat Node" cmd /k "npx hardhat node"
echo ⏳ Waiting for node to start...
timeout /t 5 /nobreak >nul

:DEPLOY_CONTRACT
:: Deploy contract
echo [4/6] Deploying smart contract...
npx hardhat run scripts/deploy.js --network localhost
if %errorlevel% neq 0 (
    echo ❌ Contract deployment failed!
    pause
    exit /b 1
)

:: Create frontend files
echo [5/6] Setting up frontend files...
call :CREATE_FRONTEND_FILES

:: Start HTTP server
echo [6/6] Starting web server...
echo.
echo 🎉 Setup complete! Your dApp is ready at: http://localhost:8080
echo.
echo 📋 Next steps:
echo 1. Configure MetaMask with:
echo    - Network: Hardhat Localhost
echo    - RPC: http://127.0.0.1:8545
echo    - Chain ID: 31337
echo 2. Import test accounts from Hardhat node output
echo.
echo Press Ctrl+C to stop the server when done...
echo.
cd frontend
python -m http.server 8080
goto :EOF

:CREATE_FRONTEND_FILES
:: Create frontend directory if it doesn't exist
if not exist "frontend" mkdir frontend

:: Create index.html
echo Creating index.html...
>"frontend\index.html" (
echo ^<!DOCTYPE html^^>
echo ^<html lang="en"^^>
echo ^<head^^>
echo     ^<meta charset="UTF-8"^^>
echo     ^<meta name="viewport" content="width=device-width, initial-scale=1.0"^^>
echo     ^<title^^^>EventRegistration dApp^</title^^>
echo     ^<link rel="stylesheet" href="style.css"^^>
echo     ^<script src="https://cdn.ethers.io/lib/ethers-5.7.umd.min.js" type="application/javascript"^^^>^</script^^>
echo ^</head^^>
echo ^<body^^>
echo     ^<div class="container"^^>
echo         ^<header class="header"^^>
echo             ^<h1^^^>🎟️ Event Registration^</h1^^>
echo             ^<p class="subtitle"^^^>Register for the exclusive event with 0.01 ETH^</p^^>
echo         ^</header^^>
echo.
echo         ^<div class="wallet-section card"^^>
echo             ^<h2^^^>🔗 Wallet Connection^</h2^^>
echo             ^<button id="connectWallet" class="btn btn-primary"^^^>Connect Wallet^</button^^>
echo             ^<div id="walletInfo" class="wallet-info hidden"^^>
echo                 ^<p^^^>^<strong^^^>Connected:^</strong^^> ^<span id="walletAddress"^^^>^</span^^^>^</p^^>
echo                 ^<p^^^>^<strong^^^>Network:^</strong^^> ^<span id="networkInfo"^^^>Hardhat Localhost^</span^^^>^</p^^>
echo             ^</div^^>
echo         ^</div^^>
echo.
echo         ^<div class="stats-section"^^>
echo             ^<div class="card stat-card"^^>
echo                 ^<h3^^^>👥 Total Participants^</h3^^>
echo                 ^<div id="participantCount" class="stat-number"^^^>0^</div^^>
echo             ^</div^^>
echo             ^<div class="card stat-card"^^>
echo                 ^<h3^^^>👑 Contract Owner^</h3^^>
echo                 ^<div id="contractOwner" class="stat-address"^^^>Not loaded^</div^^>
echo             ^</div^^>
echo             ^<div class="card stat-card"^^>
echo                 ^<h3^^^>🎫 Registration Fee^</h3^^>
echo                 ^<div class="stat-number"^^^>0.01 ETH^</div^^>
echo             ^</div^^>
echo         ^</div^^>
echo.
echo         ^<div class="registration-section card"^^>
echo             ^<h2^^^>Register for Event^</h2^^>
echo             ^<button id="registerBtn" class="btn btn-register" disabled^^>
echo                 Register for Event - 0.01 ETH
echo             ^</button^^>
echo             ^<div id="transactionStatus" class="transaction-status hidden"^^^>^</div^^>
echo         ^</div^^>
echo.
echo         ^<div class="events-section card"^^>
echo             ^<h2^^^>📋 Registration Events^</h2^^>
echo             ^<div id="eventsList" class="events-list"^^>
echo                 ^<div class="empty-state"^^^>No registrations yet^</div^^>
echo             ^</div^^>
echo         ^</div^^>
echo.
echo         ^<div class="contract-info card"^^>
echo             ^<h2^^^>📄 Contract Information^</h2^^>
echo             ^<p^^^>^<strong^^^>Address:^</strong^^> ^<code^^^>0x5FbDB2315678afecb367f032d93F642f64180aa3^</code^^^>^</p^^>
echo             ^<p^^^>^<strong^^^>Network:^</strong^^> Hardhat Localhost ^(http://127.0.0.1:8545^)^</p^^>
echo         ^</div^^>
echo     ^</div^^>
echo.
echo     ^<script src="app.js"^^^>^</script^^>
echo ^</body^^>
echo ^</html^^>
)

:: Create style.css
echo Creating style.css...
>"frontend\style.css" (
echo * {
echo     margin: 0;
echo     padding: 0;
echo     box-sizing: border-box;
echo }
echo.
echo :root {
echo     --primary-gradient: linear-gradient^(135deg, #667eea 0^%^, #764ba2 100^%^);
echo     --secondary-gradient: linear-gradient^(135deg, #f093fb 0^%^, #f5576c 100^%^);
echo     --success-gradient: linear-gradient^(135deg, #4facfe 0^%^, #00f2fe 100^%^);
echo     --dark-bg: #1a1a1a;
echo     --darker-bg: #0f0f0f;
echo     --card-bg: #2d2d2d;
echo     --text-primary: #ffffff;
echo     --text-secondary: #b0b0b0;
echo     --accent: #667eea;
echo     --border-radius: 12px;
echo     --shadow: 0 8px 32px rgba^(0, 0, 0, 0.3^);
echo }
echo.
echo body {
echo     font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
echo     background: var^(--dark-bg^);
echo     color: var^(--text-primary^);
echo     line-height: 1.6;
echo     min-height: 100vh;
echo }
echo.
echo .container {
echo     max-width: 1200px;
echo     margin: 0 auto;
echo     padding: 20px;
echo }
echo.
echo .header {
echo     text-align: center;
echo     margin-bottom: 40px;
echo     padding: 40px 20px;
echo     background: var^(--primary-gradient^);
echo     border-radius: var^(--border-radius^);
echo     box-shadow: var^(--shadow^);
echo }
echo.
echo .header h1 {
echo     font-size: 3rem;
echo     margin-bottom: 10px;
echo     font-weight: 700;
echo }
echo.
echo .subtitle {
echo     font-size: 1.2rem;
echo     color: rgba^(255, 255, 255, 0.9^);
echo }
echo.
echo .card {
echo     background: var^(--card-bg^);
echo     border-radius: var^(--border-radius^);
echo     padding: 24px;
echo     margin-bottom: 24px;
echo     box-shadow: var^(--shadow^);
echo     border: 1px solid rgba^(255, 255, 255, 0.1^);
echo     transition: transform 0.2s ease, box-shadow 0.2s ease;
echo }
echo.
echo .card:hover {
echo     transform: translateY^(-2px^);
echo     box-shadow: 0 12px 40px rgba^(0, 0, 0, 0.4^);
echo }
echo.
echo .card h2 {
echo     margin-bottom: 20px;
echo     color: var^(--text-primary^);
echo     font-size: 1.5rem;
echo }
echo.
echo .card h3 {
echo     margin-bottom: 15px;
echo     color: var^(--text-secondary^);
echo     font-size: 1.1rem;
echo }
echo.
echo .btn {
echo     padding: 12px 24px;
echo     border: none;
echo     border-radius: 8px;
echo     font-size: 1rem;
echo     font-weight: 600;
echo     cursor: pointer;
echo     transition: all 0.3s ease;
echo     text-decoration: none;
echo     display: inline-block;
echo     text-align: center;
echo     min-width: 160px;
echo }
echo.
echo .btn-primary {
echo     background: var^(--primary-gradient^);
echo     color: white;
echo }
echo.
echo .btn-primary:hover {
echo     transform: translateY^(-2px^);
echo     box-shadow: 0 6px 20px rgba^(102, 126, 234, 0.4^);
echo }
echo.
echo .btn-register {
echo     background: var^(--secondary-gradient^);
echo     color: white;
echo     font-size: 1.1rem;
echo     padding: 16px 32px;
echo     min-width: 200px;
echo }
echo.
echo .btn-register:hover:not^(:disabled^) {
echo     transform: translateY^(-2px^);
echo     box-shadow: 0 6px 20px rgba^(245, 87, 108, 0.4^);
echo }
echo.
echo .btn:disabled {
echo     opacity: 0.6;
echo     cursor: not-allowed;
echo     transform: none !important;
echo     box-shadow: none !important;
echo }
echo.
echo .stats-section {
echo     display: grid;
echo     grid-template-columns: repeat^(auto-fit, minmax^(250px, 1fr^)^);
echo     gap: 20px;
echo     margin-bottom: 30px;
echo }
echo.
echo .stat-card {
echo     text-align: center;
echo     padding: 30px 20px;
echo }
echo.
echo .stat-number {
echo     font-size: 2.5rem;
echo     font-weight: 700;
echo     background: var^(--success-gradient^);
echo     -webkit-background-clip: text;
echo     -webkit-text-fill-color: transparent;
echo     background-clip: text;
echo }
echo.
echo .stat-address {
echo     font-family: 'Courier New', monospace;
echo     font-size: 0.9rem;
echo     color: var^(--text-secondary^);
echo     word-break: break-all;
echo }
echo.
echo .wallet-info {
echo     margin-top: 15px;
echo     padding: 15px;
echo     background: rgba^(255, 255, 255, 0.05^);
echo     border-radius: 8px;
echo     border-left: 4px solid var^(--accent^);
echo }
echo.
echo .wallet-info p {
echo     margin-bottom: 8px;
echo }
echo.
echo .transaction-status {
echo     margin-top: 20px;
echo     padding: 15px;
echo     border-radius: 8px;
echo     border-left: 4px solid var^(--accent^);
echo     background: rgba^(255, 255, 255, 0.05^);
echo }
echo.
echo .transaction-status.success {
echo     border-left-color: #00d26a;
echo     background: rgba^(0, 210, 106, 0.1^);
echo }
echo.
echo .transaction-status.error {
echo     border-left-color: #ff4757;
echo     background: rgba^(255, 71, 87, 0.1^);
echo }
echo.
echo .events-list {
echo     max-height: 400px;
echo     overflow-y: auto;
echo }
echo.
echo .event-item {
echo     padding: 15px;
echo     margin-bottom: 10px;
echo     background: rgba^(255, 255, 255, 0.05^);
echo     border-radius: 8px;
echo     border-left: 4px solid var^(--accent^);
echo }
echo.
echo .event-address {
echo     font-family: 'Courier New', monospace;
echo     font-size: 0.9rem;
echo     color: var^(--text-primary^);
echo     margin-bottom: 5px;
echo     word-break: break-all;
echo }
echo.
echo .event-time {
echo     font-size: 0.8rem;
echo     color: var^(--text-secondary^);
echo }
echo.
echo .empty-state {
echo     text-align: center;
echo     color: var^(--text-secondary^);
echo     font-style: italic;
echo     padding: 40px 20px;
echo }
echo.
echo .contract-info {
echo     background: rgba^(255, 255, 255, 0.03^);
echo     border: 1px dashed rgba^(255, 255, 255, 0.2^);
echo }
echo.
echo .contract-info code {
echo     background: rgba^(255, 255, 255, 0.1^);
echo     padding: 2px 6px;
echo     border-radius: 4px;
echo     font-size: 0.9rem;
echo }
echo.
echo .hidden {
echo     display: none;
echo }
echo.
echo @media ^(max-width: 768px^) {
echo     .container {
echo         padding: 10px;
echo     }
echo     .header h1 {
echo         font-size: 2rem;
echo     }
echo     .stats-section {
echo         grid-template-columns: 1fr;
echo     }
echo     .btn {
echo         width: 100^%^;
echo         min-width: auto;
echo     }
echo }
echo.
echo .events-list::-webkit-scrollbar {
echo     width: 6px;
echo }
echo.
echo .events-list::-webkit-scrollbar-track {
echo     background: rgba^(255, 255, 255, 0.1^);
echo     border-radius: 3px;
echo }
echo.
echo .events-list::-webkit-scrollbar-thumb {
echo     background: var^(--accent^);
echo     border-radius: 3px;
echo }
)

:: Create app.js with improved MetaMask detection
echo Creating app.js...
>"frontend\app.js" (
echo // Contract configuration
echo const CONTRACT_ADDRESS = '0x5FbDB2315678afecb367f032d93F642f64180aa3';
echo const CONTRACT_ABI = [
echo     "function register^(^) payable",
echo     "function getParticipantCount^(^) view returns ^(uint256^)",
echo     "function getRegistrationFee^(^) view returns ^(uint256^)",
echo     "function owner^(^) view returns ^(address^)",
echo     "function isRegistered^(address^) view returns ^(bool^)",
echo     "event Registered^(address indexed user, uint256 time^)"
echo ];
echo.
echo // Global variables
echo let provider;
echo let signer;
echo let contract;
echo let isConnected = false;
echo.
echo // DOM Elements
echo const connectWalletBtn = document.getElementById^('connectWallet'^);
echo const registerBtn = document.getElementById^('registerBtn'^);
echo const walletInfo = document.getElementById^('walletInfo'^);
echo const walletAddress = document.getElementById^('walletAddress'^);
echo const participantCount = document.getElementById^('participantCount'^);
echo const contractOwner = document.getElementById^('contractOwner'^);
echo const transactionStatus = document.getElementById^('transactionStatus'^);
echo const eventsList = document.getElementById^('eventsList'^);
echo.
echo // Improved MetaMask detection
echo function checkMetaMask^(^) {
echo     if ^(typeof window.ethereum !== 'undefined'^) {
echo         console.log^('MetaMask is installed!'^);
echo         return true;
echo     } else {
echo         showError^('MetaMask not detected! Please ensure:^^n1. MetaMask extension is installed^^n2. You^'re using http://localhost:8080^^n3. Try refreshing the page'^);
echo         connectWalletBtn.disabled = true;
echo         connectWalletBtn.textContent = 'MetaMask Not Found';
echo         return false;
echo     }
echo }
echo.
echo // Wait for MetaMask to inject
echo async function waitForMetaMask^(^) {
echo     let attempts = 0;
echo     const maxAttempts = 50;
echo     return new Promise^((resolve, reject^) =^> ^{
echo         const checkInterval = setInterval^((^) =^> ^{
echo             attempts++;
echo             if ^(typeof window.ethereum !== 'undefined'^) ^{
echo                 clearInterval^(checkInterval^);
echo                 resolve^(true^);
echo             ^} else if ^(attempts ^>= maxAttempts^) ^{
echo                 clearInterval^(checkInterval^);
echo                 resolve^(false^);
echo             ^}
echo         ^}, 100^);
echo     ^}^);
echo }
echo.
echo // Initialize the dApp
echo document.addEventListener^('DOMContentLoaded', async function^(^) ^{
echo     console.log^('Initializing dApp...'^);
echo     const metaMaskAvailable = await waitForMetaMask^(^);
echo     if ^(metaMaskAvailable^) ^{
echo         console.log^('MetaMask detected, loading contract...'^);
echo         await loadContract^(^);
echo         connectWalletBtn.disabled = false;
echo     ^} else ^{
echo         checkMetaMask^(^);
echo     ^}
echo ^}^);
echo.
echo // Load contract instance
echo async function loadContract^(^) ^{
echo     try ^{
echo         provider = new ethers.providers.Web3Provider^(window.ethereum^);
echo         contract = new ethers.Contract^(CONTRACT_ADDRESS, CONTRACT_ABI, provider^);
echo         console.log^('Contract loaded successfully'^);
echo         await loadContractData^(^);
echo     ^} catch ^(error^) ^{
echo         console.error^('Error loading contract:', error^);
echo         showError^('Error loading contract: ' + error.message^);
echo     ^}
echo }
echo.
echo // Load contract data
echo async function loadContractData^(^) ^{
echo     try ^{
echo         const count = await contract.getParticipantCount^(^);
echo         participantCount.textContent = count.toString^(^);
echo         const owner = await contract.owner^(^);
echo         contractOwner.textContent = shortenAddress^(owner^);
echo         await loadPastEvents^(^);
echo         startEventListener^(^);
echo     ^} catch ^(error^) ^{
echo         console.error^('Error loading contract data:', error^);
echo     ^}
echo }
echo.
echo // Connect wallet function
echo async function connectWallet^(^) ^{
echo     if ^(!checkMetaMask^(^^)) return;
echo     try ^{
echo         const accounts = await window.ethereum.request^({ method: 'eth_requestAccounts' ^}^);
echo         provider = new ethers.providers.Web3Provider^(window.ethereum^);
echo         signer = provider.getSigner^(^);
echo         contract = contract.connect^(signer^);
echo         const address = await signer.getAddress^(^);
echo         walletAddress.textContent = shortenAddress^(address^);
echo         walletInfo.classList.remove^('hidden'^);
echo         connectWalletBtn.textContent = 'Connected';
echo         connectWalletBtn.disabled = true;
echo         registerBtn.disabled = false;
echo         isConnected = true;
echo         await checkUserRegistration^(^);
echo         showSuccess^('Wallet connected successfully!'^);
echo     ^} catch ^(error^) ^{
echo         console.error^('Error connecting wallet:', error^);
echo         showError^('Failed to connect wallet: ' + error.message^);
echo     ^}
echo }
echo.
echo // Check if current user is already registered
echo async function checkUserRegistration^(^) ^{
echo     try ^{
echo         const address = await signer.getAddress^(^);
echo         const registered = await contract.isRegistered^(address^);
echo         if ^(registered^) ^{
echo             registerBtn.disabled = true;
echo             registerBtn.textContent = 'Already Registered';
echo             showInfo^('You are already registered for this event.'^);
echo         ^}
echo     ^} catch ^(error^) ^{
echo         console.error^('Error checking registration:', error^);
echo     ^}
echo }
echo.
echo // Register for event
echo async function registerForEvent^(^) ^{
echo     if ^(!isConnected^) ^{
echo         showError^('Please connect your wallet first.'^);
echo         return;
echo     ^}
echo     try ^{
echo         registerBtn.disabled = true;
echo         registerBtn.textContent = 'Processing...';
echo         transactionStatus.className = 'transaction-status';
echo         transactionStatus.textContent = '';
echo         const fee = ethers.utils.parseEther^('0.01'^);
echo         const tx = await contract.register^({ value: fee ^}^);
echo         showInfo^(`Transaction sent: $^{tx.hash^}. Waiting for confirmation...`^);
echo         const receipt = await tx.wait^(^);
echo         showSuccess^(`Registration successful! Transaction confirmed in block $^{receipt.blockNumber^}`^);
echo         await updateParticipantCount^(^);
echo         registerBtn.disabled = true;
echo         registerBtn.textContent = 'Registration Complete';
echo     ^} catch ^(error^) ^{
echo         console.error^('Error registering:', error^);
echo         if ^(error.code === 'ACTION_REJECTED'^) ^{
echo             showError^('Transaction was rejected by user.'^);
echo         ^} else if ^(error.message.includes^('already registered'^)^) ^{
echo             showError^('This address is already registered for the event.'^);
echo             registerBtn.disabled = true;
echo             registerBtn.textContent = 'Already Registered';
echo         ^} else if ^(error.message.includes^('Incorrect payment amount'^)^) ^{
echo             showError^('Incorrect payment amount. Please send exactly 0.01 ETH.'^);
echo         ^} else ^{
echo             showError^('Registration failed: ' + error.message^);
echo         ^}
echo         registerBtn.disabled = false;
echo         registerBtn.textContent = 'Register for Event - 0.01 ETH';
echo     ^}
echo }
echo.
echo // Update participant count
echo async function updateParticipantCount^(^) ^{
echo     try ^{
echo         const count = await contract.getParticipantCount^(^);
echo         participantCount.textContent = count.toString^(^);
echo     ^} catch ^(error^) ^{
echo         console.error^('Error updating participant count:', error^);
echo     ^}
echo }
echo.
echo // Load past registration events
echo async function loadPastEvents^(^) ^{
echo     try ^{
echo         const currentBlock = await provider.getBlockNumber^(^);
echo         const fromBlock = Math.max^(0, currentBlock - 10000^);
echo         const events = await contract.queryFilter^('Registered', fromBlock, currentBlock^);
echo         eventsList.innerHTML = '';
echo         if ^(events.length === 0^) ^{
echo             eventsList.innerHTML = '^<div class="empty-state"^>No registrations yet^</div^>';
echo             return;
echo         ^}
echo         events.sort^((a, b^) =^> b.blockNumber - a.blockNumber^);
echo         events.forEach^(event =^> ^{
echo             addEventToUI^(event.args.user, event.args.time^);
echo         ^}^);
echo     ^} catch ^(error^) ^{
echo         console.error^('Error loading past events:', error^);
echo     ^}
echo }
echo.
echo // Start listening for new events
echo function startEventListener^(^) ^{
echo     try ^{
echo         contract.on^('Registered', ^(user, time^) =^> ^{
echo             addEventToUI^(user, time^);
echo             updateParticipantCount^(^);
echo         ^}^);
echo     ^} catch ^(error^) ^{
echo         console.error^('Error starting event listener:', error^);
echo     ^}
echo }
echo.
echo // Add event to UI
echo function addEventToUI^(user, time^) ^{
echo     const emptyState = eventsList.querySelector^('.empty-state'^);
echo     if ^(emptyState^) ^{
echo         emptyState.remove^(^);
echo     ^}
echo     const eventItem = document.createElement^('div'^);
echo     eventItem.className = 'event-item';
echo     const timestamp = new Date^(time * 1000^).toLocaleString^(^);
echo     eventItem.innerHTML = `
echo         ^<div class="event-address"^>$^{shortenAddress^(user^)^}^</div^>
echo         ^<div class="event-time"^>$^{timestamp^}^</div^>
echo     `;
echo     eventsList.insertBefore^(eventItem, eventsList.firstChild^);
echo }
echo.
echo // Utility function to shorten address
echo function shortenAddress^(address^) ^{
echo     return `$^{address.substring^(0, 6^)^}...$^{address.substring^(address.length - 4^)^}`;
echo }
echo.
echo // Show success message
echo function showSuccess^(message^) ^{
echo     transactionStatus.className = 'transaction-status success';
echo     transactionStatus.textContent = message;
echo     transactionStatus.classList.remove^('hidden'^);
echo }
echo.
echo // Show error message
echo function showError^(message^) ^{
echo     transactionStatus.className = 'transaction-status error';
echo     transactionStatus.textContent = message;
echo     transactionStatus.classList.remove^('hidden'^);
echo }
echo.
echo // Show info message
echo function showInfo^(message^) ^{
echo     transactionStatus.className = 'transaction-status';
echo     transactionStatus.textContent = message;
echo     transactionStatus.classList.remove^('hidden'^);
echo }
echo.
echo // Event Listeners
echo connectWalletBtn.addEventListener^('click', connectWallet^);
echo registerBtn.addEventListener^('click', registerForEvent^);
echo.
echo // Handle account changes
echo if ^(window.ethereum^) ^{
echo     window.ethereum.on^('accountsChanged', ^(accounts^) =^> ^{
echo         if ^(accounts.length === 0^) ^{
echo             walletInfo.classList.add^('hidden'^);
echo             connectWalletBtn.disabled = false;
echo             connectWalletBtn.textContent = 'Connect Wallet';
echo             registerBtn.disabled = true;
echo             isConnected = false;
echo             showInfo^('Wallet disconnected.'^);
echo         ^} else ^{
echo             location.reload^(^);
echo         ^}
echo     ^}^);
echo     window.ethereum.on^('chainChanged', ^(chainId^) =^> ^{
echo         if ^(chainId !== '0x7a69' ^&^& chainId !== '0x539'^) ^{
echo             showError^('Please switch to Hardhat Localhost network ^(chainId 31337^)'^);
echo         ^} else ^{
echo             location.reload^(^);
echo         ^}
echo     ^}^);
echo }
)

echo ✅ Frontend files created successfully!
goto :EOF