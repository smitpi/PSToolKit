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

### import

```
Install-LocalPSRepository -RepoName <String> -RepoPath <DirectoryInfo> [-ImportPowerShellGet] [<CommonParameters>]
```

## DESCRIPTION

Short desCreates a repository for offline installations.


## EXAMPLES

### Example 1: EXAMPLE 1

```
Install-LocalPSRepository -RepoName repo -RepoPath c:\utils\repo
```








## PARAMETERS

### -ImportPowerShellGet

Downloads an offline copy of PowerShellGet

```yaml
Type: SwitchParameter
Parameter Sets: import
Aliases: 
Accepted values: 

Required: True (None) False (import)
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -RepoName

Name of the local repository

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (All) False (None)
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -RepoPath

Path to the folder for the repository.

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (All) False (None)
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

