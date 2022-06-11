---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: https://smitpi.github.io/PSToolKit/Install-LocalPSRepository
schema: 2.0.0
---

# New-RemoteDesktopFile

## SYNOPSIS
Creates and saves a .rdp file

## SYNTAX

```
New-RemoteDesktopFile [-ComputerName] <String[]> [[-Path] <DirectoryInfo>] [[-UserName] <String>]
 [[-DomainName] <String>] [-Force] [<CommonParameters>]
```

## DESCRIPTION
Creates and saves a .rdp file

## EXAMPLES

### EXAMPLE 1
```
New-RemoteDesktopFile
```

### EXAMPLE 2
```
New-RemoteDesktopFile -ComputerName $rr -Path C:\temp -UserName $user -DomainName lab -Force
```

## PARAMETERS

### -ComputerName
Name or ip of the server to connect to.

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

### -Path
Where the .rdp file will be saved.

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: C:\Temp
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserName
ID to be used to connect.

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

### -DomainName
Domain for the userid (Use localhost if the device is not on a domain).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Override an existing .rdp file.

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

### System.Object[]
## NOTES

## RELATED LINKS
