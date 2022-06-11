---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: https://smitpi.github.io/PSToolKit/Install-LocalPSRepository
schema: 2.0.0
---

# New-PSModule

## SYNOPSIS
Creates a new PowerShell module.

## SYNTAX

```
New-PSModule [[-ModulePath] <DirectoryInfo>] [-ModuleName] <String> [[-Author] <String>]
 [-Description] <String> [-Tag] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Creates a new PowerShell module.

## EXAMPLES

### EXAMPLE 1
```
New-PSModule -ModulePath C:\Temp\ -ModuleName blah -Description 'blah' -Tag ps
```

## PARAMETERS

### -ModulePath
Path to where it will be saved.

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

### -ModuleName
Name of module

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

### -Author
Who wrote it

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: Pierre Smit
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
What it does

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: (Read-Host Description)
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tag
Tags for reaches.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: (Read-Host Tag)
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
