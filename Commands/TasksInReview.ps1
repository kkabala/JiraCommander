param (
    [Parameter(Position = 0, Mandatory=$true)]
    [string]$ProjectPrefix,

    [Parameter(Position = 1, Mandatory=$true, HelpMessage="Specify labels or leave as 'None' to skip the filtering")]
    [string]$Labels = "None"
)
$jql = "Status in ('In Review', 'Review') AND Project = $ProjectPrefix"
if ($Labels -ne "None") {
    $jql += " AND Labels = '$Labels'"
}
$jql += " ORDER BY updated, created DESC"

# Execute the query and select specific fields with formatted date
$jiraIssues=Get-JiraIssue -Query $jql | Select-Object Key, Summary, Status, @{Name="Updated";Expression={ (Get-Date $_.Updated -Format "dd/MM/yy HH:mm") }}

$jiraIssues | Format-Table -AutoSize

