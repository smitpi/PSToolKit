---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# New-PSScript

## SYNOPSIS
Creates a new PowerShell script.
With PowerShell Script Info

## SYNTAX

```
New-PSScript [[-Path] <DirectoryInfo>] [-Verb] <String> [-Noun] <String> [[-Author] <String>]
 [-Description] <String> [-tags] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Creates a new PowerShell script.
With PowerShell Script Info

## EXAMPLES

### EXAMPLE 1
```
New-PSScript -Path .\PSToolKit\Private\ -Verb get -Noun blah -Description 'blah' -tags ps
```

## PARAMETERS

### -Path
Where it will be created.

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

### -Verb
Approved PowerShell verb

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

### -Noun
Second part of script name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Author
Who wrote it.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: Pierre Smit
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
What it does.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -tags
Tags for searches.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
