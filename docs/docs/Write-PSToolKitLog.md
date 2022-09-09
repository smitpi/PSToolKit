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
Write-PSToolKitLog [-Action <String>] [-Message <String>] [-Object <String[]>] [-Severity <String>] [-ShowVerbose] [<CommonParameters>]
```

### Create

```
Write-PSToolKitLog [-Initialize] [-Object <String[]>] [<CommonParameters>]
```

### Export

```
Write-PSToolKitLog [-Export <String>] [-ExportFinal] [-LogName <String>] [-Object <String[]>] [-ReportPath <DirectoryInfo>] [<CommonParameters>]
```

## DESCRIPTION

Create a log for scripts


## EXAMPLES

### Example 1: EXAMPLE 1

```
dir | Write-PSToolKitLog -Severity Error -Action Starting -Message 'file list' -ShowVerbose
```








## PARAMETERS

### -Action

Action for the object.

```yaml
Type: String
Parameter Sets: log
Aliases: 
Accepted values: 

Required: True (None) False (log)
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Export

Export the log,

```yaml
Type: String
Parameter Sets: Export
Aliases: 
Accepted values: 

Required: True (None) False (Export)
Position: Named
Default value: Host
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ExportFinal

Export the final log file.

```yaml
Type: SwitchParameter
Parameter Sets: Export
Aliases: 
Accepted values: 

Required: True (None) False (Export)
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Initialize

Create the initial array.

```yaml
Type: SwitchParameter
Parameter Sets: Create
Aliases: 
Accepted values: 

Required: True (None) False (Create)
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -LogName

Name for the log file.

```yaml
Type: String
Parameter Sets: Export
Aliases: 
Accepted values: 

Required: True (None) False (Export)
Position: Named
Default value: PSToolKitLog
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Message

Details.

```yaml
Type: String
Parameter Sets: log
Aliases: 
Accepted values: 

Required: True (None) False (log)
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Object

The object to be reported on.

```yaml
Type: String[]
Parameter Sets: log, (All)
Aliases: 
Accepted values: 

Required: True (None) False (log, All)
Position: Named
Default value: 
Accept pipeline input: True
Accept wildcard characters: False
DontShow: False
```

### -ReportPath

Path where it will be saved.

```yaml
Type: DirectoryInfo
Parameter Sets: Export
Aliases: 
Accepted values: 

Required: True (None) False (Export)
Position: Named
Default value: C:\Temp
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Severity

Severity of the entry.

```yaml
Type: String
Parameter Sets: log
Aliases: 
Accepted values: 

Required: True (None) False (log)
Position: Named
Default value: Information
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ShowVerbose

Show every entry as it is logged.

```yaml
Type: SwitchParameter
Parameter Sets: log
Aliases: 
Accepted values: 

Required: True (None) False (log)
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## NOTES



## RELATED LINKS

Fill Related Links Here

