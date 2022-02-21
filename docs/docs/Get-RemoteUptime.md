---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Get-RemoteUptime

## SYNOPSIS
Check the uptime of a list of servers

## SYNTAX

```
Get-RemoteUptime [[-ComputerName] <String[]>] [-ShowOfflineComputers] [<CommonParameters>]
```

## DESCRIPTION
Check the uptime of a list of servers

## EXAMPLES

### EXAMPLE 1
```
Get-RemoteUptime -ComputerName $list
```

## PARAMETERS

### -ComputerName
Server Names to check

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $env:COMPUTERNAME
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -ShowOfflineComputers
Show which servers are offline

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
