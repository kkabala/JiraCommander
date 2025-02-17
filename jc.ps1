param (
    [string]$actionName,
    [string]$argument
)

$moduleFile = Join-Path $PSScriptRoot "Config.psm1"
Import-Module $moduleFile -Force

function Install-JiraPSModule {
    if (-not (Get-Module -ListAvailable -Name JiraPS)) {
        Write-Host "JiraPS module not found. Installing JiraPS module..."
        try {
            Install-Module -Name JiraPS -Force -Scope CurrentUser
            Write-Host "JiraPS module installed successfully."
        }
        catch {
            Write-Host "Error installing JiraPS module. Please ensure you have internet access and run this script with sufficient permissions."
            exit 1
        }
    }
}

function Save-CredentialsFile {
    $credentialsPath = Join-Path $PSScriptRoot ".credentials"
    if (-not (Test-Path $credentialsPath)) {
        Write-Host ".credentials file not found. Let's create it."
        $username = Read-Host "Enter your Jira username"
        $password = Read-Host "Enter your Jira password" -AsSecureString
        $credential = New-Object -TypeName PSCredential -ArgumentList $username, $password
        $credential | Export-CliXml -Path $credentialsPath
        Write-Host ".credentials file has been created."
    }
}

# Clean Jira markup from text
function Clean-JiraMarkup {
    param (
        [string]$text
    )
    $text = $text -replace '\{panel:title=[^}]+\}', "`n"
    $text = $text -replace '\{panel\}', ""
    $text = $text -replace '!.*!', ""
    $text = $text -replace '\|.*?width=\d+height=\d+\|', ""
    $text = $text -replace '\[.*?\]', ""
    $text = $text -replace '\*', ""
    $text = $text -replace '\+', "'"
    # Remove empty sections and their headings
    $text = $text -replace '(?m)^(UI|UX|UX link):(\s*\r?\n|$)', ""
    # Clean up multiple empty lines
    $text = $text -replace '[\r\n]{3,}', "`n`n"
    # Remove trailing ';Prompt=' line
    $text = $text -replace ';Prompt=.*$', ""
    return $text.Trim()
}

function Connect-Jira {
    $credentialsPath = Join-Path $PSScriptRoot ".credentials"
    $credential = Import-CliXml -Path $credentialsPath
    
    if (-not (Get-Variable -Name JiraUrl -ErrorAction SilentlyContinue)) {
        Write-Host "Jira URL is not set. Please check your Config.psm1 file."
        exit 1
    }
    
    Set-JiraConfigServer -Server $JiraUrl
    New-JiraSession -Credential $credential | Out-Null
}

function Get-JiraTicketSummary {
    param (
        [string]$ticketNumber
    )
    $issue = Get-JiraIssue -Key $ticketNumber
    Write-Host "Summary: $($issue.Summary)"
    $cleanDescription = Clean-JiraMarkup -text $issue.Description
    Write-Host "`nDescription:`n$cleanDescription"
}

Install-JiraPSModule
Save-CredentialsFile

if (-not (Get-Variable -Name JiraUrl -ErrorAction SilentlyContinue)) {
    Write-Host "Jira URL is not set. Please check your Config.psm1 file."
    exit 1
}

Connect-Jira

switch ($actionName) {
    "summary" {
        Get-JiraTicketSummary -ticketNumber $argument
        break
    }
    default {
        Write-Host "Unknown action: $actionName"
        break
    }
}