---
document type: cmdlet
external help file: PSToolKit-Help.xml
HelpUri: https://smitpi.github.io/PSToolKit/Remove-FaultyProfileList
Locale: en-US
Module Name: PSToolKit
ms.date: 02/24/2026
PlatyPS schema version: 2024-05-01
title: Remove-FaultyProfileList
---

# Remove-FaultyProfileList

## SYNOPSIS

Fixes Profilelist in the registry. To fix user logon with temp profile.

## SYNTAX

### __AllParameterSets

```
Remove-FaultyProfileList [-TargetServer] <string> [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Connects to a server, Compare Profilelist in registry to what is on disk, and deletes registry if needed.
The next time a user logs on, new profile will be created, and not a temp profile.

## EXAMPLES

### EXAMPLE 1

Remove-FaultyProfileList -TargetServer AD01

## PARAMETERS

### -TargetServer

ServerName to connect to.

```yaml
Type: String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: true
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

