# Check if JiraPS module is installed, if not, install it
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

# Check if Config.psm1 exists, if not, create it
$ConfigPath = ".\Config.psm1"

if (-not (Test-Path $ConfigPath)) {
    Write-Host "Config.psm1 not found. Let's create it."

    # Ask the user for the necessary inputs
    $JiraUrl = Read-Host "1) What is your Jira URL (example: https://jira.your-organisation-name.com)"
    $MyUsername = Read-Host "2) What is your Jira username (usually in Name.Surname format)?"
    $ProjectsToIgnore = Read-Host "3) Are there any project prefixes you'd like to ignore while executing scripts (separate them by comma, or just leave it empty for now)"

    # Create the Config.psm1 file
    $configContent = @"
`$JiraUrl = "$JiraUrl"
`$MyUsername = "$MyUsername"
`$ProjectsToIgnore = "$ProjectsToIgnore"

Export-ModuleMember -Variable JiraUrl, MyUsername, ProjectsToIgnore
"@

    # Write the content to Config.psm1 without adding escape characters
    Set-Content -Path $ConfigPath -Value $configContent -NoNewline

    # Inform the user that they can modify the file
    Write-Host "Config.psm1 has been created. You can always modify it by editing the file."
}

# Import the Config.psm1 module
Import-Module $ConfigPath

# Helper function to format script names (removes .ps1 and adds spaces)
function Format-ScriptName {
    param (
        [string]$scriptName
    )
    # Remove .ps1 extension
    $formattedName = $scriptName -replace '\.ps1$', ''
    # Add space before each uppercase letter except the first one
    $formattedName = [regex]::Replace($formattedName, '([a-z])([A-Z])', '$1 $2')
    return $formattedName
}

# Function to read a single key press
function Read-SingleKeyPress {
    $keyInfo = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    return $keyInfo.Character
}

# Endless loop to display the menu and run selected script
while ($true) {
    # Step 1: Execute the GenerateCredentials.ps1 script if it exists (only on the first run)
    if (-not $generateCredentialsRun) {
        $generateCredentialsPath = ".\GenerateCredentials.ps1"
        if (Test-Path $generateCredentialsPath) {
            Write-Host "Running GenerateCredentials.ps1..."
            . $generateCredentialsPath  # Execute the script in the current session
            $generateCredentialsRun = $true
        } else {
            Write-Host "GenerateCredentials.ps1 not found."
        }
    }

    # Step 2: Get a list of all .ps1 scripts in the current directory except Startup.ps1 and GenerateCredentials.ps1
    $scripts = Get-ChildItem -Path ".\Commands" -Filter "*.ps1"

    # Step 3: Display the scripts with numbers and formatted names
    Write-Host "`nAvailable scripts:" -ForegroundColor Green
    for ($i = 0; $i -lt $scripts.Count; $i++) {
        $formattedName = Format-ScriptName $scripts[$i].Name
        Write-Host "$($i + 1). $formattedName"
    }

    # Step 4: Wait for user input (single key press)
    Write-Host "`nPress the number of the script you want to run (or 'q' to quit)"
    $selection = Read-SingleKeyPress
    $type = $selection.GetType().Name

    # Step 5: Exit the loop if user inputs 'q'
    if ($selection -eq 'q') {
        Write-Host "Exiting the program. Goodbye!"
        break
    }

    # Validate input and execute the selected script
    if ($selection -match '^\d+$') {
        $selectedIndex = [int]::Parse($selection) - 1

        if ($selectedIndex -ge 0 -and $selectedIndex -lt $scripts.Count) {
            $selectedScript = $scripts[$selectedIndex].FullName
            Write-Host "`nExecuting $($scripts[$selectedIndex].Name)..."
            . $selectedScript  # Run the script in the current session
        } else {
            Write-Host "`nInvalid selection. Please select a valid number."
        }
    } else {
        Write-Host "`nInvalid input. Please press a number corresponding to a script."
    }

    # Wait for user to press Enter to show the menu again
    Write-Host "`nPress Enter to return to the menu"
    Read-Host
}
