# Task: Export your list of running processes and running services on your system into separate files.
# Export the list of running processes into a CSV file.
Get-Process | Select-Object ProcessName, Path, ID | `
Export-Csv -Path "C:\Users\adam\Desktop\SYS320\SYS320\Week9\processes.csv" -NoTypeInformation
# Export the list of running services into a CSV file.
Get-Service | Where-Object {$_.Status -eq "Running"} | Select-Object Name, Status, DisplayName | `
Export-Csv -Path "C:\Users\adam\Desktop\SYS320\SYS320\Week9\services.csv" -NoTypeInformation