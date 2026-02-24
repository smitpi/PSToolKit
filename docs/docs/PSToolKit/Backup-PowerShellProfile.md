---
document type: cmdlet
external help file: PSToolKit-Help.xml
HelpUri: https://smitpi.github.io/PSToolKit/Backup-PowerShellProfile
Locale: en-US
Module Name: PSToolKit
ms.date: 02/24/2026
PlatyPS schema version: 2024-05-01
title: Backup-PowerShellProfile
---

# Backup-PowerShellProfile

## SYNOPSIS

Creates a zip file from the ps profile directories

## SYNTAX

### __AllParameterSets

```
Backup-PowerShellProfile [[-ExtraDir] <DirectoryInfo>] [[-DestinationPath] <DirectoryInfo>]
 [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Creates a zip file from the ps profile directories

## EXAMPLES

### EXAMPLE 1

Backup-PowerShellProfile -DestinationPath c:\temp

## PARAMETERS

### -DestinationPath

Where the zip file will be saved.

```yaml
Type: DirectoryInfo
DefaultValue: $([Environment]::GetFolderPath('MyDocuments'))
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 1
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ExtraDir

Another Directory to add to the zip file

```yaml
Type: DirectoryInfo
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

{{ Fill in the related links here }}

