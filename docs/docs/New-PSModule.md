---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# New-PSModule

## SYNOPSIS

Creates a new PowerShell module.

## SYNTAX

### __AllParameterSets

```
New-PSModule [[-ModulePath <DirectoryInfo>]] [-ModuleName] <String> [[-Author <String>]] [-Description] <String> [-Tag] <String[]> [<CommonParameters>]
```

## DESCRIPTION

Creates a new PowerShell module.


## EXAMPLES

### Example 1: EXAMPLE 1

```
New-PSModule -ModulePath C:\Temp\ -ModuleName blah -Description 'blah' -Tag ps
```








## PARAMETERS

### -Author

Who wrote it

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 2
Default value: Pierre Smit
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Description

What it does

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (All) False (None)
Position: 3
Default value: (Read-Host Description)
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ModuleName

Name of module

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

### -ModulePath

Path to where it will be saved.

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

### -Tag

Tags for reaches.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (All) False (None)
Position: 4
Default value: (Read-Host Tag)
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## NOTES



## RELATED LINKS

Fill Related Links Here

