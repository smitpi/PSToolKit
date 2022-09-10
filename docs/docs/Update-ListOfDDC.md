---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Update-ListOfDDC

## SYNOPSIS
Update list of ListOfDDCs in the registry

## SYNTAX

```
Update-ListOfDDC [[-ComputerName] <String>] [-CurrentOnly] [[-CloudConnectors] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Update list of ListOfDDCs in the registry

## EXAMPLES

### EXAMPLE 1
```
Update-ListOfDDCs -ComputerName AD01 -CloudConnectors $DDC
```

## PARAMETERS

### -ComputerName
Server to update

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Localhost
Accept pipeline input: False
Accept wildcard characters: False
```

### -CurrentOnly
Only display current setting.

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

### -CloudConnectors
List of DDC or Cloud Connector FQDN

```yaml
Type: String[]
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

## RELATED LINKS
