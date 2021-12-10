# Simple Script used to move files and automize some workflow

# Path Location:

$InboxPath = "Inbox Location"

$OutboxPath = "Outbox Location"

$FolderName = "$OutboxPath\FOLDER_NAME" # Update FOLDER_NAME with end folder needed

$RawData = "$FolderName\Raw_data"

$Prefix = "name-of-prefix*"

## Create folders in Location

New-Item -Path $FolderName -ItemType Directory

New-Item -Path $RawData -ItemType Directory


## Move Files Created Today - This works

Get-ChildItem $InboxPath -Recurse -Filter "$Prefix" | Move-Item -Destination ($RawData)

## Copy file from Raw Data to one folder above

Get-ChildItem $RawData -Recurse -Filter "$Prefix" | Copy-Item -Destination ($FolderName)


## Rename Files in Data

Rename-Item "$FolderName\from-what" to-what
