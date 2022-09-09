---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# Get-SoftwareAudit

## SYNOPSIS

Connects to a remote hosts and collect installed software details

## SYNTAX

### __AllParameterSets

```
Get-SoftwareAudit [-ComputerName] <String[]> [[-Export <String>]] [[-ReportPath <String>]] [<CommonParameters>]
```

## DESCRIPTION

Connects to a remote hosts and collect installed software details


## EXAMPLES

### Example 1: EXAMPLE 1

```
Get-SoftwareAudit -ComputerName Neptune -Export Excel
```








## PARAMETERS

### -ComputerName

Name of the computers that will be audited

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (All) False (None)
Position: 0
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Export

Export the results to excel or html

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

Path to save the report.

```yaml
Type: String
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

## NOTES



## RELATED LINKS

Fill Related Links Here

