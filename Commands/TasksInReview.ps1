param (
    [Parameter(Position = 0, Mandatory=$true)]
    [string]$ProjectPrefix
)
$jql = "Status in ('In Review') AND Project = $ProjectPrefix AND Labels = 'Mobile' ORDER BY updated, created DESC"

# Execute the query and select specific fields with formatted date
$jiraIssues=Get-JiraIssue -Query $jql | Select-Object Key, Summary, Status, @{Name="Updated";Expression={ (Get-Date $_.Updated -Format "dd/MM/yy HH:mm") }}

$jiraIssues | Format-Table -AutoSize

