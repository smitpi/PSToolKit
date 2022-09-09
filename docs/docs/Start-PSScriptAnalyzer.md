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

### ExDef (Default)

```
Start-PSScriptAnalyzer [-ExcludeDefault] [-Export <String>] [-Paths <DirectoryInfo[]>] [-ReportPath <DirectoryInfo>] [<CommonParameters>]
```

### ExCus

```
Start-PSScriptAnalyzer [-ExcludeRules <String[]>] [-Export <String>] [-Paths <DirectoryInfo[]>] [-ReportPath <DirectoryInfo>] [<CommonParameters>]
```

## DESCRIPTION

Run and report ScriptAnalyzer output


## EXAMPLES

### Example 1: EXAMPLE 1

```
Start-PSScriptAnalyzer -Path C:\temp
```








## PARAMETERS

### -ExcludeDefault

Will exclude these rules: PSAvoidTrailingWhitespace,PSUseShouldProcessForStateChangingFunctions,PSAvoidUsingWriteHost,PSUseSingularNouns

```yaml
Type: SwitchParameter
Parameter Sets: ExDef
Aliases: 
Accepted values: 

Required: True (None) False (ExDef)
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ExcludeRules

Exclude rules from report.
Specify your own list.

```yaml
Type: String[]
Parameter Sets: ExCus
Aliases: 
Accepted values: 

Required: True (None) False (ExCus)
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Export

Export results

```yaml
Type: String
Parameter Sets: ExCus, ExDef
Aliases: 
Accepted values: 

Required: True (None) False (ExCus, ExDef)
Position: Named
Default value: Host
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Paths

Path to ps1 files

```yaml
Type: DirectoryInfo[]
Parameter Sets: ExCus, ExDef, (All)
Aliases: 
Accepted values: 

Required: True (All) False (ExCus, ExDef)
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ReportPath

Where to export to.

```yaml
Type: DirectoryInfo
Parameter Sets: ExCus, ExDef
Aliases: 
Accepted values: 

Required: True (None) False (ExCus, ExDef)
Position: Named
Default value: C:\Temp
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## OUTPUTS

### System.Object[]


## NOTES



## RELATED LINKS

Fill Related Links Here

