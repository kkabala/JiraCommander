param (
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$ProjectPrefix,

    [Parameter(Position = 1, Mandatory = $true, HelpMessage="Enter text that summary should contain")]
    [string]$summaryTextFragment
)

# Define allowed issue types
$issueTypes = "Epic, Story, 'Change Request', Bug"

# Build the JQL query
$jql = "project = '$ProjectPrefix' AND issuetype in ($issueTypes) AND summary ~ '$summaryTextFragment'"

$SummaryLength = 70

# Execute the query to search for issues with a truncated summary
Get-JiraIssue -Query $jql | Select-Object Key, @{
    Name="Summary"; 
    Expression={ 
        if ($_.Summary.Length -gt $SummaryLength) { 
            $_.Summary.Substring(0, $SummaryLength) + "..." 
        } else { 
            $_.Summary 
        } 
    } 
}, Status, Assignee, Updated | Format-Table -AutoSize

