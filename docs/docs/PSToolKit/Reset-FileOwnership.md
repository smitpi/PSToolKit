---
document type: cmdlet
external help file: PSToolKit-Help.xml
HelpUri: https://smitpi.github.io/PSToolKit/Reset-FileOwnership
Locale: en-US
Module Name: PSToolKit
ms.date: 02/24/2026
PlatyPS schema version: 2024-05-01
title: Reset-FileOwnership
---

# Reset-FileOwnership

## SYNOPSIS

Reset the ownership of a directory and add full control to the folder.

## SYNTAX

### __AllParameterSets

```
Reset-FileOwnership [-Path] <DirectoryInfo[]> [[-Credentials] <pscredential>] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Reset the ownership of a directory and add full control to the folder.

## EXAMPLES

### EXAMPLE 1

Reset-FileOwnership -Path C:\temp -Credentials $Admin

## PARAMETERS

### -Credentials

The account to grant full control.

```yaml
Type: PSCredential
DefaultValue: (Get-Credential -Message 'User to be given access')
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

### -Path

Path to the folder to reset ownership.

```yaml
Type: DirectoryInfo[]
DefaultValue: ''
SupportsWildcards: false
Aliases:
- Directory
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: true
  ValueFromPipeline: true
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

### System.IO.DirectoryInfo[]

{{ Fill in the Description }}

## OUTPUTS

### System.Object

{{ Fill in the Description }}

## NOTES

## RELATED LINKS

{{ Fill in the related links here }}

