---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# Test-PSRemote

## SYNOPSIS

Test PSb Remote to a device.

## SYNTAX

### __AllParameterSets

```
Test-PSRemote [-ComputerName] <String[]> [[-Credential <PSCredential>]] [<CommonParameters>]
```

## DESCRIPTION

Test PSb Remote to a device.


## EXAMPLES

### Example 1: EXAMPLE 1

```
Test-PSRemote -ComputerName Apollo
```








## PARAMETERS

### -ComputerName

Device to test.

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

Username to use.

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



## RELATED LINKS

Fill Related Links Here

