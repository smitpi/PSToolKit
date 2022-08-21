---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Edit-ChocolateyAppsList

## SYNOPSIS
Add or remove apps from the json file used in Install-ChocolateyApps

## SYNTAX

### Current (Default)
```
Edit-ChocolateyAppsList [-List <String>] [-ShowCurrent] [<CommonParameters>]
```

### Remove
```
Edit-ChocolateyAppsList [-List <String>] [-RemoveApp] [<CommonParameters>]
```

### Add
```
Edit-ChocolateyAppsList [-List <String>] [-AddApp <String>] [-ChocoSource <String>] [<CommonParameters>]
```

## DESCRIPTION
Add or remove apps from the json file used in Install-ChocolateyApps

## EXAMPLES

### EXAMPLE 1
```
Edit-ChocolateyAppsList -AddApp -ChocoID 7zip -ChocoSource chocolatey
```

## PARAMETERS

### -List
Which list to use.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: ExtendedApps
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowCurrent
List current apps in the json file

```yaml
Type: SwitchParameter
Parameter Sets: Current
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoveApp
Remove app from the list

```yaml
Type: SwitchParameter
Parameter Sets: Remove
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -AddApp
add an app to the list.

```yaml
Type: String
Parameter Sets: Add
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ChocoSource
The source where the app is hosted

```yaml
Type: String
Parameter Sets: Add
Aliases:

Required: False
Position: Named
Default value: Chocolatey
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
