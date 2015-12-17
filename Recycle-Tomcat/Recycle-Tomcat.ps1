###############################################
#
#	Author: Nekomech
#	Date: 12-17-2015
#
#
###############################################


Function Recycle-Tomcat {

<#

.SYNOPSIS
	This function gets a list of servers from a text file and iterates through them, stopping the tomcat7 service, cleaning up the tomcat work folder, cleaning up tomcat logs, then starting tomcat7 again.

.DESCRIPTION
	This function gets a list of servers from a text file and iterates through them, stopping the tomcat7 service, cleaning up the tomcat work folder, cleaning up tomcat logs, then starting tomcat7 again.

.PARAMETER	ServerList
	Specifies the path of a text file to get-content from, which should be a list of servers.

.PARAMETER Count
    Specifies the number of retries if the first service recycle fails

.EXAMPLE
    Recycle-Tomcat -Server "C:\tmp\ls_preproduction_app.txt" -Count 5

.NOTES
    This was designed to be ran in a scheduled task, which is why I am calling the function at the bottom.

#>

[CmdletBinding()]

PARAM(
	[Parameter(
		Mandatory=$true,
		HelpMessage="A text file that contains computers to target")]
     [string[]]
     $ServerList,

    [Parameter(
        HelpMessage="Number of times to retry if the initial service recycle fails")]
     [ValidateRange(0,100)]
     [int]
     $sount = 5

)

PROCESS{

    $ComputerName = Get-Content -Path $ServerList

    foreach($c in $ComputerName) {

    Write-Verbose "Stopping Tomcat7 service on $c"
    Get-Service -ServerList $c -name Tomcat7 | Stop-Service

    Write-Verbose "Removing Tomcat work folder on $c"
    Remove-Item -Path "\\$s\D$\Program Files\Apache Software Foundation\Tomcat 7.0\work" -Recurse

    Write-Verbose "Removing Tomcat log files on $c"
    Remove-Item -Path "\\$s\D$\Program Files\Apache Software Foundation\Tomcat 7.0\logs\*.*" -Recurse

    Write-Verbose "Removing CWCTravel log files"
    Remove-Item -Path "\\$s\D$\cwctravel\logs\*.*" -Recurse

    Write-Verbose "Starting Tomcat7 service on $c"
    Get-Service -ServerList $c -name Tomcat7 | Start-Service

    Write-Verbose "Checking to make sure that the Tomcat7 service is started"
    If((Get-Service -ServerList $c -name Tomcat7).Status -eq "Running") {
        Write-Verbose "Tomcat has been restarted successfully on $c"
    } else {
        $i = 0
        DO {Get-Service -ServerList $c -name Tomcat7 | Start-Service; $i++}
        UNTIL ((Get-Service -ServerList $c -name Tomcat7).Status -eq "Running" -OR $i -ge $sount)
    }
}
	
}


}

Recycle-Tomcat -ServerList C:\notafolder\notafile.txt -Count 3