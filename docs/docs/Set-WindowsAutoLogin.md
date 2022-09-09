---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# Set-WindowsAutoLogin

## SYNOPSIS

Enable autologin on a device.

## SYNTAX

### Disable (Default)

```
Set-WindowsAutoLogin -ComputerName <String[]> [-Action <String>] [<CommonParameters>]
```

### Enable

```
Set-WindowsAutoLogin -ComputerName <String[]> [-Action <String>] [-LogonCredentials <PSCredential>] [-RestartHost] [<CommonParameters>]
```

## DESCRIPTION

Enable autologin on a device.


## EXAMPLES

### Example 1: EXAMPLE 1

```
Set-WindowsAutoLogin -ComputerName apollo.internal.lab -Action Enable -LogonCredentials $newcred -RestartHost
```








## PARAMETERS

### -Action

Disable or enable settings.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ComputerName

The target computer name.

```yaml
Type: String[]
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

### -LogonCredentials

Credentials to use.

```yaml
Type: PSCredential
Parameter Sets: Enable
Aliases: 
Accepted values: 

Required: True (None) False (Enable)
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -RestartHost

Restart device after change.

```yaml
Type: SwitchParameter
Parameter Sets: Enable
Aliases: 
Accepted values: 

Required: True (None) False (Enable)
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## NOTES

General notes


## RELATED LINKS

Fill Related Links Here

