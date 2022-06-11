---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Install-PSModule

## SYNOPSIS
Install modules from .json file.

## SYNTAX

### List (Default)
```
Install-PSModule [-List <String>] [-DownloadModules] [-Path <DirectoryInfo>] [-Repository <String>]
 [-Scope <String>] [<CommonParameters>]
```

### Other
```
Install-PSModule [-ModuleNamesList <String[]>] [-DownloadModules] [-Path <DirectoryInfo>]
 [-Repository <String>] [-Scope <String>] [<CommonParameters>]
```

### download
```
Install-PSModule [-DownloadModules] -Path <DirectoryInfo> [-Repository <String>] [<CommonParameters>]
```

## DESCRIPTION
Install modules from .json file.

## EXAMPLES

### EXAMPLE 1
```
Install-PSModule -BaseModules -Scope AllUsers
```

## PARAMETERS

### -List
{{ Fill List Description }}

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
{{ Fill ModuleNamesList Description }}

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

### -DownloadModules
{{ Fill DownloadModules Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
{{ Fill Path Description }}

```yaml
Type: DirectoryInfo
Parameter Sets: List, Other
Aliases:

Required: False
Position: Named
Default value: C:\Temp
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: DirectoryInfo
Parameter Sets: download
Aliases:

Required: True
Position: Named
Default value: C:\Temp
Accept pipeline input: False
Accept wildcard characters: False
```

### -Repository
{{ Fill Repository Description }}

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
Scope to install modules (CurrentUser or AllUsers).

```yaml
Type: String
Parameter Sets: List, Other
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
