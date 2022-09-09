---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# Connect-VMWareCluster

## SYNOPSIS

Connect to a vSphere cluster to perform other commands or scripts

## SYNTAX

### __AllParameterSets

```
Connect-VMWareCluster [[-vCenterIp <String>]] [[-vCenterCredencial <PSCredential>]] [<CommonParameters>]
```

## DESCRIPTION

Connect to a vSphere cluster to perform other commands or scripts


## EXAMPLES

### Example 1: EXAMPLE 1

```
Connect-VMWareCluster -vCenterIp 192.168.x.x -vCenterCredencial $cred
```








## PARAMETERS

### -vCenterCredencial

Credential to connect with.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 1
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -vCenterIp

vCenter IP or name

```yaml
Type: String
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


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## NOTES



## RELATED LINKS

Fill Related Links Here

