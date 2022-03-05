---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Export-CitrixPolicySettings

## SYNOPSIS
Citrix policy export.

## SYNTAX

```
Export-CitrixPolicySettings [-FormatTable] [-ExportToExcel] [[-ReportPath] <String>] [[-ReportName] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Citrix policy export.
Run it from the DDC.

## EXAMPLES

### EXAMPLE 1
```
Export-CitrixPolicySettings -FormatTable
```

## PARAMETERS

### -FormatTable
Display as a table

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

### -ExportToExcel
Export output to excel

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

### -ReportPath
Path to where it will be saved

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $env:TMP
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReportName
Name of the report

```yaml
Type: String
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
