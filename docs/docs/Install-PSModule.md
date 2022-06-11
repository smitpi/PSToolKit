---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: https://smitpi.github.io/PSToolKit/Install-LocalPSRepository
schema: 2.0.0
---

# Install-PSModule

## SYNOPSIS
Uses a preconfigured json file or a newly created list of needed modules, and installs them.

## SYNTAX

### List (Default)
```
Install-PSModule [-List <String>] [-Repository <String>] [-Scope <String>] [<CommonParameters>]
```

### Other
```
Install-PSModule [-ModuleNamesList <String[]>] [-Repository <String>] [-Scope <String>] [<CommonParameters>]
```

## DESCRIPTION
Uses a preconfigured json file or a newly created list of needed modules, and installs them.

## EXAMPLES

### EXAMPLE 1
```
Install-PSModule -List BaseModules -Repository PSGallery -Scope AllUsers
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
From which repository it will install.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: PSGallery
Accept pipeline input: False
Accept wildcard characters: False
```

### -Scope
To which scope, allusers or currentuser.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: AllUsers
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
