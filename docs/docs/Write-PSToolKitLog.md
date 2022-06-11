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

### log (Default)
```
Write-PSToolKitLog [-Severity <String>] [-Action <String>] [-Object <String[]>] [-Message <String>]
 [-ShowVerbose] [<CommonParameters>]
```

### Create
```
Write-PSToolKitLog [-Initialize] [-Object <String[]>] [<CommonParameters>]
```

### Export
```
Write-PSToolKitLog [-Object <String[]>] [-ExportFinal] [-Export <String>] [-LogName <String>]
 [-ReportPath <DirectoryInfo>] [<CommonParameters>]
```

## DESCRIPTION
Create a log for scripts

## EXAMPLES

### EXAMPLE 1
```
dir | Write-PSToolKitLog -Severity Error -Action Starting -Message 'file list' -ShowVerbose
```

## PARAMETERS

### -Initialize
Create the initial array.

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
Severity of the entry.

```yaml
Type: String
Parameter Sets: log
Aliases:

Required: False
Position: Named
Default value: Information
Accept pipeline input: False
Accept wildcard characters: False
```

### -Action
Action for the object.

```yaml
Type: String
Parameter Sets: log
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Object
The object to be reported on.

```yaml
Type: String[]
Parameter Sets: log
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String[]
Parameter Sets: Create, Export
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Message
Details.

```yaml
Type: String
Parameter Sets: log
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowVerbose
Show every entry as it is logged.

```yaml
Type: SwitchParameter
Parameter Sets: log
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExportFinal
Export the final log file.

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
Export the log,

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

### -LogName
Name for the log file.

```yaml
Type: String
Parameter Sets: Export
Aliases:

Required: False
Position: Named
Default value: PSToolKitLog
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReportPath
Path where it will be saved.

```yaml
Type: DirectoryInfo
Parameter Sets: Export
Aliases:

Required: False
Position: Named
Default value: C:\Temp
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
