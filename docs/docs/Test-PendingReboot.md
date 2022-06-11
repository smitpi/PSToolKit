---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Test-PendingReboot

## SYNOPSIS
This script tests various registry values to see if the local computer is pending a reboot.

## SYNTAX

```
Test-PendingReboot [-ComputerName] <String[]> [[-Credential] <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION
This script tests various registry values to see if the local computer is pending a reboot.

## EXAMPLES

### EXAMPLE 1
```
Test-PendingReboot -ComputerName localhost
```

## PARAMETERS

### -ComputerName
Computer to check.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
User with admin access.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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
