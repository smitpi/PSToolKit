---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Sync-PSFolders

## SYNOPSIS
Compare two directories and copy the differences

## SYNTAX

```
Sync-PSFolders [-LeftFolder] <DirectoryInfo> [-RightFolder] <DirectoryInfo> [-SetLongPathRegKey]
 [<CommonParameters>]
```

## DESCRIPTION
Compare two directories and copy the differences.
Newest file wins

## EXAMPLES

### EXAMPLE 1
```
Sync-PSFolders -LeftFolder C:\Temp\one -RightFolder C:\Temp\6
```

## PARAMETERS

### -LeftFolder
First Folder to compare

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RightFolder
Second folder to compare

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SetLongPathRegKey
Enable long file path in registry

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
General notes

## RELATED LINKS
