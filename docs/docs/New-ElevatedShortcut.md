---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: https://smitpi.github.io/PSToolKit/Install-LocalPSRepository
schema: 2.0.0
---

# New-ElevatedShortcut

## SYNOPSIS
Creates a shortcut to a script or exe that runs as admin, without UNC

## SYNTAX

```
New-ElevatedShortcut [-ShortcutName] <String> [-FilePath] <String> [-OpenPath] [<CommonParameters>]
```

## DESCRIPTION
Creates a shortcut to a script or exe that runs as admin, without UNC

## EXAMPLES

### EXAMPLE 1
```
New-ElevatedShortcut -ShortcutName blah -FilePath cmd.exe
```

## PARAMETERS

### -ShortcutName
Name of the shortcut

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

### -FilePath
Path to the executable or ps1 file

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OpenPath
Open explorer to the .lnk file.

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
