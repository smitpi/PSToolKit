---
document type: cmdlet
external help file: PSToolKit-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSToolKit
ms.date: 02/24/2026
PlatyPS schema version: 2024-05-01
title: Resolve-SID
---

# Resolve-SID

## SYNOPSIS

Resolves the Sid

## SYNTAX

### __AllParameterSets

```
Resolve-SID [-SID] <string> [-ToString] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Resolves the Sid

## EXAMPLES

### EXAMPLE 1

Resolve-SID -Export HTML -ReportPath C:\temp

## PARAMETERS

### -SID

Enter a SID string.

```yaml
Type: String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: true
  ValueFromPipeline: true
  ValueFromPipelineByPropertyName: true
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ToString

Display the resolved account name as a string.

```yaml
Type: SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
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

### System.String

{{ Fill in the Description }}

## OUTPUTS

### ResolvedSID

{{ Fill in the Description }}

### String

{{ Fill in the Description }}

## NOTES

## RELATED LINKS

{{ Fill in the related links here }}

