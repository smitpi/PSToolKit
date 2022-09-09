---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# New-ElevatedShortcut

## SYNOPSIS

Creates a shortcut to a script or exe that runs as admin, without UNC

## SYNTAX

### Set1 (Default)

```
New-ElevatedShortcut [-ShortcutName] <String> [-FilePath] <String> [-OpenPath] [<CommonParameters>]
```

## DESCRIPTION

Creates a shortcut to a script or exe that runs as admin, without UNC


## EXAMPLES

### Example 1: EXAMPLE 1

```
New-ElevatedShortcut -ShortcutName blah -FilePath cmd.exe
```








## PARAMETERS

### -FilePath

Path to the executable or ps1 file

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (All) False (None)
Position: 1
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -OpenPath

Open explorer to the .lnk file.

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

### -ShortcutName

Name of the shortcut

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (All) False (None)
Position: 0
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## NOTES



## RELATED LINKS

Fill Related Links Here

