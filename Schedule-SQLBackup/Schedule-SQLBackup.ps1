<#-------------------------------------------------------------------------

Author: Nekomech
Date: 06/14/2014

Description:  This will create a scheduled task on the local machine which 
in turn runs a SQL backup

-------------------------------------------------------------------------#>

$script:creds = Get-Credential

function Create-Job
{
    
DO {

$arg1 = $null
$arg2 = $null
$getschedule = $null
$datetime = $null
#$creds = $null
$dt = $null
$confirm = $Null

$arg1 = Read-Host "SQL Server Name?"
$arg2 = Read-Host "Database Name?"
$getschedule = Read-Host "Scheduled Date and Time? in MM/dd/hh:mm format like "
$datetime = [datetime]::ParseExact($getschedule,"MM/dd/HH:mm",$null)
$dt = Get-Date -Format yyyyMMdd_HHmmss
#Write-Host "Getting user credentials to run the job as..."
#Start-Sleep -s 1
#$creds = Get-Credential
$confirm = Read-Host "$arg1`n$arg2`n$datetime`nEnter [Y] to confirm these settings"

}

UNTIL ($confirm -ne "Y")


$a = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy bypass -File \\share\scripts\AdHoc-SQLBackup.ps1 $arg1 $arg2"
$T = New-ScheduledTaskTrigger -Once -At $datetime
$S = New-ScheduledTaskSettingsSet
$D = New-ScheduledTask -Action $a -Trigger $T -Settings $S
Register-ScheduledTask BackupTask_$dt -InputObject $D -User $script:creds.UserName -Password $script:creds.GetNetworkCredential().password


}

Create-Job

WHILE ((Read-Host "Keep going? [Y]") -eq "y")
    {

    Create-Job

    }

Write-Host "Exiting in 2s..."
Start-Sleep -s 1.5
EXIT
