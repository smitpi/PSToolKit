---
document type: cmdlet
external help file: PSToolKit-Help.xml
HelpUri: https://smitpi.github.io/PSToolKit/Backup-ElevatedShortcut
Locale: en-US
Module Name: PSToolKit
ms.date: 02/24/2026
PlatyPS schema version: 2024-05-01
title: Backup-ElevatedShortcut
---

# Backup-ElevatedShortcut

## SYNOPSIS

Exports the RunAss shortcuts, to a zip file

## SYNTAX

### __AllParameterSets

```
Backup-ElevatedShortcut [[-ExportPath] <DirectoryInfo>] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Exports the RunAss shortcuts, to a zip file

## EXAMPLES

### EXAMPLE 1

Backup-ElevatedShortcut -ExportPath c:\temp

## PARAMETERS

### -ExportPath

Path for the zip file

```yaml
Type: DirectoryInfo
DefaultValue: '"$env:TEMP"'
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

