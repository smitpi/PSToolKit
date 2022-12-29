---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Set-UserDesktopWallpaper

## SYNOPSIS
Change the wallpaper for the user.

## SYNTAX

```
Set-UserDesktopWallpaper [-PicturePath] <String> [[-Style] <String>] [<CommonParameters>]
```

## DESCRIPTION
Change the wallpaper for the user.

## EXAMPLES

### EXAMPLE 1
```
Set-DesktopWallpaper -PicturePath "C:\pictures\picture1.jpg" -Style Fill
```

## PARAMETERS

### -PicturePath
Defines the path to the picture to use for background

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

### -Style
Defines the style of the wallpaper.
Valid values are, Tiled, Centered, Stretched, Fill, Fit, Span

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Fill
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
