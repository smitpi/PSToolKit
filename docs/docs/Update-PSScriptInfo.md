---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Update-PSScriptInfo

## SYNOPSIS
Update PowerShell ScriptFileInfo

## SYNTAX

```
Update-PSScriptInfo [-FullName] <FileInfo> [[-Author] <String>] [[-Description] <String>] [[-tag] <String[]>]
 [-MinorUpdate] [-ChangesMade] <String> [<CommonParameters>]
```

## DESCRIPTION
Update PowerShell ScriptFileInfo

## EXAMPLES

### EXAMPLE 1
```
Update-PSScriptInfo -FullName .\PSToolKit\Public\Start-ClientPSProfile.ps1 -ChangesMade "blah"
```

## PARAMETERS

### -FullName
FullName of the script

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

### -Author
Who wrote it

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -tag
Tags for searching

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: Ps
Accept pipeline input: False
Accept wildcard characters: False
```

### -MinorUpdate
Minor version increase

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

### -ChangesMade
What has changed.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: (Read-Host 'Changes Made ')
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Collections.Hashtable
## NOTES

## RELATED LINKS
