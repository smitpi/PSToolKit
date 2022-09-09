---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# Search-Script

## SYNOPSIS

Search for a string in a directory of ps1 scripts.

## SYNTAX

### __AllParameterSets

```
Search-Script [[-KeyWord <String[]>]] [[-Path <DirectoryInfo[]>]] [[-Include <String[]>]] [-ListView] [<CommonParameters>]
```

## DESCRIPTION

Search for a string in a directory of ps1 scripts.


## EXAMPLES

### Example 1: EXAMPLE 1

```
Search-Scripts -Path . -KeyWord "contain" -ListView
```








## PARAMETERS

### -Include

File extension to search.
Default is ps1.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 2
Default value: @('*.ps1', '*.psm1', '*.psd1')
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -KeyWord

The string to search for.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 0
Default value: (Read-Host 'Keyword?')
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ListView

Show result as a list.

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

### -Path

Path to search.

```yaml
Type: DirectoryInfo[]
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 1
Default value: (Get-Item $PSScriptRoot)
Accept pipeline input: True
Accept wildcard characters: False
DontShow: False
```


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## NOTES



## RELATED LINKS

Fill Related Links Here

