---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: https://smitpi.github.io/PSToolKit/Edit-HostsFile
schema: 2.0.0
---

# Restore-ElevatedShortcut

## SYNOPSIS
Restore the RunAss shortcuts, from a zip file

## SYNTAX

```
Restore-ElevatedShortcut [-ZipFilePath] <FileInfo> [-ForceReinstall] [<CommonParameters>]
```

## DESCRIPTION
Restore the RunAss shortcuts, from a zip file

## EXAMPLES

### EXAMPLE 1
```
Restore-ElevatedShortcut -ZipFilePath c:\temp\bck.zip -ForceReinstall
```

## PARAMETERS

### -ZipFilePath
Path to the backup file

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ForceReinstall
Override existing shortcuts

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
