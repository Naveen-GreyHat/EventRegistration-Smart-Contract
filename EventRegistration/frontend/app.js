// Contract configuration
const CONTRACT_ADDRESS = '0x5FbDB2315678afecb367f032d93F642f64180aa3';
const CONTRACT_ABI = [
    "function register() payable",
    "function getParticipantCount() view returns (uint256)",
    "function getRegistrationFee() view returns (uint256)",
    "function owner() view returns (address)",
    "function isRegistered(address) view returns (bool)",
    "event Registered(address indexed user, uint256 time)"
];

// Global variables
let provider;
let signer;
let contract;
let isConnected = false;

// DOM Elements
const connectWalletBtn = document.getElementById('connectWallet');
const registerBtn = document.getElementById('registerBtn');
const walletInfo = document.getElementById('walletInfo');
const walletAddress = document.getElementById('walletAddress');
const participantCount = document.getElementById('participantCount');
const contractOwner = document.getElementById('contractOwner');
const transactionStatus = document.getElementById('transactionStatus');
const eventsList = document.getElementById('eventsList');

// Initialize the dApp
document.addEventListener('DOMContentLoaded', function() {
    checkMetaMask();
    loadContract();
});

// Check if MetaMask is installed
function checkMetaMask() {
    if (typeof window.ethereum === 'undefined') {
        showError('MetaMask is not installed. Please install MetaMask to use this dApp.');
        connectWalletBtn.disabled = true;
        connectWalletBtn.textContent = 'MetaMask Not Found';
        return false;
    }
    return true;
}

// Load contract instance
async function loadContract() {
    try {
        provider = new ethers.providers.Web3Provider(window.ethereum);
        contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, provider);
        
        // Try to load initial data even if not connected
        await loadContractData();
    } catch (error) {
        console.error('Error loading contract:', error);
    }
}

// Load contract data (participant count, owner)
async function loadContractData() {
    try {
        const count = await contract.getParticipantCount();
        participantCount.textContent = count.toString();
        
        const owner = await contract.owner();
        contractOwner.textContent = shortenAddress(owner);
        
        // Load past events
        await loadPastEvents();
        
        // Start listening for new events
        startEventListener();
    } catch (error) {
        console.error('Error loading contract data:', error);
    }
}

// Connect wallet function
async function connectWallet() {
    if (!checkMetaMask()) return;
    
    try {
        // Request account access
        await window.ethereum.request({ method: 'eth_requestAccounts' });
        
        // Get signer
        provider = new ethers.providers.Web3Provider(window.ethereum);
        signer = provider.getSigner();
        
        // Update contract instance with signer for write operations
        contract = contract.connect(signer);
        
        // Get connected address
        const address = await signer.getAddress();
        walletAddress.textContent = shortenAddress(address);
        
        // Update UI
        walletInfo.classList.remove('hidden');
        connectWalletBtn.textContent = 'Connected';
        connectWalletBtn.disabled = true;
        registerBtn.disabled = false;
        
        isConnected = true;
        
        // Check if user is already registered
        await checkUserRegistration();
        
        showSuccess('Wallet connected successfully!');
        
    } catch (error) {
        console.error('Error connecting wallet:', error);
        showError('Failed to connect wallet: ' + error.message);
    }
}

// Check if current user is already registered
async function checkUserRegistration() {
    try {
        const address = await signer.getAddress();
        const registered = await contract.isRegistered(address);
        
        if (registered) {
            registerBtn.disabled = true;
            registerBtn.textContent = 'Already Registered';
            showInfo('You are already registered for this event.');
        }
    } catch (error) {
        console.error('Error checking registration:', error);
    }
}

