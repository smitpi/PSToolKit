---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# Set-StaticIP

## SYNOPSIS

Set static IP on device

## SYNTAX

### __AllParameterSets

```
Set-StaticIP [-IP] <String> [-DNS <String>] [-GateWay <String>] [<CommonParameters>]
```

## DESCRIPTION

Set static IP on device


## EXAMPLES

### Example 1: EXAMPLE 1

```
Set-StaticIP -IP 192.168.10.10 -GateWay 192.168.10.1 -DNS 192.168.10.60
```








## PARAMETERS

### -DNS

new DNS

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -GateWay

new gateway

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -IP

New IP

```yaml
Type: String
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

## NOTES



## RELATED LINKS

Fill Related Links Here

