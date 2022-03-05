---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Get-WinEventLogExtract

## SYNOPSIS
Extract Event logs of a server list, and create html / excel report

## SYNTAX

```
Get-WinEventLogExtract [[-ComputerName] <String[]>] [[-Days] <Int32>] [[-ErrorLevel] <String>] [-FilterCitrix]
 [[-Export] <String>] [[-ReportPath] <DirectoryInfo>] [<CommonParameters>]
```

## DESCRIPTION
Extract Event logs of a server list, and create html / excel report

## EXAMPLES

### EXAMPLE 1
```
Get-WinEventLogExtract -ComputerName localhost
```

## PARAMETERS

### -ComputerName
Name of the host

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: @($($env:COMPUTERNAME))
Accept pipeline input: False
Accept wildcard characters: False
```

### -Days
Limit the search results

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 7
Accept pipeline input: False
Accept wildcard characters: False
```

### -ErrorLevel
Set the default filter to this level and above.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: Warning
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterCitrix
Only show Citrix errors

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

### -Export
Export results

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
Path where report will be saved

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: C:\Temp
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
