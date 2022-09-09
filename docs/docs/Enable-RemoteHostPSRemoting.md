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

### __AllParameterSets

```
Enable-RemoteHostPSRemoting [-ComputerName] <String> [-AdminCredentials <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION

enable ps remote remotely


## EXAMPLES

### Example 1: EXAMPLE 1

```
Enable-RemoteHostPSRemoting -ComputerName $host -AdminCredentials $cred
```








## PARAMETERS

### -AdminCredentials

Credentials with admin access

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: (Get-Credential)
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ComputerName

The remote computer

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (All) False (None)
Position: 0
Default value: 
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

