---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# Get-CitrixClientVersion

## SYNOPSIS

Report on the CItrix workspace versions the users are using.

## SYNTAX

### __AllParameterSets

```
Get-CitrixClientVersion [-AdminAddress] <String> [-hours] <Int32> [-ReportsPath] <String[]> [<CommonParameters>]
```

## DESCRIPTION

Report on the CItrix workspace versions the users are using.


## EXAMPLES

### Example 1: EXAMPLE 1

```
Get-CitrixClientVersions -AdminAddress localhost -hours 12
```








## PARAMETERS

### -AdminAddress

DDC FQDN

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

### -hours

Limit the amount of data to collect from OData

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (All) False (None)
Position: 1
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ReportsPath

Where report will be saved.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (All) False (None)
Position: 2
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## NOTES



## RELATED LINKS

Fill Related Links Here

