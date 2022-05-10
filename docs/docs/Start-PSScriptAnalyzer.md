---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Start-PSScriptAnalyzer

## SYNOPSIS
Run and report ScriptAnalyzer output

## SYNTAX

```
Start-PSScriptAnalyzer [-Paths] <DirectoryInfo[]> [[-ExcludeRules] <String[]>] [[-Export] <String>]
 [[-ReportPath] <DirectoryInfo>] [<CommonParameters>]
```

## DESCRIPTION
Run and report ScriptAnalyzer output

## EXAMPLES

### EXAMPLE 1
```
Start-PSScriptAnalyzer -Path C:\temp
```

## PARAMETERS

### -Paths
Path to ps1 files

```yaml
Type: DirectoryInfo[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeRules
Exclude rules from report.

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

### -Export
Export results

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: Host
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReportPath
Where to export to.

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
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