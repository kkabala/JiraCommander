param (
    [Parameter(Position = 0, Mandatory = $true)]  # Ticket number as the first positional parameter
    [string]$TicketNumber
)

Import-Module ".\Config.psm1"

# Define Jira base URL
# Construct the full URL for the ticket
$ticketUrl = "${JiraUrl}/browse/${TicketNumber}"

# Open the ticket in the default browser
Start-Process $ticketUrl