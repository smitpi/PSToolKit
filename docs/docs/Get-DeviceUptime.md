---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# Get-DeviceUptime

## SYNOPSIS

Calculates the uptime of a system

## SYNTAX

### Set1 (Default)

```
Get-DeviceUptime [-ComputerName <String[]>] [<CommonParameters>]
```

## DESCRIPTION

Calculates the uptime of a system


## EXAMPLES

### Example 1: EXAMPLE 1

```
Get-DeviceUptime -ComputerName Neptune
```








## PARAMETERS

### -ComputerName

Computer to query.

```yaml
Type: String[]
Parameter Sets: Set1, (All)
Aliases: 
Accepted values: 

Required: True (None) False (Set1, All)
Position: Named
Default value: $env:computername
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

