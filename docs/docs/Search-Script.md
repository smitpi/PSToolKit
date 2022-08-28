---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: https://smitpi.github.io/PSToolKit/Edit-HostsFile
schema: 2.0.0
---

# Search-Script

## SYNOPSIS
Search for a string in a directory of ps1 scripts.

## SYNTAX

```
Search-Script [[-KeyWord] <String[]>] [[-Path] <DirectoryInfo[]>] [[-Include] <String[]>] [-ListView]
 [<CommonParameters>]
```

## DESCRIPTION
Search for a string in a directory of ps1 scripts.

## EXAMPLES

### EXAMPLE 1
```
Search-Scripts -Path . -KeyWord "contain" -ListView
```

## PARAMETERS

### -KeyWord
The string to search for.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: (Read-Host 'Keyword?')
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Path to search.

```yaml
Type: DirectoryInfo[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: (Get-Item $PSScriptRoot)
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Include
File extension to search.
Default is ps1.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: @('*.ps1', '*.psm1', '*.psd1')
Accept pipeline input: False
Accept wildcard characters: False
```

### -ListView
Show result as a list.

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
