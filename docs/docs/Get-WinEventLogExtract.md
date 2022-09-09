---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# Get-WinEventLogExtract

## SYNOPSIS

Extract Event logs of a server list, and create html / excel report

## SYNTAX

### __AllParameterSets

```
Get-WinEventLogExtract [-ComputerName] <String[]> [-Days] <Int32> [-ErrorLevel] <String> [-Export <String>] [-ReportPath <DirectoryInfo>] [<CommonParameters>]
```

## DESCRIPTION

Extract Event logs of a server list, and create html / excel report


## EXAMPLES

### Example 1: EXAMPLE 1

```
Get-WinEventLogExtract -ComputerName localhost
```








## PARAMETERS

### -ComputerName

Name of the host

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (All) False (None)
Position: 0
Default value: 
Accept pipeline input: True
Accept wildcard characters: False
DontShow: False
```

### -Days

Limit the search results

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (All) False (None)
Position: 1
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ErrorLevel

Set the default filter to this level and above.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (All) False (None)
Position: 2
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Export

Export results

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: Host
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ReportPath

Path where report will be saved

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: C:\Temp
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## OUTPUTS

### System.Object[]


## NOTES



## RELATED LINKS

Fill Related Links Here

