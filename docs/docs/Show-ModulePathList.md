---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Show-ModulePathList

## SYNOPSIS
Show installed module list grouped by install path.

## SYNTAX

```
Show-ModulePathList [[-Export] <String[]>] [[-ReportPath] <DirectoryInfo>] [-OpenReportsFolder]
 [<CommonParameters>]
```

## DESCRIPTION
Show installed module list grouped by install path.

## EXAMPLES

### EXAMPLE 1
```
Show-ModulePathList -Export HTML -ReportPath C:\temp
```

## PARAMETERS

### -Export
Export result to Excel or HTML.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Host
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
Position: 2
Default value: C:\Temp
Accept pipeline input: False
Accept wildcard characters: False
```

### -OpenReportsFolder
Open the folder after creation.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object[]
## NOTES

## RELATED LINKS
