#Original code and idea from Harry Zhao. Updated code for WAP and load balancer inclusion

#Comment out sections that are not needed for you specific use case

#Setting the variables
$guid = "5d89a20c-beab-4389-9447-324788eb944a"  
$certhash = "PUT YOU CERT HASH HERE" #hash of new cert
$stsname = "PUT THE STS NAME HERE" #dotted domain name of sts
$certauthstsname = "PUT THE CERT AUTH STS NAME HERE" #dotted domain name of cert auth sts 
$certauthport = "49443" #Depanding on your setup the certificate auth port could be 49443, 443, or some other port number. YMMV

#Removing the old TLS bindings
netsh http delete sslcert hostnameport=localhost:443
netsh http delete sslcert hostnameport=$stsname:443
netsh http delete sslcert hostnameport=$stsname:49443


#Adding the new TLS bindings
$hostnameport = $stsname+":443"
$Command = "http add sslcert hostnameport=$hostnameport certhash=$certhash appid={$guid} certstorename=MY sslctlstorename=AdfsTrustedDevices clientcertnegotiation=disable"
$Command | netsh 

$hostnameport = "localhost:443"
$Command = "http add sslcert hostnameport=$hostnameport certhash=$certhash appid={$guid} certstorename=MY sslctlstorename=AdfsTrustedDevices clientcertnegotiation=disable"
$Command | netsh

$hostnameport = $certauthstsname+":"+$certauthport
$Command = "http add sslcert hostnameport=$hostnameport certhash=$certhash appid={$guid} certstorename=MY clientcertnegotiation=enable"
$Command | netsh



#TLS Binding for load balancers that are not capable of SNI for health check
$ipport = "0.0.0.0:443"
$Command = "http add sslcert hostnameport=$hostnameport certhash=$certhash appid={$guid} certstorename=MY"
$Command | netsh



#Binding just for WAP
$hostnameport = $stsname+":443"
$Command = "http add sslcert hostnameport=$hostnameport certhash=$certhash appid={$guid} certstorename=MY sslctlstorename=AdfsTrustedDevices clientcertnegotiation=disable"
$Command | netsh 


$hostnameport = $certauthstsname+":49443"
$Command = "http add sslcert hostnameport=$hostnameport certhash=$certhash appid={$guid} certstorename=MY clientcertnegotiation=enable"
$Command | netsh
