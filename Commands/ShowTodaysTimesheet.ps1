Import-Module ".\Config.psm1"

# Get today's date in the correct format (Jira expects date in YYYY-MM-DD)
$today = (Get-Date).ToString('yyyy-MM-dd')

# Fetch all issues assigned to the current user that are not closed/completed, and expand worklogs
$jql = "assignee = currentUser() AND Status not in ('Done', 'Cancelled', 'Resolved', 'Completed', 'Rejected')"

# Execute the query to get relevant issues and include worklogs
$issues = Get-JiraIssue -Query $jql -Fields "worklog,summary"

# Initialize a list to store results and a total time counter
$worklogResults = @()
$totalTimeLogged = 0

# Loop through each issue and calculate the total hours logged today
foreach ($issue in $issues) {
    # Check if there are any worklogs
    if ($issue.worklog.worklogs.Count -gt 0) {
        $issueTimeLogged = 0

        # Loop through each worklog and check if it matches the current user and today's date
        foreach ($log in $issue.worklog.worklogs) {
            if ($log.author.name -eq $MyUsername -and ($log.started).ToString('yyyy-MM-dd') -eq $today) {
                $issueTimeLogged += [math]::Round($log.timeSpentSeconds / 3600, 2)
            }
        }

        # Add the issue time to the total
        $totalTimeLogged += $issueTimeLogged

        # If time was logged today, add it to the result list
        if ($issueTimeLogged -gt 0) {
            $worklogResults += [PSCustomObject]@{
                'Key'        = $issue.Key
                'Summary'    = $issue.summary
                'TimeLogged' = "$issueTimeLogged h"
            }
        }
    }
}

# Output the results in a table format
if ($worklogResults.Count -gt 0) {
    $worklogResults | Format-Table -Property Key, Summary, TimeLogged -AutoSize
    Write-Host "Time logged in total = $totalTimeLogged h"
} else {
    Write-Host "No time logged today."
}

