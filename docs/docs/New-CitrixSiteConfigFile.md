---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# New-CitrixSiteConfigFile

## SYNOPSIS
A config file with Citrix server details and URLs.
To be used in scripts.

## SYNTAX

```
New-CitrixSiteConfigFile [-ConfigName] <String> [[-Path] <DirectoryInfo>] [<CommonParameters>]
```

## DESCRIPTION
A config file with Citrix server details and URLs.
To be used in scripts.
Use the function Import-CitrixSiteConfigFile to create variables from the config.

## EXAMPLES

### EXAMPLE 1
```
New-CitrixSiteConfigFile -ConfigName TestFarm -Path C:\Tiles
```

## PARAMETERS

### -ConfigName
A Unique name for the site / farm.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Where the config file will be saved.

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: C:\Temp
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
