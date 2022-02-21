---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Import-CitrixSiteConfigFile

## SYNOPSIS
Import the CItrix config file, and created a variable with the details

## SYNTAX

```
Import-CitrixSiteConfigFile [[-CitrixSiteConfigFilePath] <String>] [<CommonParameters>]
```

## DESCRIPTION
Import the CItrix config file, and created a variable with the details

## EXAMPLES

### EXAMPLE 1
```
Import-CitrixSiteConfigFile -CitrixSiteConfigFilePath c:\temp\CTXSiteConfig.json
```

## PARAMETERS

### -CitrixSiteConfigFilePath
Path to config file

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: (Get-Item $profile).DirectoryName + '\Config\CTXSiteConfig.json'
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
General notes

## RELATED LINKS
