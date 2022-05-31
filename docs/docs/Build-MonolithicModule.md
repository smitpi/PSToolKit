---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Build-MonolithicModule

## SYNOPSIS
Combines ps1 files into one psm1 file

## SYNTAX

```
Build-MonolithicModule [-ModulePSM1] <FileInfo> [[-VersionBump] <String>] [-CopyNestedModules]
 [[-OutputFolder] <DirectoryInfo>] [<CommonParameters>]
```

## DESCRIPTION
Combines ps1 files into one psm1 file

## EXAMPLES

### EXAMPLE 1
```
Build-MonolithicModule -Export HTML -ReportPath C:\temp
```

## PARAMETERS

### -ModulePSM1
{{ Fill ModulePSM1 Description }}

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VersionBump
{{ Fill VersionBump Description }}

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

### -CopyNestedModules
{{ Fill CopyNestedModules Description }}

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

### -OutputFolder
{{ Fill OutputFolder Description }}

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: C:\Temp
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
