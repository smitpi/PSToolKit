---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Set-PSToolKitConfigFiles

## SYNOPSIS
Creates the config files for the modules and chocolatey scripts.

## SYNTAX

```
Set-PSToolKitConfigFiles [-Source <String>] [-UserID <String>] [-GitHubToken <String>] [<CommonParameters>]
```

## DESCRIPTION
Creates the config files for the modules and chocolatey scripts.

## EXAMPLES

### EXAMPLE 1
```
Set-PSToolKitConfigFiles -Source Module
```

## PARAMETERS

### -Source
Where to copy the config from.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Module
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserID
GitHub userid hosting the gist.

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

### -GitHubToken
GitHub Token

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

## NOTES

## RELATED LINKS
