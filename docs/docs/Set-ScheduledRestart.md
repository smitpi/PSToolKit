---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Set-ScheduledRestart

## SYNOPSIS
Create a scheduled task to reboot a server.

## SYNTAX

```
Set-ScheduledRestart [-ComputerName] <String[]> [-Credential <PSCredential>] [-RebootDate <DateTime>]
 [<CommonParameters>]
```

## DESCRIPTION
Create a scheduled task to reboot a server.

## EXAMPLES

### EXAMPLE 1
```
Set-ScheduledRestart -ComputerName $Env:COMPUTERNAME -Credential $admin -RebootDate $date
```

## PARAMETERS

### -ComputerName
List of servers to reboot.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: CN, host

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
Credentials to connect to the server, if needed.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RebootDate
The date and time to run the reboot.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

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

### System.Object[]
## NOTES

## RELATED LINKS
