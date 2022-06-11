---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Get-FolderSize

## SYNOPSIS
Gets folder sizes using COM and with a fallback to robocopy.exe with the logging option

## SYNTAX

```
Get-FolderSize [-Path] <String[]> [[-Precision] <Int32>] [-RoboOnly] [<CommonParameters>]
```

## DESCRIPTION
Gets folder sizes using COM and with a fallback to robocopy.exe with the logging option
,
    which makes it not actually copy or move files, but just list them, and the end
    summary result is parsed to extract the relevant data.

    This apparently is much faster than .NET and Get-ChildItem in PowerShell.

    The properties of the objects will be different based on which method is used, but
    the "TotalBytes" property is always populated if the directory size was successfully
    retrieved.
Otherwise you should get a warning.

    BSD 3-clause license.

    Copyright (C) 2015, Joakim Svendsen
    All rights reserved.
    Svendsen Tech.

## EXAMPLES

### EXAMPLE 1
```
. .\Get-FolderSize.ps1
PS C:\> 'C:\Windows', 'E:\temp' | Get-FolderSize
```

### EXAMPLE 2
```
Get-FolderSize -Path Z:\Database -Precision 2
```

### EXAMPLE 3
```
Get-FolderSize -Path Z:\Database -RoboOnly
```

## PARAMETERS

### -Path
Path or paths to measure size of.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Precision
Number of digits after decimal point in rounded numbers.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 4
Accept pipeline input: False
Accept wildcard characters: False
```

### -RoboOnly
Do not use COM, only robocopy, for always getting full details.

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
