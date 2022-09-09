---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# Get-ProcessPerformance

## SYNOPSIS

Gets the top 10 processes by CPU %

## SYNTAX

### __AllParameterSets

```
Get-ProcessPerformance [[-ComputerName <String[]>]] [[-LimitProcCount <Int32>]] [[-Sortby <String>]] [<CommonParameters>]
```

## DESCRIPTION

Gets the top 10 processes by CPU %


## EXAMPLES

### Example 1: EXAMPLE 1

```
Get-ProcessPerformance -ComputerName Apollo -LimitProcCount 10 -Sortby '% CPU'
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

### -LimitProcCount

List the top x of processes.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 1
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Sortby

Sort by CPU or Memory descending.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 2
Default value: % CPU
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## NOTES



## RELATED LINKS

Fill Related Links Here

