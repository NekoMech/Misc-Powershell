#Nekomech
#5-15-2015
#Install-Certs function



#defining a certificate install function

[cmdletbinding()]

param(

#certificate store where the certificate will be installed
[ValidateSet("Personal","IntermediateCA","ThirdPartyRootCA")]
[string]
$StoreLocation,

#path of certificate(s) to install
[ValidateNotNullOrEmpty()]
[string[]]
$CertPath,

#path to text file that has certificate password
[string]
$certpassword,

#if no pass, use this switch to bypass getting the password
[switch]
$NoPass

)

#setting error action preference to stop
$ErrorActionPreference = "Stop"

#timestamp function
function Timestamp {

#outputs date-time
Get-Date -Format MM/dd/yy.hhmmss

}

#defining certificate store location based on user input
switch ($StoreLocation) {
    Personal {[string]$certificateStorePath = "My"}
    IntermediateCA {[string]$certificateStorePath = "CA"}
    ThirdPartyRootCA {[string]$certificateStorePath = "AuthRoot"}
    default {Write-Output "$StoreLocation is not a valid parameter! Please enter in one of the following: Personal, IntermediateCA, ThirdPartyRootCa" | Out-File -FilePath $log -Append; EXIT}
}

#checking for log file
$log = "C:\Users\$env:USERNAME\Install-Certs.log"
Try {
    if((Test-Path -Path $log) -eq $false) {
        New-Item -ItemType File -Path $log 
        Write-Verbose "Created log file at $log"
    } else {
        Write-Verbose "$(timestamp) Log file already exists!" 
    }
} Catch {
    Write-Error "$(timestamp) Unable to create the log file! Make sure you have the correct permission."
}

#getting certificate file
Try{
    $certfile = Get-Item -Path $CertPath 
    Write-Verbose "$(Timestamp) retrieved item $certfile"
} catch {
    throw
}

#getting password from text file
if(!$NoPass){
    Try {
        $pass = Get-Content -Path $certpassword 
        Write-Verbose "$(timestamp) imported password from $certpassword"
    } Catch {
        throw
    }
} Else {
    Write-Verbose "NoPass switch found. No password for this certificate, continuing..."
}


#if certificate is a collection, creating the certificate collection object and loading it into memory
Try {
    if($pass) {
        $certificateCollection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
        $certificateCollection.Import($CertPath, $pass, "Exportable,PersistKeySet")
        Write-Verbose "$(timestamp) Created the Certificate Collection object and imported $CertPath successfully!"
        foreach($c in $certificateCollection) {
            if(!(Test-Path -Path ("cert:\CurrentUser\" + $certificateStorePath + "\" + $c.Thumbprint))) {
                $certStore = New-Object System.Security.Cryptography.X509Certificates.X509Store -ArgumentList $certificateStorePath, "CurrentUser" 
                $certStore.Open('ReadWrite')
                $certStore.Add($c)
                $certStore.Close()
                Write-Verbose "$(timestamp) Added certificate $($c.Thumbrint) successfully!"
            } else {
                Write-Verbose "$(timestamp) Certificate $($c.Thumbprint) is already installed!"
            }
        }
    } else {
        $certificateCollection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
        $certificateCollection.Import($CertPath)
        Write-Verbose "$(timestamp) Created the Certificate Collection object and imported $CertPath successfully!"
        foreach($c in $certificateCollection) {
            if(!(Test-Path -Path ("cert:\CurrentUser\" + $certificateStorePath + "\" + $c.Thumbprint))) {
                $certStore = New-Object System.Security.Cryptography.X509Certificates.X509Store -ArgumentList $certificateStorePath, "CurrentUser" 
                $certStore.Open('ReadWrite')
                $certStore.Add($c)
                $certStore.Close()
                Write-Verbose "$(timestamp) Added certificate $($c.Thumbrint) successfully!"
            } else {
                Write-Verbose "$(timestamp) Certificate $($c.Thumbprint) is already installed!"
            }
        }
    }

} catch {
    throw
}
