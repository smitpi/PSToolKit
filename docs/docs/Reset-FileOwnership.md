---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Reset-FileOwnership

## SYNOPSIS
Reset the ownership of a directory and add full control to the folder.

## SYNTAX

```
Reset-FileOwnership [-Path] <DirectoryInfo[]> [[-Credentials] <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION
Reset the ownership of a directory and add full control to the folder.

## EXAMPLES

### EXAMPLE 1
```
Reset-FileOwnership -Path C:\temp -Credentials $Admin
```

## PARAMETERS

### -Path
Path to the folder to reset ownership.

```yaml
Type: DirectoryInfo[]
Parameter Sets: (All)
Aliases: Directory

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Credentials
The account to grant full control.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: (Get-Credential -Message 'User to be given access')
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object[]
## NOTES

## RELATED LINKS
