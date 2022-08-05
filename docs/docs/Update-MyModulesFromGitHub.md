---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Update-MyModulesFromGitHub

## SYNOPSIS
Updates my modules

## SYNTAX

```
Update-MyModulesFromGitHub [[-Modules] <String[]>] [-AllUsers] [-ForceUpdate] [<CommonParameters>]
```

## DESCRIPTION
Updates my modules

## EXAMPLES

### EXAMPLE 1
```
Update-MyModulesFromGitHub -AllUsers
```

## PARAMETERS

### -Modules
Which modules to update.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: @('CTXCloudApi', 'PSConfigFile', 'PSLauncher', 'XDHealthCheck', 'PSSysTray', 'PWSHModule', 'PSToolkit')
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllUsers
Will update to the AllUsers Scope.

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

### -ForceUpdate
ForceUpdate the download and install.

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

### System.Object[]
## NOTES

## RELATED LINKS
