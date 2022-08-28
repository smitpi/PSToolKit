---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: https://smitpi.github.io/PSToolKit/Edit-HostsFile
schema: 2.0.0
---

# Get-SoftwareAudit

## SYNOPSIS
Connects to a remote hosts and collect installed software details

## SYNTAX

```
Get-SoftwareAudit [-ComputerName] <String[]> [[-Export] <String>] [[-ReportPath] <String>] [<CommonParameters>]
```

## DESCRIPTION
Connects to a remote hosts and collect installed software details

## EXAMPLES

### EXAMPLE 1
```
Get-SoftwareAudit -ComputerName Neptune -Export Excel
```

## PARAMETERS

### -ComputerName
Name of the computers that will be audited

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

### -Export
Export the results to excel or html

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Host
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReportPath
Path to save the report.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: "$env:TEMP"
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
