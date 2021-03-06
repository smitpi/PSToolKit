---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Publish-ModuleToLocalRepo

## SYNOPSIS
Checks for required modules and upload all to your local repo.

## SYNTAX

```
Publish-ModuleToLocalRepo [[-ManifestPaths] <String[]>] [-Repository] <String> [<CommonParameters>]
```

## DESCRIPTION
Checks for required modules and upload all to your local repo.

## EXAMPLES

### EXAMPLE 1
```
Publish-ModuleToLocalRepo -ManifestPaths .\PSConfigFile\PSConfigFile\PSConfigFile.psd1 -Repository blah
```

## PARAMETERS

### -ManifestPaths
Path to the .psd1 file.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Repository
Name of the local repository.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object[]
## NOTES

## RELATED LINKS
