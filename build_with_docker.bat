@echo off
echo Building WifiTrigger with Docker...

REM Make sure Docker is installed and running
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Docker is not installed or not in PATH. Please install Docker Desktop.
    pause
    exit /b 1
)

echo Creating Docker image for iOS compilation...
docker build -t wifitrigger-builder .

if %errorlevel% neq 0 (
    echo Failed to build Docker image
    pause
    exit /b 1
)

echo Compiling WifiTrigger...
docker run --rm -v "%cd%:/project" -w /project wifitrigger-builder

echo.
echo Compilation complete! Check the packages/ directory for the .deb file.
pause