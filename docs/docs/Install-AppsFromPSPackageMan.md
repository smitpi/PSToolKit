---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Install-AppsFromPSPackageMan

## SYNOPSIS
Uses the module PSPackageMan to install apps from a GitHub Gist File.

## SYNTAX

### Public (Default)
```
Install-AppsFromPSPackageMan [-GitHubUserID <String>] [-PublicGist] [<CommonParameters>]
```

### Private
```
Install-AppsFromPSPackageMan [-GitHubUserID <String>] [-GitHubToken <String>] [<CommonParameters>]
```

## DESCRIPTION
Uses the module PSPackageMan to install apps from a GitHub Gist File.

## EXAMPLES

### EXAMPLE 1
```
Install-AppsFromPSPackageMan  -GitHubUserID $user -PublicGist
```

## PARAMETERS

### -GitHubUserID
User with access to the gist.

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

### -PublicGist
Select if the list is hosted publicly.

```yaml
Type: SwitchParameter
Parameter Sets: Public
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -GitHubToken
The token for that gist.

```yaml
Type: String
Parameter Sets: Private
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
