<#
Explain why you selected those four cmdlets and the value it would provide for an incident investigation.
    I don't have much DF knowledge, so I did some Googling on it and I settled on getting the logs for the System, Security, Application, and PowerShell history. The System and Security event logs are supposed to be useful for tracking user activity, and the Application event logs are supposed to be useful for tracking application activity. Because Powershell is so powerful on Windows, it could easily be abused by malware to carry out malicious actions. This makes it a good log to collect.
#>

# prompt the user for the folder path to save the results, and make a new directory structure to save the results
$folderPath = Read-Host "Enter the folder path to save the results"
New-Item -ItemType Directory -Path "$folderPath\IncidentResponseToolKit" | Out-Null
New-Item -ItemType Directory -Path "$folderPath\IncidentResponseToolKit\csv" | Out-Null

# retrieve running processes and their paths
Get-Process | Select-Object ProcessName, Path | Export-Csv -Path "$folderPath\IncidentResponseToolKit\csv\processes.csv" -NoTypeInformation
Write-Host "Processes saved to $folderPath\IncidentResponseToolKit\csv\processes.csv"

# retrieve registered services and their executable paths
Get-WmiObject -Class Win32_Service | Select-Object Name, DisplayName, PathName | Export-Csv -Path "$folderPath\IncidentResponseToolKit\csv\services.csv" -NoTypeInformation
Write-Host "Services saved to $folderPath\IncidentResponseToolKit\csv\services.csv"

# retrieve all TCP network sockets
Get-NetTCPConnection | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State | Export-Csv -Path "$folderPath\IncidentResponseToolKit\csv\tcpSockets.csv" -NoTypeInformation
Write-Host "TCP sockets saved to $folderPath\IncidentResponseToolKit\csv\tcpSockets.csv"

# retrieve user account information and their privelege level
Get-WmiObject -Class Win32_UserAccount | Select-Object Name, FullName, Description, Privileges | Export-Csv -Path "$folderPath\IncidentResponseToolKit\csv\users.csv" -NoTypeInformation
Write-Host "User accounts saved to $folderPath\IncidentResponseToolKit\csv\users.csv"

# retrieve network adapter configuration information
Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE | Format-List IPAddress, DefaultIPGateway, DNSServerSearchOrder, DHCPServer | Export-Csv -Path "$folderPath\IncidentResponseToolKit\csv\networkAdapterConfiguration.csv" -NoTypeInformation
Write-Host "Network adapter configuration saved to $folderPath\IncidentResponseToolKit\csv\networkAdapterConfiguration.csv"

# save 4 other artifacts that would be useful in an incident investigation

# save system event logs to a CSV file (1/4)
Get-EventLog -LogName System -Newest 1000 | Export-Csv -Path "$folderPath\IncidentResponseToolKit\csv\sysEventLogs.csv" -NoTypeInformation
Write-Host "System event logs saved to $folderPath\IncidentResponseToolKit\csv\sysEventLogs.csv"

# save security event logs to a CSV file (2/4)
Get-EventLog -LogName Security -Newest 1000 | Export-Csv -Path "$folderPath\IncidentResponseToolKit\csv\secEventLogs.csv" -NoTypeInformation
Write-Host "Security event logs saved to $folderPath\IncidentResponseToolKit\csv\secEventLogs.csv"

# save application event logs to a CSV file (3/4)
Get-EventLog -LogName Application -Newest 1000 | Export-Csv -Path "$folderPath\IncidentResponseToolKit\csv\appEventLogs.csv" -NoTypeInformation
Write-Host "Application event logs saved to $folderPath\IncidentResponseToolKit\csv\appEventLogs.csv"

# save PowerShell history to a CSV file (4/4)
Get-WinEvent Microsoft-Windows-PowerShell/Operational -MaxEvents 1000 | Export-Csv -Path "$folderPath\IncidentResponseToolKit\csv\psEventLogs.csv" -NoTypeInformation
Write-Host "PowerShell event logs saved to $folderPath\IncidentResponseToolKit\csv\psEventLogs.csv"

# function to create file hashes, it is called twice, defined by $num.
function create_hash_file($num) {
    # if $num = 1, collect the file hashes for each CSV file and save them to a file:
    if ($num -eq 1) {
        # get the files in the csv directory
        $files = Get-ChildItem -Path "$folderPath\IncidentResponseToolKit\csv\*.csv"
        # loop through the files
        foreach ($file in $files) {
            # Append the file hash and path of each file to a CSV file called "fileHashes.csv"
            Get-FileHash -Path $file.FullName -Algorithm SHA256 | Export-Csv -Path "$folderPath\IncidentResponseToolKit\csv\fileHashes.csv" -Append -NoTypeInformation
        }
    }
    # if $num = 2, get the file hash for the zip file and save it to a file:
    elseif ($num -eq 2) {
        # Append the file hash and path of the zip to a CSV file called "zipHash.csv"
        Get-FileHash -Path $zipPath -Algorithm SHA256 | Export-Csv -Path "$folderPath\IncidentResponseToolKit\zipHash.csv" -NoTypeInformation
    }
}

# collect the file hashes for each CSV file and save them to a file:
create_hash_file(1)

# compress the folder containing the results and save it to a zip file
$zipPath = "$folderPath\IncidentResponseToolKit\results.zip"
Compress-Archive -Path "$folderPath\IncidentResponseToolKit\csv\*" -DestinationPath $zipPath

# get the file hash for the zip file and save it to a file
create_hash_file(2)