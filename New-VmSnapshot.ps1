# Module Import
Import-Module Az.Accounts
Import-Module Az.Compute
Import-Module Az.Resources

$TenantID = '00000000-0000-0000-0000-000000000000'
$SubscriptionID = '00000000-0000-0000-0000-000000000000'
$credName = 'myAppCredential'
$VMName = 'MyVM'
$snapShotRGName = 'rg-snapshots'
$vmResourceGroupName = 'rg-vms'
$snapShotName = $VMName + '_' + 'OSDisk_SnapShot' + '_' + ("{0:mmhhddMMyyyy}" -f (Get-Date))
$snapShotVariableName = 'CurrentVMSnapshot'

#Authentication
Write-Verbose 'Reading Credentials and values'
$appCred = Get-AutomationPSCredential -name $CredName
write-Verbose 'Authenticating to Azure with App-Credentials'
Connect-AzAccount -Credential $AppCred -Tenantid $tenantID -ServicePrincipal |out-null
Select-AzSubscription -Subscriptionid $SubscriptionID

#Get Current VM Data and Disk information
$vm = Get-AzVM -Name $VMName
$origDisk = Get-AzDisk -DiskName $vm.StorageProfile.OsDisk.Name

#Shutdown VM
Stop-AzVM -Name $VMName -ResourceGroupName $vmResourceGroupName -Force

# Get Location from snapshot ResourceGroup

#Ceate Snapshot
$SnapshotConfigParam = @{
    SourceUri = $($OrigDisk.id)
    Location = (Get-AzResourceGroup -Name $snapShotRGName).Location
    CreateOption = 'Copy'
}
$snapShotConfig = New-AzSnapshotConfig @SnapShotConfigParam
New-AzSnapshot -ResourceGroupName $snapshotRGName -SnapshotName $snapShotName -Snapshot $snapShotConfig

Set-AutomationVariable -Name $snapShotVariableName -Value $SnapShotName

#Restart VM
Start-AzVM -Name $vmName -ResourceGroupName $vmResourceGroupName -NoWait
