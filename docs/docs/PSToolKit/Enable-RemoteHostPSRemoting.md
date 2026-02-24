---
document type: cmdlet
external help file: PSToolKit-Help.xml
HelpUri: https://smitpi.github.io/PSToolKit/Enable-RemoteHostPSRemoting
Locale: en-US
Module Name: PSToolKit
ms.date: 02/24/2026
PlatyPS schema version: 2024-05-01
title: Enable-RemoteHostPSRemoting
---

# Enable-RemoteHostPSRemoting

## SYNOPSIS

enable ps remote remotely

## SYNTAX

### __AllParameterSets

```
Enable-RemoteHostPSRemoting [-ComputerName] <string> [-AdminCredentials <pscredential>]
 [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

enable ps remote remotely

## EXAMPLES

### EXAMPLE 1

Enable-RemoteHostPSRemoting -ComputerName $host -AdminCredentials $cred

## PARAMETERS

### -AdminCredentials

Credentials with admin access

```yaml
Type: PSCredential
DefaultValue: (Get-Credential)
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

### -ComputerName

The remote computer

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

General notes


## RELATED LINKS

{{ Fill in the related links here }}

