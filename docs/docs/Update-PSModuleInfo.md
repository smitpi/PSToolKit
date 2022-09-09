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

### __AllParameterSets

```
Update-PSModuleInfo [-ModuleManifestPath] <FileInfo> [[-Author <String>]] [[-Description <String>]] [[-tag <String[]>]] [[-ChangesMade <String>]] [-MinorUpdate] [<CommonParameters>]
```

## DESCRIPTION

Update PowerShell module manifest file


## EXAMPLES

### Example 1: EXAMPLE 1

```
Update-PSModuleInfo -ModuleManifestPath .\PSLauncher.psd1 -ChangesMade 'Added button to add more panels'
```








## PARAMETERS

### -Author

Who wrote the module.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 1
Default value: Pierre Smit
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ChangesMade

What has changed in the module.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 4
Default value: Module Info was updated
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Description

What it does

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 2
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -MinorUpdate

Major update increase

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ModuleManifestPath

Path to .psd1 file

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (All) False (None)
Position: 0
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -tag

Tags for searching

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 3
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## OUTPUTS

### System.Collections.Hashtable


## NOTES



## RELATED LINKS

Fill Related Links Here

