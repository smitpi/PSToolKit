---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# Get-SystemInfo

## SYNOPSIS

Get system details of a remote device

## SYNTAX

### __AllParameterSets

```
Get-SystemInfo [[-ComputerName <String[]>]] [[-Export <String>]] [[-ReportPath <DirectoryInfo>]] [<CommonParameters>]
```

## DESCRIPTION

Get system details of a remote device


## EXAMPLES

### Example 1: EXAMPLE 1

```
Get-SystemInfo -ComputerName Apollo
```








## PARAMETERS

### -ComputerName

Device to be queried.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 0
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Export

Export to excel or html

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 1
Default value: Host
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ReportPath

Where to save report.

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 2
Default value: "$env:TEMP"
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

