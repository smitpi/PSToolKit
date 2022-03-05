---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Enable-RemoteHostPSRemoting

## SYNOPSIS
enable ps remote remotely

## SYNTAX

```
Enable-RemoteHostPSRemoting [-ComputerName] <String> [-AdminCredentials <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION
enable ps remote remotely

## EXAMPLES

### EXAMPLE 1
```
Enable-RemoteHostPSRemoting -ComputerName $host -AdminCredentials $cred
```

## PARAMETERS

### -ComputerName
The remote computer

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

### -AdminCredentials
Credentials with admin access

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: (Get-Credential)
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
