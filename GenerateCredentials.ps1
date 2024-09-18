# Import the module and connect to Jira
Import-Module JiraPS
Import-Module ".\Config.psm1"

Set-JiraConfigServer $JiraUrl
$cred = Get-Credential

New-JiraSession -Credential $cred