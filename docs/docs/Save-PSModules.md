---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: https://smitpi.github.io/PSToolKit/Edit-HostsFile
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

### EXAMPLE 1
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

Required: False
Position: Named
Default value: ExtendedModules
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModuleNamesList
Or specify a string list with module names.

```yaml
Type: String[]
Parameter Sets: Other
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Repository
To which repository it will download.

```yaml
Type: String
Parameter Sets: (All)
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

### System.Object[]
## NOTES

## RELATED LINKS
