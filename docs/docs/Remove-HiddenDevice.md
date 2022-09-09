---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# Remove-HiddenDevice

## SYNOPSIS

Removes ghost devices from your system

## SYNTAX

### __AllParameterSets

```
Remove-HiddenDevice [[-FilterByClass <Array>]] [[-FilterByFriendlyName <Array>]] [-listDevicesOnly] [-listGhostDevicesOnly] [<CommonParameters>]
```

## DESCRIPTION

Removes ghost devices from your system


## EXAMPLES

### Example 1: EXAMPLE 1

```
Lists all devices
```

.
Remove-HiddenDevices -listDevicesOnly





### Example 2: EXAMPLE 2

```
Save the list of devices as an object
```

$Devices = .
Remove-HiddenDevices -listDevicesOnly





### Example 3: EXAMPLE 3

```
Lists all 'ghost' devices
```

.
Remove-HiddenDevices -listGhostDevicesOnly





### Example 4: EXAMPLE 4

```
Save the list of 'ghost' devices as an object
```

$ghostDevices = .
Remove-HiddenDevices -listGhostDevicesOnly





### Example 5: EXAMPLE 5

```
Remove all ghost devices EXCEPT any devices that have "Intel" or "Citrix" in their friendly name
```

.
Remove-HiddenDevices -filterByFriendlyName @("Intel","Citrix")





### Example 6: EXAMPLE 6

```
Remove all ghost devices EXCEPT any devices that are apart of the classes "LegacyDriver" or "Processor"
```

.
Remove-HiddenDevices -filterByClass @("LegacyDriver","Processor")





### Example 7: EXAMPLE 7

```
Remove all ghost devices EXCEPT for devices with a friendly name of "Intel" or "Citrix" or with a class of "LegacyDriver" or "Processor"
```

.
Remove-HiddenDevices -filterByClass @("LegacyDriver","Processor") -filterByFriendlyName @("Intel","Citrix")






## PARAMETERS

### -FilterByClass

This parameter will exclude devices that match the class name provided.
This parameter needs to be specified in an array format for all the class names you want to be excluded from removal.
This is an exact string match so "Disk" will not match "DiskDrive".

```yaml
Type: Array
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 0
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -FilterByFriendlyName

This parameter will exclude devices that match the partial name provided.
This parameter needs to be specified in an array format for all the friendly names you want to be excluded from removal.
"Intel" will match "Intel(R) Xeon(R) CPU E5-2680 0 @ 2.70GHz".
"Loop" will match "Microsoft Loopback Adapter".

```yaml
Type: Array
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 1
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -listDevicesOnly

listDevicesOnly will output a table of all devices found in this system.

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

### -listGhostDevicesOnly

listGhostDevicesOnly will output a table of all 'ghost' devices found in this system.

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

Permission level has not been tested.
 It is assumed you will need to have sufficient rights to uninstall devices from device manager for this script to run properly.


## RELATED LINKS

Fill Related Links Here

