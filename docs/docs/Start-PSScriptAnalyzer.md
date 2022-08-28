---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: https://smitpi.github.io/PSToolKit/Edit-HostsFile
schema: 2.0.0
---

# Start-PSScriptAnalyzer

## SYNOPSIS
Run and report ScriptAnalyzer output

## SYNTAX

### ExDef (Default)
```
Start-PSScriptAnalyzer [-Paths <DirectoryInfo[]>] [-ExcludeDefault] [-Export <String>]
 [-ReportPath <DirectoryInfo>] [<CommonParameters>]
```

### ExCus
```
Start-PSScriptAnalyzer [-Paths <DirectoryInfo[]>] [-ExcludeRules <String[]>] [-Export <String>]
 [-ReportPath <DirectoryInfo>] [<CommonParameters>]
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

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeRules
Exclude rules from report.
Specify your own list.

```yaml
Type: String[]
Parameter Sets: ExCus
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeDefault
Will exclude these rules: PSAvoidTrailingWhitespace,PSUseShouldProcessForStateChangingFunctions,PSAvoidUsingWriteHost,PSUseSingularNouns

```yaml
Type: SwitchParameter
Parameter Sets: ExDef
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
Position: Named
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
Position: Named
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