// Register for event
async function registerForEvent() {
    if (!isConnected) {
        showError('Please connect your wallet first.');
        return;
    }
    
    try {
        registerBtn.disabled = true;
        registerBtn.textContent = 'Processing...';
        
        // Clear previous status
        transactionStatus.className = 'transaction-status';
        transactionStatus.textContent = '';
        
        // Calculate registration fee (0.01 ETH)
        const fee = ethers.utils.parseEther('0.01');
        
        // Send transaction
        const tx = await contract.register({ value: fee });
        
        showInfo(`Transaction sent: ${tx.hash}. Waiting for confirmation...`);
        
        // Wait for transaction confirmation
        const receipt = await tx.wait();
        
        showSuccess(`Registration successful! Transaction confirmed in block ${receipt.blockNumber}`);
        
        // Update participant count
        await updateParticipantCount();
        
        // Disable register button since user is now registered
        registerBtn.disabled = true;
        registerBtn.textContent = 'Registration Complete';
        
    } catch (error) {
        console.error('Error registering:', error);
        
        if (error.code === 'ACTION_REJECTED') {
            showError('Transaction was rejected by user.');
        } else if (error.message.includes('already registered')) {
            showError('This address is already registered for the event.');
            registerBtn.disabled = true;
            registerBtn.textContent = 'Already Registered';
        } else if (error.message.includes('Incorrect payment amount')) {
            showError('Incorrect payment amount. Please send exactly 0.01 ETH.');
        } else {
            showError('Registration failed: ' + error.message);
        }
        
        registerBtn.disabled = false;
        registerBtn.textContent = 'Register for Event - 0.01 ETH';
    }
}

// Update participant count
async function updateParticipantCount() {
    try {
        const count = await contract.getParticipantCount();
        participantCount.textContent = count.toString();
    } catch (error) {
        console.error('Error updating participant count:', error);
    }
}

// Load past registration events
async function loadPastEvents() {
    try {
        // Get events from the last 10000 blocks
        const currentBlock = await provider.getBlockNumber();
        const fromBlock = Math.max(0, currentBlock - 10000);
        
        const events = await contract.queryFilter('Registered', fromBlock, currentBlock);
        
        // Clear events list
        eventsList.innerHTML = '';
        
        if (events.length === 0) {
            eventsList.innerHTML = '<div class="empty-state">No registrations yet</div>';
            return;
        }
        
        // Sort events by block number (newest first)
        events.sort((a, b) => b.blockNumber - a.blockNumber);
        
        // Display events
        events.forEach(event => {
            addEventToUI(event.args.user, event.args.time);
        });
        
    } catch (error) {
        console.error('Error loading past events:', error);
    }
}

// Start listening for new events
function startEventListener() {
    try {
        contract.on('Registered', (user, time) => {
            addEventToUI(user, time);
            updateParticipantCount();
        });
    } catch (error) {
        console.error('Error starting event listener:', error);
    }
}

// Add event to UI
function addEventToUI(user, time) {
    // Remove empty state if it exists
    const emptyState = eventsList.querySelector('.empty-state');
    if (emptyState) {
        emptyState.remove();
    }
    
    const eventItem = document.createElement('div');
    eventItem.className = 'event-item';
    
    const timestamp = new Date(time * 1000).toLocaleString();
    
    eventItem.innerHTML = `
        <div class="event-address">${shortenAddress(user)}</div>
        <div class="event-time">${timestamp}</div>
    `;
    
    // Add new event at the top
    eventsList.insertBefore(eventItem, eventsList.firstChild);
}

// Utility function to shorten address
function shortenAddress(address) {
    return `${address.substring(0, 6)}...${address.substring(address.length - 4)}`;
}

// Show success message
function showSuccess(message) {
    transactionStatus.className = 'transaction-status success';
    transactionStatus.textContent = message;
    transactionStatus.classList.remove('hidden');
}

// Show error message
function showError(message) {
    transactionStatus.className = 'transaction-status error';
    transactionStatus.textContent = message;
    transactionStatus.classList.remove('hidden');
}

// Show info message
function showInfo(message) {
    transactionStatus.className = 'transaction-status';
    transactionStatus.textContent = message;
    transactionStatus.classList.remove('hidden');
}

// Event Listeners
connectWalletBtn.addEventListener('click', connectWallet);
registerBtn.addEventListener('click', registerForEvent);

// Handle account changes
if (window.ethereum) {
    window.ethereum.on('accountsChanged', (accounts) => {
        if (accounts.length === 0) {
            // User disconnected their wallet
            walletInfo.classList.add('hidden');
            connectWalletBtn.disabled = false;
            connectWalletBtn.textContent = 'Connect Wallet';
            registerBtn.disabled = true;
            isConnected = false;
            showInfo('Wallet disconnected.');
        } else {
            // Account changed, reload
            location.reload();
        }
    });
    
    // Handle chain changes
    window.ethereum.on('chainChanged', (chainId) => {
        // Check if it's localhost (chainId 1337 for Hardhat)
        if (chainId !== '0x539') { // 1337 in hex
            showError('Please switch to Hardhat Localhost network (chainId 1337)');
        } else {
            location.reload();
        }
    });
}