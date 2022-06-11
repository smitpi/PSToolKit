---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: https://smitpi.github.io/PSToolKit/Install-LocalPSRepository
schema: 2.0.0
---

# Search-Script

## SYNOPSIS
Search for a string in a directory of ps1 scripts.

## SYNTAX

```
Search-Script [[-Path] <String[]>] [[-Include] <String[]>] [[-KeyWord] <String[]>] [-ListView]
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

### -Path
Path to search.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $pwd
Accept pipeline input: False
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
Position: 2
Default value: *.ps1
Accept pipeline input: False
Accept wildcard characters: False
```

### -KeyWord
The string to search for.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: (Read-Host 'Keyword?')
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
