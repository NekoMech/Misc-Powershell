###############################################
#
#	Author: Nekomech
#	Date: 12-17-2015
#
#
###############################################


Function Restart-Tomcat {

<#

.SYNOPSIS
	This function gets a list of servers from a text file and iterates through them, stopping the tomcat7 service, cleaning up the tomcat work folder, cleaning up tomcat logs, then starting tomcat7 again.

.DESCRIPTION
	This function gets a list of servers from a text file and iterates through them, stopping the tomcat7 service, cleaning up the tomcat work folder, cleaning up tomcat logs, then starting tomcat7 again.

.PARAMETER ComputerName
	Specifies the path of a text file to get-content from, which should be a list of servers.

.PARAMETER Count
    Specifies the number of retries if the first service recycle fails
    
.PARAMETER FromFile
    Switch that when used requires the user to pass a -Path of a text file that contains Computer Names.
    
.PARAMETER Path
    Path of a file that contains computer names, which the function will run against.

.EXAMPLE
    Example 1
    Restart-Tomcat -ComputerName "Server01","Server02" -Count 5
    
    Exmaple 2
    Restart-Tomcat -FromFile -Path "\\FileServer\Share\all_app_servers.txt" -Count 5

.NOTES
    

#>

[CmdletBinding(DefaultParameterSetName="Default")]

PARAM(
	[Parameter(
        ParameterSetName="Default",
        Mandatory=$true,
        HelpMessage="One or more servers that will be restarted. Fully qualified names preferred")]
    [string[]]
    $ComputerName,
    
    [Parameter(
        Mandatory=$false,
        HelpMessage="Number of times to retry if the initial service restart fails.  Maximum allowed tries is 100.")]
     [ValidateRange(0,100)]
     [int]
     $Count = 5,
     
    [Parameter(
        ParameterSetName="From File",
        Mandatory=$false,
        HelpMessage="Switch that when used treats ServerList as a file system path from which to import servers from a text file")]
    [switch]
    $FromFile,
      
    [Parameter(
        ParameterSetName="From File",
        Mandatory=$true,
        HelpMessage="File path of file that contains server names")]
    [string]
    $Path
)

PROCESS{

    If($FromFile) {
        $ServerList = Get-Content $Path
    } else {
        $ServerList = $ComputerName
    }

    foreach($s in $ServerList) {

    Write-Verbose "Stopping Tomcat7 service on $s"
    Get-Service -ComputerName $s -name Tomcat7 | Stop-Service

    Write-Verbose "Removing Tomcat work folder on $s"
    Remove-Item -Path "\\$s\D$\Program Files\Apache Software Foundation\Tomcat 7.0\work" -Recurse

    Write-Verbose "Removing Tomcat log files on $s"
    Remove-Item -Path "\\$s\D$\Program Files\Apache Software Foundation\Tomcat 7.0\logs\*.*" -Recurse

    Write-Verbose "Removing log files"
    Remove-Item -Path "\\$s\D$\logfolder\logs\*.*" -Recurse

    Write-Verbose "Starting Tomcat7 service on $s"
    Get-Service -ComputerName $s -name Tomcat7 | Start-Service

    Write-Verbose "Checking to make sure that the Tomcat7 service is started"
    If((Get-Service -ComputerName $s -name Tomcat7).Status -eq "Running") {
        Write-Verbose "Tomcat has been restarted successfully on $s"
    } else {
        $i = 0
        DO {Get-Service -ComputerName $s -name Tomcat7 | Start-Service; $i++}
        UNTIL ((Get-Service -ComputerName $s -name Tomcat7).Status -eq "Running" -OR $i -ge $Count)
    }
}
	
}


}
