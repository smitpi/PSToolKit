---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Write-PSToolKitLog

## SYNOPSIS
Create a log for scripts

## SYNTAX

### Set (Default)
```
Write-PSToolKitLog [-Severity <String>] [-Message <String>] [-ShowVerbose] [<CommonParameters>]
```

### Create
```
Write-PSToolKitLog [-CreateArray] [<CommonParameters>]
```

### Export
```
Write-PSToolKitLog [-ExportFinal] [-Export <String>] [-ReportPath <DirectoryInfo>] [<CommonParameters>]
```

## DESCRIPTION
Create a log for scripts

## EXAMPLES

### EXAMPLE 1
```
Write-PSToolKitLog -Severity Information -Message 'Where details are?'
```

## PARAMETERS

### -CreateArray
Run at the begining to create the initial arrray.

```yaml
Type: SwitchParameter
Parameter Sets: Create
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Severity
Level of the message to be logged.

```yaml
Type: String
Parameter Sets: Set
Aliases:

Required: False
Position: Named
Default value: Information
Accept pipeline input: False
Accept wildcard characters: False
```

### -Message
Details to be logged.

```yaml
Type: String
Parameter Sets: Set
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowVerbose
Also show output to screen.

```yaml
Type: SwitchParameter
Parameter Sets: Set
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExportFinal
Run at the end to finalize the report.

```yaml
Type: SwitchParameter
Parameter Sets: Export
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Export
Export the log to excel of html.

```yaml
Type: String
Parameter Sets: Export
Aliases:

Required: False
Position: Named
Default value: Host
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReportPath
Where to save the log.

```yaml
Type: DirectoryInfo
Parameter Sets: Export
Aliases:

Required: False
Position: Named
Default value: "$env:TEMP"
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
General notes

## RELATED LINKS
