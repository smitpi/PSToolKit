---
document type: cmdlet
external help file: PSToolKit-Help.xml
HelpUri: https://smitpi.github.io/PSToolKit/Set-UserDesktopWallpaper
Locale: en-US
Module Name: PSToolKit
ms.date: 02/24/2026
PlatyPS schema version: 2024-05-01
title: Set-UserDesktopWallpaper
---

# Set-UserDesktopWallpaper

## SYNOPSIS

Change the wallpaper for the user.

## SYNTAX

### __AllParameterSets

```
Set-UserDesktopWallpaper [-PicturePath] <string> [[-Style] <string>] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Change the wallpaper for the user.

## EXAMPLES

### EXAMPLE 1

Set-DesktopWallpaper -PicturePath "C:\pictures\picture1.jpg" -Style Fill

## PARAMETERS

### -PicturePath

Defines the path to the picture to use for background

```yaml
Type: String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Style

Defines the style of the wallpaper.
Valid values are, Tiled, Centered, Stretched, Fill, Fit, Span

```yaml
Type: String
DefaultValue: Fill
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 1
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

{{ Fill in the related links here }}

