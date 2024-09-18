param (
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$Issue,  # The Jira issue key (e.g., "PROJ-123")

    [Parameter(Position = 1, Mandatory = $true)]
    [string]$TimeSpent,  # Time spent in "m" (minutes), "h" (hours), or "d" (days)

    [Parameter(Position = 2, Mandatory = $false)]
    [string]$Comment = "N/A"  # Optional comment, default is an empty string
)

# Import JiraPS module (if not already loaded)
Import-Module JiraPS

# Helper function to convert time to seconds
function Convert-TimeSpent {
    param (
        [string]$timeSpent
    )

    if ($timeSpent -match '(\d+)([mhd])$') {
        $value = [int]$matches[1]
        $unit = $matches[2]

        switch ($unit) {
            'm' { return [TimeSpan]::FromMinutes($value) }  # Minutes to TimeSpan
            'h' { return [TimeSpan]::FromHours($value) }    # Hours to TimeSpan
            'd' { return [TimeSpan]::FromHours($value * 8) } # Days to TimeSpan (8 hours per day)
        }    
    }
    else {
        throw "Invalid TimeSpent format. Use a number followed by 'm', 'h', or 'd'."
    }
}

# Convert the TimeSpent to Jira-compatible format (seconds)
$timeInSeconds = Convert-TimeSpent -timeSpent $TimeSpent

Add-JiraIssueWorklog -Issue $Issue -TimeSpent "$timeInSeconds" -Comment $Comment -DateStarted (Get-Date)

Write-Host "Time logged successfully on issue ${Issue}: $TimeSpent"
if ($Comment -ne "") {
    Write-Host "Comment: $Comment"
}

