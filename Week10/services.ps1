# task: make a menu to list the services that a user specifies.
# this task is way more simple if we just use a while loop.
while ($true) {
    # display the menu and get the user's choice
    Write-Host "What services you you want to see?"
    Write-Host "Please select an option: 'all', 'stopped', 'running', or 'quit' to exit."
    $choice = Read-Host

    # why bother validating custom inputs? I use a switch instead.
    switch ($choice) {
        'all' {
            # get all registered services and display them in a table. figured out that -autosize is a thing.
            Get-Service | Select-Object DisplayName, Status | Format-Table -AutoSize
        }
        'stopped' {
            # get only the stopped services and display them in a table.
            Get-Service | Select-Object DisplayName, Status | Where-Object {$_.Status -eq 'Stopped'} | Format-Table -AutoSize
        }
        'running' {
            # get only the running services and display them in a table.
            Get-Service | Select-Object DisplayName, Status | Where-Object {$_.Status -eq 'Running'} | Format-Table -AutoSize
        }
        'quit' {
            # let the user leave when they type 'quit'.
            exit
        }
        default {
            # display an error message when the input is invalid
            Write-Host "Invalid option. Please select 'all', 'stopped', 'running', or 'quit' to exit."
        }
    }
}
