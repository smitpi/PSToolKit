---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Set-ObjectOwnerShip

## SYNOPSIS
Reset the ownership of a folder, and add the specified user with full control.

## SYNTAX

```
Set-ObjectOwnerShip [-FolderPath] <DirectoryInfo[]> [-UserName] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Reset the ownership of a folder, and add the specified user with full control.

## EXAMPLES

### EXAMPLE 1
```
Set-ObjectOwnerShip -FolderPath c:\temp -UserName lab\james
```

## PARAMETERS

### -FolderPath
The folder to replace the permissions

```yaml
Type: DirectoryInfo[]
Parameter Sets: (All)
Aliases: Name

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserName
This user will be granted full control.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
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
