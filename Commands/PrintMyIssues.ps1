$jql = "assignee = currentUser() AND Status not in ('Done', 'Cancelled', 'Resolved', 'Completed', 'Rejected')"
if ($ProjectsToIgnore -ne "") {
    $jql += " AND PROJECT NOT IN (${ProjectsToIgnore})"
}

$filters = ' ORDER BY updated, created DESC'

# Add project prefix filter if provided
if ($ProjectPrefix -ne "") {
    $jql += " AND project = '$ProjectPrefix'"
}

# Order by updated, created
$jql += $filters

# Execute the query
$jiraIssues = Get-JiraIssue -Query $jql
$jiraIssues | Format-Table -AutoSize
