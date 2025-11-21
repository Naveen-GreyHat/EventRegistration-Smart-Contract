@echo off
chcp 65001 > nul
title Quick dApp Test

echo.
echo ========================================
echo           Quick dApp Test
echo ========================================
echo.
echo Testing if everything is working...
echo.

:: Test if Hardhat node is running
echo [1/4] Testing Hardhat node...
curl -s -X POST --data "{\"jsonrpc\":\"2.0\",\"method\":\"net_version\",\"params\":[],\"id\":1}" http://localhost:8545 > nul
if %errorlevel% equ 0 (
    echo ✅ Hardhat node is running
) else (
    echo ❌ Hardhat node is not running
    echo Run setup-and-run.bat first
    pause
    exit /b 1
)

:: Test if contract is deployed
echo [2/4] Testing contract...
npx hardhat console --network localhost --eval "const contract = await ethers.getContractAt('EventRegistration', '0x5FbDB2315678afecb367f032d93F642f64180aa3'); console.log('✅ Contract is accessible'); process.exit(0)" 2>nul
if %errorlevel% equ 0 (
    echo ✅ Contract is deployed and accessible
) else (
    echo ❌ Contract not accessible
)

:: Test if HTTP server is running
echo [3/4] Testing web server...
curl -s http://localhost:8080 > nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Web server is running
) else (
    echo ❌ Web server is not running
    echo Starting web server...
    start "Web Server" cmd /k "cd frontend && python -m http.server 8080"
    timeout /t 3 /nobreak >nul
)

echo [4/4] Opening dApp...
start http://localhost:8080

echo.
echo ✅ All tests passed! Your dApp should be working.
echo.
echo If you encounter MetaMask issues:
echo 1. Run metamask-setup.bat
echo 2. Make sure you're on http://localhost:8080
echo 3. Not file:// protocol
echo.
pause