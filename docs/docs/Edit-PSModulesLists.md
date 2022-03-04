---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Edit-PSModulesLists

## SYNOPSIS
Edit the Modules json files.

## SYNTAX

### List (Default)
```
Edit-PSModulesLists -List <String> [-ShowCurrent] [<CommonParameters>]
```

### Remove
```
Edit-PSModulesLists -List <String> [-RemoveModule] [<CommonParameters>]
```

### Add
```
Edit-PSModulesLists -List <String> [-AddModule] [-ModuleName <String>] [<CommonParameters>]
```

## DESCRIPTION
Edit the Modules json files.

## EXAMPLES

### EXAMPLE 1
```
Edit-PSModulesLists -ShowCurrent
```

## PARAMETERS

### -List
Which list to edit.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowCurrent
Currently in the list

```yaml
Type: SwitchParameter
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoveModule
Remove form the list

```yaml
Type: SwitchParameter
Parameter Sets: Remove
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -AddModule
Add to the list

```yaml
Type: SwitchParameter
Parameter Sets: Add
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModuleName
What module to add.

```yaml
Type: String
Parameter Sets: Add
Aliases:

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

## NOTES

## RELATED LINKS