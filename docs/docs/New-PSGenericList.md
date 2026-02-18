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

```
New-PSGenericList [[-Type] <Type>] [-Values <Object[]>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Creates a .net list object

## EXAMPLES

### EXAMPLE 1
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

Required: False
Position: 1
Default value: String
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Values
Data to add.

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Collections.Generic.List[<type>]
## NOTES

## RELATED LINKS
