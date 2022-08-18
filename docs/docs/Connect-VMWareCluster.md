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

```
Connect-VMWareCluster [[-vCenterIp] <String>] [[-vCenterCredencial] <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION
Connect to a vSphere cluster to perform other commands or scripts

## EXAMPLES

### EXAMPLE 1
```
Connect-VMWareCluster -vCenterIp 192.168.x.x -vCenterCredencial $cred
```

## PARAMETERS

### -vCenterIp
vCenter IP or name

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -vCenterCredencial
{{ Fill vCenterCredencial Description }}

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
