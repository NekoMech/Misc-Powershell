<#
Backup-JenkinsConfig
Nekomech
12-14-2015
#>

#################
#Jenkins Backup
#################

#Setting variables
$DateTime = Get-Date -Format yyyy-MM-dd-hhmmss
$LogFile = "\\Server01\D$\Backups\jenkinsbackup." + $DateTime + ".log"
$JenkinsSource = "D:\jenkins\"
$JenkinsDestination = "\\Server01\D$\Backups\jenkins " + $DateTime
$DestinationRoot = "\\Server01\D$\Backups\"

#Recreating the destination root if it does not exist
If(!(Test-Path -path $DestinationRoot)) {
    Write-Verbose "$($DestinationRoot) not found! Creating directory..."
    New-Item -ItemType Directory -Path $DestinationRoot
    Write-Verbose "Directory created successfully!"
} else {
    Write-Verbose "Destination root already exists, continuing..."
}

#Creating the Jenkins Backup destination
if(!(Test-path -path $JenkinsDestination)) {
	Write-Verbose "Creating Jenkins backup destination at $($JenkinsDestination)"
	New-Item -ItemType Directory -Path $JenkinsDestination
}

#Running the Robocopy command
ROBOCOPY $JenkinsSource $JenkinsDestination /R:1 /W:1 /B /COPYALL /E /NP /SL >> $LogFile

#Cleaning up old Backup directories
$olddir = Get-ChildItem -Path $DestinationRoot | Where {$_.CreationTime -le (Get-Date).AddDays(-4) -AND $_.PSisContainer -eq $true}
foreach($o in $olddir){
    Write-Verbose "Removing file or directory $o"
    CMD /c RD /S /Q $o.Fullname
}

#Cleaning up old logs
$oldlog = Get-ChildItem -Path $DestinationRoot | Where {$_.CreationTime -le (Get-Date).AddDays(-4) -AND $_.PSisContainer -eq $false}
foreach($o in $oldlog){
    Write-Verbose "Removing file $o"
    CMD /c DEL /Q $o.Fullname
}

