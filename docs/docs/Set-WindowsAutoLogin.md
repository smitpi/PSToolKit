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
Set-WindowsAutoLogin -ComputerName <String[]> [-Action <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### Enable
```
Set-WindowsAutoLogin -ComputerName <String[]> [-Action <String>] [-LogonCredentials <PSCredential>]
 [-RestartHost] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Enable autologin on a device.

## EXAMPLES

### EXAMPLE 1
```
Set-WindowsAutoLogin -ComputerName apollo.internal.lab -Action Enable -LogonCredentials $newcred -RestartHost
```

## PARAMETERS

### -ComputerName
The target computer name.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Action
Disable or enable settings.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogonCredentials
Credentials to use.

```yaml
Type: PSCredential
Parameter Sets: Enable
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RestartHost
Restart device after change.

```yaml
Type: SwitchParameter
Parameter Sets: Enable
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
General notes

## RELATED LINKS
