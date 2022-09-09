---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# Start-PSRoboCopy

## SYNOPSIS

My wrapper for default robocopy switches

## SYNTAX

### __AllParameterSets

```
Start-PSRoboCopy [-Source] <DirectoryInfo> [-Destination] <DirectoryInfo> [-Action] <String> [[-IncludeFiles <String[]>]] [[-eXcludeFiles <String[]>]] [[-eXcludeDirs <String[]>]] [[-LogPath <DirectoryInfo>]] [-TestOnly] [<CommonParameters>]
```

## DESCRIPTION

My wrapper for default robocopy switches


## EXAMPLES

### Example 1: EXAMPLE 1

```
Start-PSRoboCopy -Source C:\Utils\LabTools -Destination P:\Utils\LabTools2 -Action copy -eXcludeFiles *.git
```








## PARAMETERS

### -Action

3 choices.
Copy files and folders, Move files and folders or mirror the folders (Destination files will be overwritten)

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (All) False (None)
Position: 2
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Destination

Where it will be copied.

```yaml
Type: DirectoryInfo
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

### -eXcludeDirs

Exclude these folders (can use wildcards)

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 5
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -eXcludeFiles

Exclude these files (can use wildcards)

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 4
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -IncludeFiles

Only copy these files

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 3
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -LogPath

Where to save the log.
If the log file exists, it will be appended.

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 6
Default value: C:\Temp
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Source

Folder to copy.

```yaml
Type: DirectoryInfo
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

### -TestOnly

Don't do any changes, see which files has changed.

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


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## NOTES



## RELATED LINKS

Fill Related Links Here

