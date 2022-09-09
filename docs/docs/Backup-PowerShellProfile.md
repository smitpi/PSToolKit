---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# Backup-PowerShellProfile

## SYNOPSIS

Creates a zip file from the ps profile directories

## SYNTAX

### __AllParameterSets

```
Backup-PowerShellProfile [[-ExtraDir <DirectoryInfo>]] [[-DestinationPath <DirectoryInfo>]] [<CommonParameters>]
```

## DESCRIPTION

Creates a zip file from the ps profile directories


## EXAMPLES

### Example 1: EXAMPLE 1

```
Backup-PowerShellProfile -DestinationPath c:\temp
```








## PARAMETERS

### -DestinationPath

Where the zip file will be saved.

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 1
Default value: $([Environment]::GetFolderPath('MyDocuments'))
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ExtraDir

Another Directory to add to the zip file

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 0
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## NOTES



## RELATED LINKS

Fill Related Links Here

