---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# New-PSScript

## SYNOPSIS

Creates a new PowerShell script. With PowerShell Script Info

## SYNTAX

### __AllParameterSets

```
New-PSScript [[-Path <DirectoryInfo>]] [-Verb] <String> [-Noun] <String> [[-Author <String>]] [-Description] <String> [-tags] <String[]> [<CommonParameters>]
```

## DESCRIPTION

Creates a new PowerShell script.
With PowerShell Script Info


## EXAMPLES

### Example 1: EXAMPLE 1

```
New-PSScript -Path .\PSToolKit\Private\ -Verb get -Noun blah -Description 'blah' -tags PS
```








## PARAMETERS

### -Author

Who wrote it.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 3
Default value: Pierre Smit
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Description

What it does.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (All) False (None)
Position: 4
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Noun

Second part of script name.

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

### -Path

Where the script will be created.

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 0
Default value: $pwd
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -tags

Tags for searches.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (All) False (None)
Position: 5
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Verb

Approved PowerShell verb

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


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## NOTES



## RELATED LINKS

Fill Related Links Here

