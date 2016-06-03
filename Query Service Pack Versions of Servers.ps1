## Powershell Script to query the Service Pack Version for a given list of servers
## Server List Path
$Servers = Get-Content C:\temp\allsvr.txt
## Query WMI-Object of each server in the List and export it to a CSV
Foreach ($server in $Servers)
{
       try
            {
              Get-WmiObject -Class Win32_operatingsystem -ComputerName $server | select -Property PSComputerName, Caption, ServicePackMajorVersion | export-csv c:\temp\exportSPVer.csv -append
             }
            catch 
            {
                # Check for common DCOM errors and display "friendly" output
                switch ($_)
                {
                    { $_.Exception.ErrorCode -eq 0x800706BA } `
                        { $err = 'Unavailable (Host Offline or Firewall)'; 
                            break; }
                    { $_.CategoryInfo.Reason -eq 'UnauthorizedAccessException' } `
                        { $err = 'Access denied (Check User Permissions)'; 
                            break; }
                    default { $err = $_.Exception.Message }
                }
                Add-content C:\temp\exportSPVer.csv "$server - $err"
            } 
    } 

