# Backing up an Azure VM (like SEPPmail) with Snapshots

## Overview

For appliance-type Linux-VM´s like SEPPmail, Azure Backup is not a good choice, because internal running services like databases wont most likely be backed up correctly. In this case snapshots are a better way to get a consistent state of a VM for recovery purposes.

The scripts in this example show how to create a snapshot of a VM and restore the VM from this snapshot. The platform it runs on is Azure Automation because its flexibility on scheduling and remote triggering (Webhooks). With a little bit of modification, you be able to run this from your workstation or any other automation platform.

## Prerequisites

You need:

* Azure Subscription and a working VM inside
* Contributor rights on the resources we use in the Subscription
* Admin rights in the Tenant to register an App.

## Preparation

Collect some information to prepare the script:

* Tenant ID of the tenant the VM runs in
* Subscription ID of the subscription the VM runs and where you want the snapshot to be created
* An App registration (Credential Information) with:
  * Contributor rights in the resource groups for the snapshot
  * Contributor rights on the VM you want to snapshot
* An Azure Automation Account with:
  * A credential object to store the App Registration information
  * A variable to store the current name of the Snapshot
  * Az.Accounts module installed in its current version
  * Az.Compute module installed in its current version
* The names of:
  * The resource groups of the VM and the one for the Snapshot (may be the same)
  * The resource group of the Automation Account
* The Azure Location the snapshot and the new disk shall be created

We assume the snapshot and the VM are located in the same tenant/subscription.

## Setup

1. First create the App Registration and assign contributor rights to the resources as described above.
2. Create the Azure Automation Account
3. Then create the Credential object in Azure Automation and remember its name
4. Create the cariable called "CurrentVMSnapshot" in Azure Automation with value 'never run' (or something similar).
5. Import the missing Modules Az.Accounts, Az.Compute and Az.Resources
6. Import the two Powershell scripts as runbooks into Azure Automation
7. Fill in correct values into the authentication and variables-section of the 2 runbooks.
8. Run New-VMSnapshot to create a snapshot
9. Run Set-VmToLatestSnapshot to restore to the latest snapshot.

!! Be aware that restoring to a snapshot reboots the VM and deletes all changes which have been done in between snapshot time and restore time. !!

## What the runbooks actually does

### New-VmSnapShot.ps1

First it authenticates to the Azure Tenant and selects the correct subscription.
Then the VM and its OSDisk is identified and the VM is shut down. A snapshot from the cold VM is created and stored in the defined resource group. Then it sets the variable "CurrentVMSnapshot" to the actual name of the snapshot. Finally the VM is started again.

### Set-VmToLatestSnapshot.ps1

If the VM needs to be restored to the latest snapshot, the runbook authenticates to the tenant, selects the right subscription and first created a new disk of the latest snapshot. The new disk will have the same name like the Snapshot. After disk creation the VM gets stopped, and the new OSDisk is configured for the VM. Then the VM is started with the new disk.

## Notes

Snapshots and new disks consume storage space. The script has no option to do housekeeping and get rid of old snapshots or disks. If you plan to use this in production, you need to extend the script for your needs to balance costs and meaningful operation. Also things like error handling and proper reporting/notification might be something you may implement.

## END
