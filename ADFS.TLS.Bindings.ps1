Write-Output "BE SURE YOU HAVE CUSTOMIZED THE SCRIPT FOR YOUR ADFS/WAP INSTALLATION BEFORE RUNNING"
Write-Output " "
Write-Output "Current ADFS bindings are:"
Write-Output " "
Get-AdfsSslCertificate | fl
Write-Output " "
Write-Output " "
Write-Output " "
Write-Output " "
Write-Output "Bindings shown from netsh before changes"
Write-Output " "
$Command = "http show sslcert"
$Command | netsh
Write-Output " "
Write-Output "BE SURE YOU HAVE CUSTOMIZED THE SCRIPT FOR YOUR ADFS/WAP INSTALLATION BEFORE RUNNING"
read-host “Press ENTER to continue...ctrl-C to Exit”

#Setting the variables to $Null start start of run
$guid = $Null
$certhash = $Null
$stsname = $Null
$certauthstsname = $Null
$certauthport = $Null
$deviceregistration = $Null
$deviceregistrationname = $Null
$GeneralTLSBindingforLoadBlanacersthatdontdoSNIforhealthchecks = $Null


#Setting the variables
$guid = "5d89a20c-beab-4389-9447-324788eb944a"  #app GUID of ADFS
$certhash = "PUT YOU CERT HASH HERE BETWEEN THE DOUBLE QUOTES" #hash of new cert
$stsname = "PUT THE STS NAME HERE BETWEEN THE DOUBLE QUOTES" #dotted domain name of sts
$certauthstsname = "PUT THE CERT AUTH STS NAME HERE BETWEEN THE DOUBLE QUOTES" #dotted domain name of cert auth sts 
$certauthport = "PUT THE CERT AUTH STS NAME HERE BETWEEN THE DOUBLE QUOTES" #Depanding on your setup the certificate auth port could be 49443, 443, or some other port number. YMMV
$deviceregistration = $False # Change to $True if you want to update device registration binding
$deviceregistrationname = "PUT THE DEVICE REGISTERATION NAME HERE BETWEEN THE DOUBLE QUOTES" #If you have device registeration setup on ADFS. i.e. EnterpriseRegistration.contoso.com
$GeneralTLSBindingforLoadBlanacersthatdontdoSNIforhealthchecks = $False # Change to $True if you want to add or refresh a 0.0.0.0:443 binding for Load Balancer health checks

#Is this an ADFS SERVER?
if (Get-WindowsFeature | Where-Object {$_. installstate -eq "installed"} | Where-Object {$_.name -eq "ADFS-Federation"})
{
#Removing the old TLS bindings for ADFS installation
netsh http delete sslcert hostnameport=localhost:443
netsh http delete sslcert hostnameport=$stsname:443
netsh http delete sslcert hostnameport=$certauthstsname+":"+$certauthport

}

#Adding the new TLS bindings for ADFS installation
$hostnameport = $stsname+":443"
$Command = "http add sslcert hostnameport=$hostnameport certhash=$certhash appid={$guid} certstorename=MY sslctlstorename=AdfsTrustedDevices clientcertnegotiation=disable"
$Command | netsh 

$hostnameport = "localhost:443"
$Command = "http add sslcert hostnameport=$hostnameport certhash=$certhash appid={$guid} certstorename=MY sslctlstorename=AdfsTrustedDevices clientcertnegotiation=disable"
$Command | netsh

$hostnameport = $certauthstsname+":"+$certauthport
$Command = "http add sslcert hostnameport=$hostnameport certhash=$certhash appid={$guid} certstorename=MY clientcertnegotiation=enable"
$Command | netsh
}

#Is this an WAP SERVER?
if (Get-WindowsFeature | Where-Object {$_. installstate -eq "installed"} | Where-Object {$_.name -eq "Web-Application-Proxy"})
{
#Removing the old TLS bindings for WAP installation
netsh http delete sslcert hostnameport=$stsname:443
netsh http delete sslcert hostnameport=$certauthstsname+":"+$certauthport

#Adding the new TLS bindings for WAP installation
$hostnameport = $stsname+":443"
$Command = "http add sslcert hostnameport=$hostnameport certhash=$certhash appid={$guid} certstorename=MY sslctlstorename=AdfsTrustedDevices clientcertnegotiation=disable"
$Command | netsh 


$hostnameport = $certauthstsname+":"+$certauthport
$Command = "http add sslcert hostnameport=$hostnameport certhash=$certhash appid={$guid} certstorename=MY clientcertnegotiation=enable"
$Command | netsh
}


#TLS Binding for load balancers that are not capable of SNI for health check
if ($GeneralTLSBindingforLoadBlanacersthatdontdoSNIforhealthchecks)
	{
$ipport = "0.0.0.0:443"
$Command = "http add sslcert ipport=$ipport certhash=$certhash appid={$guid} certstorename=MY"
$Command | netsh
}



Write-Output " "
Write-Output "Bindings shown from netsh AFTER changes"
Write-Output " "
$Command = "http show sslcert"
$Command | netsh