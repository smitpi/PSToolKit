---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Write-PSReports

## SYNOPSIS
Creates a excel or html report

## SYNTAX

```
Write-PSReports [-InputObject] <PSObject> [-ReportTitle] <String> [-ExcelConditionalText <PSObject>]
 [-TextWrap] [-Export <String[]>] [-ReportPath <DirectoryInfo>] [-OpenReportsFolder]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Creates a excel or html report

## EXAMPLES

### EXAMPLE 1
```
[System.Collections.generic.List[PSObject]]$Conditions = @()    
$Conditions.Add((New-ConditionalText -Text 'Warning' -ConditionalTextColor black -BackgroundColor Yellow -Range 'E:E' ))
$Conditions.Add((New-ConditionalText -Text 'Error' -ConditionalTextColor black -BackgroundColor orange -Range 'E:E' ))
$Conditions.Add((New-ConditionalText -Text 'Critical' -ConditionalTextColor white -BackgroundColor Red -Range 'E:E' ))
```

Write-PSReports -InputObject $report -ReportTitle 'Windows Events' -Export All -ReportPath C:\temp -ExcelConditionalText $Conditions

## PARAMETERS

### -InputObject
Data for the report.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReportTitle
Title of the report.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcelConditionalText
Add Conditional text color to the cells.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TextWrap
Wrap the text in the excel report.

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
Export the result to a report file.
(Excel or html5 or normal html).

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReportPath
Where to save the report.

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: C:\Temp
Accept pipeline input: False
Accept wildcard characters: False
```

### -OpenReportsFolder
Open the directory of creating the reports.

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

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
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
