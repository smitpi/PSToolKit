---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Set-PSProjectFile

## SYNOPSIS
Creates and modify needed files for a PS project from existing module files.

## SYNTAX

```
Set-PSProjectFile [-ModulePSM1] <FileInfo> [[-VersionBump] <String>] [[-mkdocs] <String>] [-GitPush]
 [<CommonParameters>]
```

## DESCRIPTION
Creates and modify needed files for a PS project from existing module files.

## EXAMPLES

### EXAMPLE 1
```
Set-PSProjectFiles -ModulePSM1 c:\temp\blah.psm1 -VersionBump Minor -mkdocs serve
```

## PARAMETERS

### -ModulePSM1
Path to module .psm1 file.

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
This will increase the version of the module.

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

### -mkdocs
Create and test the mkdocs site

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
Run Git Push when done.

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

## NOTES

## RELATED LINKS
