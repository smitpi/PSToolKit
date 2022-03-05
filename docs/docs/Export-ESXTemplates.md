---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Export-ESXTemplates

## SYNOPSIS
Export all VM Templates from vSphere to local disk.

## SYNTAX

```
Export-ESXTemplates [-ExportPath] <DirectoryInfo> [<CommonParameters>]
```

## DESCRIPTION
Export all VM Templates from vSphere to local disk.

## EXAMPLES

### EXAMPLE 1
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

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
