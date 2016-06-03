 
$Credential = Get-Credential -Credential 'sbicza01\ec733365'
$ComputerName = Get-Content "C:\temp\comp.txt"
function Format-HumanReadable 
{
            param ($size)
            switch ($size) 
            {
                {$_ -ge 1PB}{"{0:#.#',P'}" -f ($size / 1PB); break}
                {$_ -ge 1TB}{"{0:#.#',T'}" -f ($size / 1TB); break}
                {$_ -ge 1GB}{"{0:#.#',G'}" -f ($size / 1GB); break}
                {$_ -ge 1MB}{"{0:#.#',M'}" -f ($size / 1MB); break}
                {$_ -ge 1KB}{"{0:#',K'}" -f ($size / 1KB); break}
                default {"{0}" -f ($size) + "B"}
            }
}
        
        $wmiq = 'SELECT * FROM Win32_LogicalDisk WHERE Size != Null AND DriveType >= 2'
        foreach ($computer in $ComputerName)
        {
            try
            {
                    $disks = Get-WmiObject -Query $wmiq `
                             -ComputerName $computer -Credential $Credential `
                             -ErrorAction Stop

                   # Create array for $disk objects and then populate
                    $disks | ForEach-Object { $diskarray += $_.Size }
                    

                       
              
            }
            catch 
            {
                # Check for common DCOM errors and display "friendly" output
                switch ($_)
                {
                    { $_.Exception.ErrorCode -eq 0x800706ba } `
                        { $err = 'Unavailable (Host Offline or Firewall)'; 
                            break; }
                    { $_.CategoryInfo.Reason -eq 'UnauthorizedAccessException' } 
                        { $err = 'Access denied (Check User Permissions)'; 
                            break; }
                    default { $err = $_.Exception.Message }
                }
                Write-Warning "$computer - $err"
            } 
    }
$diskarray | Select-Object @{n='Size';e={Format-HumanReadable $_}} | export-csv c:\temp\hdd.csv




