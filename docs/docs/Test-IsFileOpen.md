---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# Test-IsFileOpen

## SYNOPSIS

Checks if a file is open

## SYNTAX

### __AllParameterSets

```
Test-IsFileOpen [-Path] <String[]> [-FilterOpen] [<CommonParameters>]
```

## DESCRIPTION

Checks if a file is open


## EXAMPLES

### Example 1: EXAMPLE 1

```
dir | Test-IsFileOpen
```








## PARAMETERS

### -FilterOpen

Only show open files.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Path

Path to the file to check.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: FullName
Accepted values: 

Required: True (All) False (None)
Position: 0
Default value: 
Accept pipeline input: True
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

