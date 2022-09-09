---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# Set-FolderCustomIcon

## SYNOPSIS

Will change the icon of a folder to a custom selected icon

## SYNTAX

### __AllParameterSets

```
Set-FolderCustomIcon [[-FolderPath <DirectoryInfo>]] [[-CustomIconPath <String>]] [[-Index <Int32>]] [<CommonParameters>]
```

## DESCRIPTION

Will change the icon of a folder to a custom selected icon


## EXAMPLES

### Example 1: EXAMPLE 1

```
Set-FolderCustomIcon -FolderPath C:\temp -CustomIconPath C:\WINDOWS\System32\SHELL32.dll -Index 27
```








## PARAMETERS

### -CustomIconPath

Path to the .ico, .exe, .icl or .dll file, containing the icon.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 1
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -FolderPath

Path to the folder to be changed.

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 0
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Index

The index of the icon in the file.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 2
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## OUTPUTS

### System.Object[]


## NOTES

General notes


## RELATED LINKS

Fill Related Links Here

