<#

Nekomech
09-08-2014

Move files while replicating directory structure, excluding the designated root of the source, and the designated root of the destination

#>

$Date = Get-Date -f HHmmss_ddyyyy

Stop-Transcript | Out-Null

$logname = "c:\logs\MoveFiles_" + $Date + ".log"
Start-Transcript -path $logname

Write-Output $Date

$sourceroot = "\\Sever01\Folder1"
$destroot = "\\Server02\Folder2\FolderX"



$files  = gci -Path $sourceroot -recurse | where {$_.CreationTime -le (Get-Date).AddDays(-30) -and ($_.length -lt 400000000) -and ((".mp3", ".mp4", ".txt") -contains $_.Extension)}


Foreach ($file in $files){


    IF (!(Test-Path ($file.DirectoryName -replace [regex]::Escape($sourceroot),$destroot))){

        MKDIR ($file.DirectoryName -replace [regex]::Escape($sourceroot),$destroot)

        }

Move-Item $file.FullName -Destination ($file.fullname -replace [regex]::Escape($sourceroot),$destroot) -Verbose

}

Stop-Transcript
