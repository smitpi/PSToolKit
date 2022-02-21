---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Find-PSScripts

## SYNOPSIS
Find and update script info

## SYNTAX

```
Find-PSScripts [[-Path] <DirectoryInfo>] [[-InHours] <Int32>] [-SelectGrid] [-UpdateUnknown] [-NeedUpdate]
 [-UpdateAll] [<CommonParameters>]
```

## DESCRIPTION
Find and update script info

## EXAMPLES

### EXAMPLE 1
```
Find-PSScripts -path . -SelectGrid
```

## PARAMETERS

### -Path
Path to scripts

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $pwd
Accept pipeline input: False
Accept wildcard characters: False
```

### -InHours
Changed in the last x hours

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -SelectGrid
Display a out-grid view

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

### -UpdateUnknown
Update if info is unknown

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

### -NeedUpdate
Update if info is old

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

### -UpdateAll
Update all

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
