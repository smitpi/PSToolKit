---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Install-LocalPSRepository

## SYNOPSIS
Short desCreates a repository for offline installations.

## SYNTAX

```
Install-LocalPSRepository -RepoName <String> -RepoPath <DirectoryInfo> [-ImportPowerShellGet]
 [-DownloadModules] [-List <String>] [-ModuleNamesList <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Short desCreates a repository for offline installations.

## EXAMPLES

### EXAMPLE 1
```
Install-LocalPSRepository -RepoName repo -RepoPath c:\utils\repo -DownloadModules -List BaseModules
```

## PARAMETERS

### -RepoName
Name of the local repository

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

### -RepoPath
Path to the folder for the repository.

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ImportPowerShellGet
Downloads an offline copy of PowerShellGet

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

### -DownloadModules
Downloads an existing json list of modules to the new repository.

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

### -List
The base or extended json module list.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: ExtendedModules
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModuleNamesList
A string list of module names to download.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object[]
## NOTES

## RELATED LINKS
