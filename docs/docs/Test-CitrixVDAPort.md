---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# Test-CitrixVDAPort

## SYNOPSIS

Test connection between DDC and VDI

## SYNTAX

### __AllParameterSets

```
Test-CitrixVDAPort [-ServerList] <ArrayList> [[-PortsList <ArrayList>]] [[-Export <String>]] [[-ReportPath <String>]] [<CommonParameters>]
```

## DESCRIPTION

Test connection between DDC and VDI, you can also specify other ports.


## EXAMPLES

### Example 1: EXAMPLE 1

```
Test-CitrixVDAPorts -ServerList $list
```








## PARAMETERS

### -Export

Export the results.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 3
Default value: Host
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -PortsList

List of ports to test, by default the citrix ports are selected.

```yaml
Type: ArrayList
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 1
Default value: @('80', '443', '1494', '2598')
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ReportPath

Where report will be saves.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 4
Default value: $env:temp
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ServerList

List servers to test

```yaml
Type: ArrayList
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


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## OUTPUTS

### System.Object[]


## NOTES



## RELATED LINKS

Fill Related Links Here

