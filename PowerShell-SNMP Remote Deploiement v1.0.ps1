#SNMP Remote Deploiement-PowerShell v1.0
# Retrieve list of machines where SNMP will be installed and authorized
$ListSrv = Get-Content -Path c:\temp\list_srv_deploy_snmp.txt
$Results = @()
$Log = "C:\temp\log_deploy_snmp.log"

foreach ($hostname in $ListSrv){

# Creation of a remote session with PowerShellSession (PSS)
Write-host "Session vers $hostname"
$session = New-PSSession -ComputerName $hostname

# SNMP presence verification
$check = Invoke-Command -Session $session -ScriptBlock { Get-WindowsFeature | Where-Object {$_.Name -eq "SNMP-Service"} }

# If SNMP is not present then start the installation
If ($check.Installed -ne "True") {

# SNMP deploiement and configuration of the firewall
Write-host "Installation SNMP vers $hostname"
Invoke-Command -Session $session -ScriptBlock {
Get-WindowsFeature *snmp* |Install-WindowsFeature
Restart-service snmp** 
Import-Module NetSecurity 
New-NetFirewallRule -Name Allow_Ping -DisplayName “Allow Ping”  -Description “Ping ICMPv4” -Protocol ICMPv4 -IcmpType 8 -Enabled True -Profile Any -Action Allow
Gpupdate /force
Restart-service snmp** 
}
}

# Verification after installation
$checkafter = Invoke-Command -Session $session -ScriptBlock { Get-WindowsFeature | Where-Object {$_.Name -eq "SNMP-Service"} }

If ($checkafter.Installed -eq "True") {
$Results += "$hostname;'OK'"
} Else { $Results += "$hostname;'KO'" }

# Session closed
Remove-PSSession $session
}

$Results >> $log

Write-Host "Deploiement terminé !"