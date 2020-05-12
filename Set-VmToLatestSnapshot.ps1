# Module Import
Import-Module Az.Compute

#Define Variables
$TenantID = '00000000-0000-0000-0000-000000000000'
$SubscriptionID = '00000000-0000-0000-0000-000000000000'
$credName = 'myAppCredential'
$VMName = 'MyVM'
$snapShotRGName = 'rg-snapshots'
$vmResourceGroupName = 'rg-vms'
$snapShotName = Get-AutomationVariable -Name 'CurrentVMSnapshot' 


#Authentication
Write-Verbose 'Reading Credentials and values'
$appCred = Get-AutomationPSCredential -name $CredName
write-Verbose 'Authenticating to Azure with App-Credentials'
Connect-AzAccount -Credential $AppCred -Tenantid $tenantID -ServicePrincipal |out-null
Select-AzSubscription -Subscriptionid $SubscriptionID


#Create New Disk from Snapshot
$LatestSnapShot = Get-AzSnapshot -ResourceGroupName $snapShotRGName -SnapshotName $SnapshotName
$NewDiskConfigParam = @{
    Location = $($LatestSnapShot.Location)
    DiskSizeGB = $($LatestSnapShot.DiskSizeGB)
    AccountType = $($LatestSnapShot.SKU.Name)
    OsType = $($LatestSnapShot.OsType)
    CreateOption = 'Copy'
    SourceUri = $($LatestSnapShot.id)
}
#NewDiskConfigParam
$NewDiskConfigParam
$NewDiskConfig = New-AzDiskConfig @NewDiskConfigParam 
$NewDisk = New-Azdisk -Disk $NewDiskConfig -ResourceGroupName $vmResourceGroupName -DiskName $snapShotName

#Update Disk Config and reboot VM
$VM = Get-AzVM -Name $VMName
Stop-AzVM -Name $VMName -Force -ResourceGroupName $vmResourceGroupName
Set-AzVMOSDisk -VM $vm -ManagedDiskId $NewDisk.id -Name $NewDisk.Name
Update-AzVM -ResourceGroupName $vmResourceGroupName -VM $vm
Start-AzVM -Name $VMName -ResourceGroupName $vmResourceGroupName
