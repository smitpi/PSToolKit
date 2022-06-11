---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Write-Ascii

## SYNOPSIS
Create Ascii Art

## SYNTAX

```
Write-Ascii [-InputObject] <String[]> [-PrependChar] [-Compress] [[-ForegroundColor] <String>]
 [[-BackgroundColor] <String>] [<CommonParameters>]
```

## DESCRIPTION
Create Ascii Art

## EXAMPLES

### EXAMPLE 1
```
Write-Ascii Blah
```

## PARAMETERS

### -InputObject
The string

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: InputText

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -PrependChar
char

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

### -Compress
compress output

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: Compression

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ForegroundColor
ForegroundColor

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Default
Accept pipeline input: False
Accept wildcard characters: False
```

### -BackgroundColor
BackgroundColor

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: Default
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
