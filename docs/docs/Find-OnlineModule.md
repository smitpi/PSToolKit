---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Find-OnlineModule

## SYNOPSIS
Find a module on psgallery

## SYNTAX

```
Find-OnlineModule [[-Keyword] <String>] [-Offline] [-UpdateCache] [-ConsoleOutput <String>]
 [-MarkdownOutput <String>] [<CommonParameters>]
```

## DESCRIPTION
Find a module on psgallery

## EXAMPLES

### EXAMPLE 1
```
Find-OnlineModule -Keyword Citrix -Offline -Output AsObject
```

## PARAMETERS

### -Keyword
What to search for.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Offline
Uses a previously downloaded cache for the earch.
If the cache doesnt exists, it will be created.

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

### -UpdateCache
Update the local cache.

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

### -ConsoleOutput
How to display the results.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: AsObject
Accept pipeline input: False
Accept wildcard characters: False
```

### -MarkdownOutput
Export results to markdown file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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
