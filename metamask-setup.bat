@echo off
chcp 65001 > nul
title MetaMask Setup Helper

echo.
echo ========================================
echo        MetaMask Configuration Helper
echo ========================================
echo.
echo This will help you configure MetaMask for the EventRegistration dApp.
echo.
echo Steps to configure MetaMask:
echo.
echo 1. Open MetaMask extension
echo 2. Click the network dropdown ^(top^)
echo 3. Click "Add Network" 
echo 4. Click "Add a network manually"
echo 5. Enter these details:
echo.
echo    Network Name: Hardhat Localhost
echo    RPC URL: http://127.0.0.1:8545
echo    Chain ID: 31337
echo    Currency Symbol: ETH
echo    Block Explorer: ^(leave blank^)
echo.
echo 6. Click "Save"
echo.
echo 7. Import test accounts using these private keys:
echo.
echo    Account #0 ^(10,000 ETH^):
echo    0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
echo.
echo    Account #1 ^(10,000 ETH^):
echo    0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
echo.
echo 8. Make sure you're connected to "Hardhat Localhost" network
echo.
echo Press any key to open the dApp after configuring MetaMask...
pause > nul
start http://localhost:8080