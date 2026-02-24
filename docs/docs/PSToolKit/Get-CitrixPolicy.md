---
document type: cmdlet
external help file: PSToolKit-Help.xml
HelpUri: https://smitpi.github.io/PSToolKit/Get-CitrixPolicy
Locale: en-US
Module Name: PSToolKit
ms.date: 02/24/2026
PlatyPS schema version: 2024-05-01
title: Get-CitrixPolicy
---

# Get-CitrixPolicy

## SYNOPSIS

Export Citrix Policies

## SYNTAX

### __AllParameterSets

```
Get-CitrixPolicy [-Controller] <string> [[-Export] <string>] [[-ReportPath] <DirectoryInfo>]
 [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Export Citrix Policies

## EXAMPLES

### EXAMPLE 1

Get-CitrixPolicy -Controller $ctxddc

## PARAMETERS

### -Controller

Name of the DDC

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

### -Export

Export result to excel, html

```yaml
Type: String
DefaultValue: Host
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

### -ReportPath

Where to save the report.

```yaml
Type: DirectoryInfo
DefaultValue: C:\Temp
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 2
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

### System.Object

{{ Fill in the Description }}

## NOTES

## RELATED LINKS

{{ Fill in the related links here }}

