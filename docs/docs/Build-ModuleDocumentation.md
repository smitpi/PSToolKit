---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Build-ModuleDocumentation

## SYNOPSIS
Use Platyps to create documentation form help

## SYNTAX

```
Build-ModuleDocumentation [-ModulePSM1] <FileInfo> [[-VersionBump] <String>] [-CopyNestedModules]
 [[-mkdocs] <String>] [-GitPush] [<CommonParameters>]
```

## DESCRIPTION
Use Platyps to create documentation form help

## EXAMPLES

### EXAMPLE 1
```
Build-ModuleDocumentation -Export HTML -ReportPath C:\temp
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

### -mkdocs
{{ Fill mkdocs Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GitPush
{{ Fill GitPush Description }}

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
