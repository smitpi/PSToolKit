---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# New-MSEdgeWebApp

## SYNOPSIS
Creates a new webapp to a URL, and save the shortcut on your system.

## SYNTAX

```
New-MSEdgeWebApp [-AppName] <String> [-URL] <String> [-IconPath <FileInfo>] [-Path <DirectoryInfo>]
 [<CommonParameters>]
```

## DESCRIPTION
Creates a new webapp to a URL, and save the shortcut on your system.

## EXAMPLES

### EXAMPLE 1
```
New-MSEdgeWebApp -Export HTML -ReportPath C:\temp
```

## PARAMETERS

### -AppName
The name of the webapp

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -URL
The URL of the webapp.

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

### -IconPath
{{ Fill IconPath Description }}

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
The path to save the shortcut to.

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
