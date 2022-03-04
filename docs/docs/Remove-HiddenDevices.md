---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Remove-HiddenDevices

## SYNOPSIS
Removes ghost devices from your system

## SYNTAX

```
Remove-HiddenDevices [[-FilterByClass] <Array>] [[-FilterByFriendlyName] <Array>] [-listDevicesOnly]
 [-listGhostDevicesOnly] [<CommonParameters>]
```

## DESCRIPTION
Removes ghost devices from your system

## EXAMPLES

### EXAMPLE 1
```
Lists all devices
. Remove-HiddenDevices -listDevicesOnly
```

### EXAMPLE 2
```
Save the list of devices as an object
$Devices = . Remove-HiddenDevices -listDevicesOnly
```

### EXAMPLE 3
```
Lists all 'ghost' devices
. Remove-HiddenDevices -listGhostDevicesOnly
```

### EXAMPLE 4
```
Save the list of 'ghost' devices as an object
$ghostDevices = . Remove-HiddenDevices -listGhostDevicesOnly
```

### EXAMPLE 5
```
Remove all ghost devices EXCEPT any devices that have "Intel" or "Citrix" in their friendly name
. Remove-HiddenDevices -filterByFriendlyName @("Intel","Citrix")
```

### EXAMPLE 6
```
Remove all ghost devices EXCEPT any devices that are apart of the classes "LegacyDriver" or "Processor"
. Remove-HiddenDevices -filterByClass @("LegacyDriver","Processor")
```

### EXAMPLE 7
```
Remove all ghost devices EXCEPT for devices with a friendly name of "Intel" or "Citrix" or with a class of "LegacyDriver" or "Processor"
. Remove-HiddenDevices -filterByClass @("LegacyDriver","Processor") -filterByFriendlyName @("Intel","Citrix")
```

## PARAMETERS

### -FilterByClass
This parameter will exclude devices that match the class name provided.
This parameter needs to be specified in an array format for all the class names you want to be excluded from removal.
This is an exact string match so "Disk" will not match "DiskDrive".

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
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

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -listDevicesOnly
listDevicesOnly will output a table of all devices found in this system.

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

### -listGhostDevicesOnly
listGhostDevicesOnly will output a table of all 'ghost' devices found in this system.

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
Permission level has not been tested. 
It is assumed you will need to have sufficient rights to uninstall devices from device manager for this script to run properly.

## RELATED LINKS
