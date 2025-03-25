#!/usr/bin/env pwsh

# Define paths
$unityPath = "C:\Program Files\Unity\Hub\Editor\6000.1.0b6\Editor\Unity.exe"
$testResultsPath = "C:\gauntletai\OpenAI-Agents\test-results.xml"
$projectPath = "C:\gauntletai\OpenAI-Agents"
$logFilePath = "C:\gauntletai\OpenAI-Agents\unity-log.txt"

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
    $args = @(
        "-runTests",
        "-testResults", $testResultsPath,
        "-batchmode",
        "-projectPath", $projectPath,
        "-testPlatform", "EditMode",
        "-logFile", $logFilePath
    )
    
    Write-Host "Executing Unity with args: $args"
    
    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = $unityPath
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true
    $pinfo.UseShellExecute = $false
    $pinfo.Arguments = $args
    
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $pinfo
    $process.Start() | Out-Null
    
    # Wait for process with timeout (15 minutes)
    $timeout = 900 * 1000 # milliseconds
    if (-not $process.WaitForExit($timeout)) {
        Write-Host "ERROR: Unity test process timed out after $($timeout/1000) seconds"
        try {
            $process.Kill()
        }
        catch {
            Write-Host "Failed to kill Unity process: $_"
        }
        exit 1
    }
    
    # $stdout = $process.StandardOutput.ReadToEnd()
    # $stderr = $process.StandardError.ReadToEnd()
    $exitCode = $process.ExitCode
    
    # Write-Host "Unity test process completed with exit code: $exitCode"
    # if ($stdout) { Write-Host "stdout: $stdout" }
    # if ($stderr) { Write-Host "stderr: $stderr" }
    
    if ($exitCode -eq 1) {
        # Read unity log and extract error message
        if (Test-Path $logFilePath) {

            #Load the file into an array of lines
            $lines = Get-Content $logFilePath
            #for loop through the lines until we find one starting with ## Output
            for ($i = 0; $i -lt $lines.Length; $i++) {
                #Use string.startswith, not regex
                if ($lines[$i].StartsWith("#")) {
                    #ALso the line contgains Output
                    if ($lines[$i] -match "Output") {   
                        Write-Host $lines[$i + 1].Trim()
                        break
                    }
                }
            }
        }
        exit $exitCode
    }
    elseif ($exitCode -ne 0) {
        Write-Host "Tests failed. Exit code: $exitCode"
        exit $exitCode
    }
    else {
        Write-Host "Tests completed successfully, see results at $testResultsPath"
        exit 0
    }
}
catch {
    Write-Host "Error executing Unity tests: $_"
    exit 1
}