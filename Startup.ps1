function Ensure-JiraPSModule {
    if (-not (Get-Module -ListAvailable -Name JiraPS)) {
        Write-Host "JiraPS module not found. Installing JiraPS module..."
        try {
            Install-Module -Name JiraPS -Force -Scope CurrentUser
            Write-Host "JiraPS module installed successfully."
        } catch {
            Write-Host "Error installing JiraPS module. Please ensure you have internet access and run this script with sufficient permissions."
            exit 1
        }
    } else {
        Write-Host "JiraPS module is already installed."
    }
}

function Ensure-ConfigFile {
    $ConfigPath = ".\Config.psm1"
    if (-not (Test-Path $ConfigPath)) {
        Write-Host "Config.psm1 not found. Let's create it."
        $JiraUrl = Read-Host "1) What is your Jira URL (example: https://jira.your-organisation-name.com)"
        $MyUsername = Read-Host "2) What is your Jira username (usually in Name.Surname format)?"
        $ProjectsToIgnore = Read-Host "3) Are there any project prefixes you'd like to ignore while executing scripts (separate them by comma, or just leave it empty for now)"
        $configContent = @"
`$JiraUrl = "$JiraUrl"
`$MyUsername = "$MyUsername"
`$ProjectsToIgnore = "$ProjectsToIgnore"

Export-ModuleMember -Variable JiraUrl, MyUsername, ProjectsToIgnore
"@
        Set-Content -Path $ConfigPath -Value $configContent -NoNewline
        Write-Host "Config.psm1 has been created. You can always modify it by editing the file."
    }
    Import-Module $ConfigPath
}

function Run-GenerateCredentials {
    if (-not $generateCredentialsRun) {
        $generateCredentialsPath = ".\GenerateCredentials.ps1"
        if (Test-Path $generateCredentialsPath) {
            Write-Host "Running GenerateCredentials.ps1..."
            . $generateCredentialsPath
            $generateCredentialsRun = $true
        } else {
            Write-Host "GenerateCredentials.ps1 not found."
        }
    }
}

function Get-ScriptList {
    Get-ChildItem -Path ".\Commands" -Filter "*.ps1" | Sort-Object Name
}

function Display-ScriptMenu {
    param (
        [array]$scripts
    )
    Write-Host "`nAvailable scripts:" -ForegroundColor Green
    for ($i = 0; $i -lt $scripts.Count; $i++) {
        $formattedName = Format-ScriptName $scripts[$i].Name
        Write-Host "$($i + 1). $formattedName"
    }
    Write-Host "`nPress the number of the script you want to run (or 'q' to quit)"
}

function Execute-SelectedScript {
    param (
        [array]$scripts,
        [string]$selection
    )
    if ($selection -eq 'q') {
        Write-Host "Exiting the program. Goodbye!"
        exit
    }
    if ($selection -match '^\d+$') {
        $selectedIndex = [int]::Parse($selection) - 1
        if ($selectedIndex -ge 0 -and $selectedIndex -lt $scripts.Count) {
            $selectedScript = $scripts[$selectedIndex].FullName
            Write-Host "`nExecuting $($scripts[$selectedIndex].Name)..."
            . $selectedScript
        } else {
            Write-Host "`nInvalid selection. Please select a valid number."
        }
    } else {
        Write-Host "`nInvalid input. Please press a number corresponding to a script."
    }
}

function Format-ScriptName {
    param (
        [string]$scriptName
    )
    $formattedName = $scriptName -replace '\.ps1$', ''
    $formattedName = [regex]::Replace($formattedName, '([a-z])([A-Z])', '$1 $2')
    return $formattedName
}

function Read-SingleKeyPress {
    $keyInfo = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    return $keyInfo.Character
}

Ensure-JiraPSModule
Ensure-ConfigFile
Run-GenerateCredentials

while ($true) {
    $scripts = Get-ScriptList
    Display-ScriptMenu -scripts $scripts
    $selection = Read-SingleKeyPress
    Execute-SelectedScript -scripts $scripts -selection $selection
    Write-Host "`nPress Enter to return to the menu"
    Read-Host
}
