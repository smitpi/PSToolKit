---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# Test-PendingReboot

## SYNOPSIS

This script tests various registry values to see if the local computer is pending a reboot.

## SYNTAX

### __AllParameterSets

```
Test-PendingReboot [-ComputerName] <String[]> [[-Credential <PSCredential>]] [<CommonParameters>]
```

## DESCRIPTION

This script tests various registry values to see if the local computer is pending a reboot.


## EXAMPLES

### Example 1: EXAMPLE 1

```
Test-PendingReboot -ComputerName localhost
```








## PARAMETERS

### -ComputerName

Computer to check.

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

### -Credential

User with admin access.

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


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## NOTES

General notes


## RELATED LINKS

Fill Related Links Here

