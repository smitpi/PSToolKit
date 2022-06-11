---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Update-PSToolKitConfigFile

## SYNOPSIS
Manages the config files for the PSToolKit Module.

## SYNTAX

### local (Default)
```
Update-PSToolKitConfigFile [-UpdateLocal] [-UpdateLocalFromModule] [<CommonParameters>]
```

### Localgist
```
Update-PSToolKitConfigFile [-UpdateLocal] [-UpdateLocalFromGist] [-GitHubUserID <String>]
 [-GitHubToken <String>] [<CommonParameters>]
```

### gistupdate
```
Update-PSToolKitConfigFile [-UpdateGist] [-GitHubUserID <String>] [-GitHubToken <String>] [<CommonParameters>]
```

## DESCRIPTION
Manages the config files for the PSToolKit Module, By updating either the locally installed files, or the ones hosted on GitHub Gist.

## EXAMPLES

### EXAMPLE 1
```
Update-PSToolKitConfigFiles -UpdateLocal -UpdateLocalFromModule
```

## PARAMETERS

### -UpdateLocal
Overwrites the local files in C:\Program Files\PSToolKit\Config\

```yaml
Type: SwitchParameter
Parameter Sets: local, Localgist
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -UpdateGist
Update the Gist from the local files.

```yaml
Type: SwitchParameter
Parameter Sets: gistupdate
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -UpdateLocalFromModule
Will be updated from the PSToolKit Modules files.

```yaml
Type: SwitchParameter
Parameter Sets: local
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -UpdateLocalFromGist
Will be updated from the hosted gist files..

```yaml
Type: SwitchParameter
Parameter Sets: Localgist
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -GitHubUserID
GitHub User with access to the gist.

```yaml
Type: String
Parameter Sets: Localgist, gistupdate
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GitHubToken
GitHub User's Token.

```yaml
Type: String
Parameter Sets: Localgist, gistupdate
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
