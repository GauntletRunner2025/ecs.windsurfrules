#!/usr/bin/env pwsh

# Define paths
$unityPath = "C:\Program Files\Unity\Hub\Editor\6000.1.0b6\Editor\Unity.exe"
$testResultsPath = "C:\gauntletai\bounce\test-results.xml"
$projectPath = "C:\gauntletai\bounce"
$logFilePath = "C:\gauntletai\bounce\unity-log.txt"

Write-Host "Running Unity tests..."

# Check if Unity is already running
$unityProcesses = Get-Process -Name "Unity" -ErrorAction SilentlyContinue

if ($unityProcesses) {
    Write-Host "ERROR: Unity is already running. Cannot run tests while Unity is open."
    Write-Host "Found $($unityProcesses.Count) Unity process(es)."
    Write-Host "Please close all Unity instances before running tests."
    exit 1
}

# Run Unity with tests directly
try {
    Write-Host "Executing: `"$unityPath`" -runTests -testResults `"$testResultsPath`" -batchmode -projectPath `"$projectPath`" -testPlatform EditMode -logFile `"$logFilePath`""
    
    $process = Start-Process -FilePath $unityPath -ArgumentList "-runTests", "-testResults", $testResultsPath, "-batchmode", "-projectPath", $projectPath, "-testPlatform", "EditMode", "-logFile", $logFilePath -Wait -PassThru -NoNewWindow
    
    # Check the exit code
    $exitCode = $process.ExitCode
    Write-Host "Unity test process completed with exit code: $exitCode"
    
    # If the exit code is non-zero, extract content from the log file
    if ($exitCode -ne 0) {
        Write-Host "Tests failed. Examining log file..."
        
        # Check if the log file exists
        if (Test-Path $logFilePath) {
            Write-Host "Log file found. Displaying last 20 lines:"
            Get-Content -Path $logFilePath -Tail 20
            
            # Check for the specific "already open in another instance" error
            $logContent = Get-Content -Path $logFilePath -Raw
            if ($logContent -match "project.*already open in another instance") {
                Write-Host "`nERROR: Unity project is already open in another instance."
                Write-Host "Please close all Unity instances before running tests."
            }
        } else {
            Write-Host "Log file not found at: $logFilePath"
        }
        
        # Return the exit code from Unity
        exit $exitCode
    } else {
        Write-Host "Tests completed successfully."
    }
} catch {
    Write-Host "Error executing Unity tests: $_"
    exit 1
}

Write-Host "Script completed."
exit 0 