---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Update-PSModuleInfo

## SYNOPSIS
Update PowerShell module manifest file

## SYNTAX

```
Update-PSModuleInfo [-ModuleManifestPath] <FileInfo> [[-Author] <String>] [[-Description] <String>]
 [[-tag] <String[]>] [-MinorUpdate] [[-ChangesMade] <String>] [<CommonParameters>]
```

## DESCRIPTION
Update PowerShell module manifest file

## EXAMPLES

### EXAMPLE 1
```
Update-PSModuleInfo -ModuleManifestPath .\PSLauncher.psd1 -ChangesMade 'Added button to add more panels'
```

## PARAMETERS

### -ModuleManifestPath
Path to .psd1 file

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

### -Author
Who wrote the moduke

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Pierre Smit
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
What it does

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

### -tag
Tags for searching

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MinorUpdate
Major update increase

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

### -ChangesMade
What has changed in the module.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: Module Info was updated
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
