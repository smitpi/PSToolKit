---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: https://smitpi.github.io/PSToolKit/Install-LocalPSRepository
schema: 2.0.0
---

# Start-PSModuleMaintenance

## SYNOPSIS
Goes through all the installed modules, and allow you to upgrade(If available), or remove old and duplicate versions.

## SYNTAX

### Update (Default)
```
Start-PSModuleMaintenance [-ListUpdateAvailable] [-PerformUpdate] [<CommonParameters>]
```

### Duplicate
```
Start-PSModuleMaintenance [-RemoveDuplicates] [<CommonParameters>]
```

### Remove
```
Start-PSModuleMaintenance [-RemoveOldVersions] [-ForceRemove] [<CommonParameters>]
```

## DESCRIPTION
Goes through all the installed modules, and allow you to upgrade(If available), or remove old and duplicate versions.

## EXAMPLES

### EXAMPLE 1
```
Start-PSModuleMaintenance -ListUpdateAvailable -PerformUpdate
```

## PARAMETERS

### -ListUpdateAvailable
Filter to show only the modules with update available.

```yaml
Type: SwitchParameter
Parameter Sets: Update
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PerformUpdate
Performs the update-module function on modules with updates available.

```yaml
Type: SwitchParameter
Parameter Sets: Update
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoveDuplicates
Checks if a module is installed in more than one location, and reinstall it the all users profile.

```yaml
Type: SwitchParameter
Parameter Sets: Duplicate
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoveOldVersions
Delete the old versions of existing modules.

```yaml
Type: SwitchParameter
Parameter Sets: Remove
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ForceRemove
If unable to remove, then the directory will be deleted.

```yaml
Type: SwitchParameter
Parameter Sets: Remove
Aliases:

Required: False
Position: Named
Default value: False
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
