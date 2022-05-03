---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Install-ChocolateyApp

## SYNOPSIS
Install chocolatey apps from a json list.

## SYNTAX

### Set1 (Default)
```
Install-ChocolateyApp [-BaseApps] [-ExtendedApps] [<CommonParameters>]
```

### Set2
```
Install-ChocolateyApp [-OtherApps] [-JsonPath <FileInfo>] [<CommonParameters>]
```

## DESCRIPTION
Install chocolatey apps from a json list.

## EXAMPLES

### EXAMPLE 1
```
Install-ChocolateyApps -BaseApps
```

## PARAMETERS

### -BaseApps
Use build in base app list

```yaml
Type: SwitchParameter
Parameter Sets: Set1
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExtendedApps
Use build in extended app list

```yaml
Type: SwitchParameter
Parameter Sets: Set1
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -OtherApps
Specify your own json list file

```yaml
Type: SwitchParameter
Parameter Sets: Set2
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -JsonPath
Path to the json file

```yaml
Type: FileInfo
Parameter Sets: Set2
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
