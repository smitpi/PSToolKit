---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Start-PSToolkitSystemInitialize

## SYNOPSIS
Initialize a blank machine.

## SYNTAX

```
Start-PSToolkitSystemInitialize [-GitHubUserID] <String> [-GitHubToken] <String> [-LabSetup]
 [-InstallMyModules] [-PendingReboot] [<CommonParameters>]
```

## DESCRIPTION
Initialize a blank machine with PSToolKit tools and dependencies.

## EXAMPLES

### EXAMPLE 1
```
Start-PSToolkitSystemInitialize -InstallMyModules
```

## PARAMETERS

### -GitHubUserID
{{ Fill GitHubUserID Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GitHubToken
Token used to install modules and apps.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LabSetup
Commands only for my HomeLab

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

### -InstallMyModules
Install my other published modules.

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

### -PendingReboot
Will reboot the device if it is needed.

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
