// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title EventRegistration
 * @dev A smart contract for event registration with payment requirement
 * @notice Users can register for an event by paying 0.01 ETH
 */
contract EventRegistration {
    // Registration fee constant
    uint256 public constant REGISTRATION_FEE = 0.01 ether;
    
    // Owner of the contract
    address public owner;
    
    // Total number of participants
    uint256 private participantCount;
    
    // Mapping to track registered addresses
    mapping(address => bool) public isRegistered;
    
    // Array of all registered participants
    address[] private participants;
    
    /**
     * @dev Emitted when a user successfully registers
     * @param user The address of the registered user
     * @param time The timestamp of registration
     */
    event Registered(address indexed user, uint256 time);
    
    /**
     * @dev Emitted when funds are withdrawn by owner
     * @param owner The contract owner
     * @param amount The amount withdrawn
     */
    event FundsWithdrawn(address indexed owner, uint256 amount);
    
    /**
     * @dev Sets the deployer as the owner
     */
    constructor() {
        owner = msg.sender;
    }
    
    /**
     * @dev Registers a user for the event
     * @notice Users must pay exactly 0.01 ETH and cannot register twice
     */
    function register() external payable {
        // Check if payment amount is correct
        require(msg.value == REGISTRATION_FEE, "EventRegistration: Incorrect payment amount. Required: 0.01 ETH");
        
        // Check if user is not already registered
        require(!isRegistered[msg.sender], "EventRegistration: Address already registered");
        
        // Mark user as registered
        isRegistered[msg.sender] = true;
        participants.push(msg.sender);
        participantCount++;
        
        // Emit registration event
        emit Registered(msg.sender, block.timestamp);
    }
    
    /**
     * @dev Returns the total number of registered participants
     * @return The total participant count
     */
    function getParticipantCount() external view returns (uint256) {
        return participantCount;
    }
    
    /**
     * @dev Returns the list of all registered participants
     * @return Array of participant addresses
     */
    function getAllParticipants() external view returns (address[] memory) {
        return participants;
    }
    
    /**
     * @dev Check if an address is registered
     * @param _user The address to check
     * @return Boolean indicating registration status
     */
    function checkRegistration(address _user) external view returns (bool) {
        return isRegistered[_user];
    }
    
    /**
     * @dev Get contract balance
     * @return The current balance of the contract
     */
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    /**
     * @dev Withdraw collected funds (owner only)
     */
    function withdrawFunds() external {
        require(msg.sender == owner, "EventRegistration: Only owner can withdraw funds");
        
        uint256 balance = address(this).balance;
        require(balance > 0, "EventRegistration: No funds to withdraw");
        
        (bool success, ) = payable(owner).call{value: balance}("");
        require(success, "EventRegistration: Transfer failed");
        
        emit FundsWithdrawn(owner, balance);
    }
    
    /**
     * @dev Get registration fee
     * @return The required registration fee in wei
     */
    function getRegistrationFee() external pure returns (uint256) {
        return REGISTRATION_FEE;
    }
}
