---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Install-PSModules

## SYNOPSIS
Install modules from .json file.

## SYNTAX

### base (Default)
```
Install-PSModules [-BaseModules] [-Scope <String>] [-ForceInstall] [-UpdateModules] [-RemoveAll]
 [<CommonParameters>]
```

### ext
```
Install-PSModules [-ExtendedModules] [-Scope <String>] [-ForceInstall] [-UpdateModules] [-RemoveAll]
 [<CommonParameters>]
```

### other
```
Install-PSModules [-Scope <String>] [-OtherModules] [-JsonPath <String>] [-ForceInstall] [-UpdateModules]
 [-RemoveAll] [<CommonParameters>]
```

## DESCRIPTION
Install modules from .json file.

## EXAMPLES

### EXAMPLE 1
```
Install-PSModules -BaseModules -Scope AllUsers
```

## PARAMETERS

### -BaseModules
Only base list.

```yaml
Type: SwitchParameter
Parameter Sets: base
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExtendedModules
Use longer list.

```yaml
Type: SwitchParameter
Parameter Sets: ext
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Scope
Scope to install modules (CurrentUser or AllUsers).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: CurrentUser
Accept pipeline input: False
Accept wildcard characters: False
```

### -OtherModules
Use Manual list.

```yaml
Type: SwitchParameter
Parameter Sets: other
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -JsonPath
Path to manual list.

```yaml
Type: String
Parameter Sets: other
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ForceInstall
Force reinstall.

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

### -UpdateModules
Update the modules.

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

### -RemoveAll
Remove the modules.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
