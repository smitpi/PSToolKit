---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# Remove-CIMUserProfile

## SYNOPSIS

Uses CimInstance to remove a user profile

## SYNTAX

### __AllParameterSets

```
Remove-CIMUserProfile [[-TargetServer <String>]] [-UserName] <String> [<CommonParameters>]
```

## DESCRIPTION

Uses CimInstance to remove a user profile


## EXAMPLES

### Example 1: EXAMPLE 1

```
Remove-CIMUserProfiles -UserName ps
```








## PARAMETERS

### -TargetServer

Affected Server

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 0
Default value: $env:COMPUTERNAME
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -UserName

Affected Username

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (All) False (None)
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

