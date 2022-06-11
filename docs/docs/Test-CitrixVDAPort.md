---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: https://smitpi.github.io/PSToolKit/Install-LocalPSRepository
schema: 2.0.0
---

# Test-CitrixVDAPort

## SYNOPSIS
Test connection between ddc and vda

## SYNTAX

```
Test-CitrixVDAPort [-ServerList] <ArrayList> [[-PortsList] <ArrayList>] [[-Export] <String>]
 [[-ReportPath] <String>] [<CommonParameters>]
```

## DESCRIPTION
Test connection between ddc and vda

## EXAMPLES

### EXAMPLE 1
```
Test-CitrixVDAPorts -ServerList $list
```

## PARAMETERS

### -ServerList
List servers to test

```yaml
Type: ArrayList
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PortsList
List of ports to test

```yaml
Type: ArrayList
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: @('80', '443', '1494', '2598')
Accept pipeline input: False
Accept wildcard characters: False
```

### -Export
Export the results.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: Host
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReportPath
Where report will be saves.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: $env:temp
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
