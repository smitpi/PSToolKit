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

### Set1 (Default)

```
Start-PSToolkitSystemInitialize [-InstallMyModules] [-LabSetup] [-PendingReboot] [<CommonParameters>]
```

## DESCRIPTION

Initialize a blank machine with PSToolKit tools and dependencies.


## EXAMPLES

### Example 1: EXAMPLE 1

```
Start-PSToolkitSystemInitialize -InstallMyModules
```








## PARAMETERS

### -InstallMyModules

Install my other published modules.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -LabSetup

Commands only for my HomeLab

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -PendingReboot

Will reboot the device if it is needed.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## NOTES



## RELATED LINKS

Fill Related Links Here

