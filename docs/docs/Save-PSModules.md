---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# Save-PSModules

## SYNOPSIS

Saves the modules to a local repo.

## SYNTAX

### List (Default)

```
Save-PSModules [-List <String>] [-Repository <String>] [<CommonParameters>]
```

### Other

```
Save-PSModules [-ModuleNamesList <String[]>] [-Repository <String>] [<CommonParameters>]
```

## DESCRIPTION

Saves the modules to a local repo.


## EXAMPLES

### Example 1: EXAMPLE 1

```
Install-PSModule -List BaseModules -Repository LocalRepo
```








## PARAMETERS

### -List

Select the base or extended, to select one of the json config files.

```yaml
Type: String
Parameter Sets: List
Aliases: 
Accepted values: 

Required: True (None) False (List)
Position: Named
Default value: ExtendedModules
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ModuleNamesList

Or specify a string list with module names.

```yaml
Type: String[]
Parameter Sets: Other
Aliases: 
Accepted values: 

Required: True (None) False (Other)
Position: Named
Default value: 
Accept pipeline input: True
Accept wildcard characters: False
DontShow: False
```

### -Repository

To which repository it will download.

```yaml
Type: String
Parameter Sets: Other, List
Aliases: 
Accepted values: 

Required: True (None) False (Other, List)
Position: Named
Default value: 
Accept pipeline input: False
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

