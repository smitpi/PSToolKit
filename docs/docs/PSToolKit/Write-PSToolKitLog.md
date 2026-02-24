---
document type: cmdlet
external help file: PSToolKit-Help.xml
HelpUri: https://smitpi.github.io/PSToolKit/Write-PSToolKitLog
Locale: en-US
Module Name: PSToolKit
ms.date: 02/24/2026
PlatyPS schema version: 2024-05-01
title: Write-PSToolKitLog
---

# Write-PSToolKitLog

## SYNOPSIS

Create a log for scripts

## SYNTAX

### log (Default)

```
Write-PSToolKitLog [-Severity <string>] [-Action <string>] [-Object <string[]>] [-Message <string>]
 [-ShowVerbose] [<CommonParameters>]
```

### Create

```
Write-PSToolKitLog [-Initialize] [-Object <string[]>] [<CommonParameters>]
```

### Export

```
Write-PSToolKitLog [-Object <string[]>] [-ExportFinal] [-Export <string>] [-LogName <string>]
 [-ReportPath <DirectoryInfo>] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Create a log for scripts

## EXAMPLES

### EXAMPLE 1

dir | Write-PSToolKitLog -Severity Error -Action Starting -Message 'file list' -ShowVerbose

## PARAMETERS

### -Action

Action for the object.

```yaml
Type: String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: log
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Export

Export the log,

```yaml
Type: String
DefaultValue: Host
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Export
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ExportFinal

Export the final log file.

```yaml
Type: SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Export
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Initialize

Create the initial array.

```yaml
Type: SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Create
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -LogName

Name for the log file.

```yaml
Type: String
DefaultValue: PSToolKitLog
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Export
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Message

Details.

```yaml
Type: String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: log
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Object

The object to be reported on.

```yaml
Type: String[]
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: log
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
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

### -ReportPath

Path where it will be saved.

```yaml
Type: DirectoryInfo
DefaultValue: C:\Temp
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Export
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Severity

Severity of the entry.

```yaml
Type: String
DefaultValue: Information
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: log
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ShowVerbose

Show every entry as it is logged.

```yaml
Type: SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: log
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

### System.String[]

{{ Fill in the Description }}

## OUTPUTS

## NOTES

## RELATED LINKS

{{ Fill in the related links here }}

