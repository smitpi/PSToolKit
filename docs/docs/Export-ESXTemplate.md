---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# Export-ESXTemplate

## SYNOPSIS

Export all VM Templates from vSphere to local disk.

## SYNTAX

### __AllParameterSets

```
Export-ESXTemplate [-ExportPath] <DirectoryInfo> [<CommonParameters>]
```

## DESCRIPTION

Export all VM Templates from vSphere to local disk.


## EXAMPLES

### Example 1: EXAMPLE 1

```
Export-ESXTemplates -ExportPath c:\temp
```








## PARAMETERS

### -ExportPath

Directory to export to

```yaml
Type: DirectoryInfo
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


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## NOTES



## RELATED LINKS

Fill Related Links Here

