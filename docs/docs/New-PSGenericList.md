---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# New-PSGenericList

## SYNOPSIS

Creates a .net list object

## SYNTAX

### __AllParameterSets

```
New-PSGenericList [[-Type <Type>]] [-Values <Object[]>] [<CommonParameters>]
```

## DESCRIPTION

Creates a .net list object


## EXAMPLES

### Example 1: EXAMPLE 1

```
$list = New-GenericList -Type string -Values 'blah','two','one'
```








## PARAMETERS

### -Type

The type of objects in the list

```yaml
Type: Type
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 0
Default value: String
Accept pipeline input: True
Accept wildcard characters: False
DontShow: False
```

### -Values

Data to add.

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: 
Accept pipeline input: True
Accept wildcard characters: False
DontShow: False
```


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## OUTPUTS

### System.Collections.Generic.List[<type>]


## NOTES



## RELATED LINKS

Fill Related Links Here

