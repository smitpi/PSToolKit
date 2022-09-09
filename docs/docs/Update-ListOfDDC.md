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

### __AllParameterSets

```
Update-ListOfDDC [[-ComputerName <String>]] [[-CloudConnectors <String[]>]] [-CurrentOnly] [<CommonParameters>]
```

## DESCRIPTION

Update list of ListOfDDCs in the registry


## EXAMPLES

### Example 1: EXAMPLE 1

```
Update-ListOfDDCs -ComputerName AD01 -CloudConnectors $DDC
```








## PARAMETERS

### -CloudConnectors

List of DDC or Cloud Connector FQDN

```yaml
Type: String[]
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

### -ComputerName

Server to update

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 0
Default value: localhost
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -CurrentOnly

Only display current setting.

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



## RELATED LINKS

Fill Related Links Here

