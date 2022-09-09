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

### __AllParameterSets

```
Publish-ModuleToLocalRepo [[-ManifestPaths <String[]>]] [-Repository] <String> [<CommonParameters>]
```

## DESCRIPTION

Checks for required modules and upload all to your local repo.


## EXAMPLES

### Example 1: EXAMPLE 1

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
Accepted values: 

Required: True (None) False (All)
Position: 0
Default value: 
Accept pipeline input: True
Accept wildcard characters: False
DontShow: False
```

### -Repository

Name of the local repository.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (All) False (None)
Position: 1
Default value: 
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

