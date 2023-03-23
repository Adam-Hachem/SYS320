# Storyline: Review the Security Event Log

# Directory to save files:
$myDir = "C:\Users\adam\Desktop\"

# List all the available Windows Event logs
Get-EventLog -List

# Create a prompt to allow a user to select a log to view
$readLog = Read-Host -Prompt "Please select a log to review from the list above."

# Task: Create a prompt to allow a user to specify a keyword or phrase to search on.
# Find a string from your event logs to search on
$searchLog = Read-Host -Prompt "Please specify the keyword or phrase you would like to search for."

# Print the log to the screen
Get-EventLog -LogName $readLog | Where-Object {$_.Message -ilike "*$searchLog*" } | Export-Csv -NoTypeInformation `
-Path $myDir\SecurityLogs.csv