---
document type: cmdlet
external help file: PSToolKit-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSToolKit
ms.date: 02/24/2026
PlatyPS schema version: 2024-05-01
title: New-PSGenericList
---

# New-PSGenericList

## SYNOPSIS

Creates a .net list object

## SYNTAX

### __AllParameterSets

```
New-PSGenericList [[-Type] <type>] [-Values <Object[]>] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Creates a .net list object

## EXAMPLES

### EXAMPLE 1

$list = New-GenericList -Type string -Values 'blah','two','one'

## PARAMETERS

### -Type

The type of objects in the list

```yaml
Type: Type
DefaultValue: String
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: true
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Values

Data to add.

```yaml
Type: Object[]
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
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

### System.Type

{{ Fill in the Description }}

### System.Object[]

{{ Fill in the Description }}

## OUTPUTS

### System.Collections.Generic.List[<type>]

{{ Fill in the Description }}

## NOTES

## RELATED LINKS

{{ Fill in the related links here }}

