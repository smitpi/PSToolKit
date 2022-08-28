---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: https://smitpi.github.io/PSToolKit/Edit-HostsFile
schema: 2.0.0
---

# Edit-SSHConfigFile

## SYNOPSIS
Creates and modifies the ssh config file in their profile.

## SYNTAX

### List (Default)
```
Edit-SSHConfigFile [-Show] [<CommonParameters>]
```

### remove
```
Edit-SSHConfigFile [-Remove] [<CommonParameters>]
```

### removestring
```
Edit-SSHConfigFile [-RemoveString <String>] [<CommonParameters>]
```

### add
```
Edit-SSHConfigFile [-Add] [<CommonParameters>]
```

### addobject
```
Edit-SSHConfigFile [-AddObject <PSObject>] [<CommonParameters>]
```

### notepad
```
Edit-SSHConfigFile [-OpenInNotepad] [<CommonParameters>]
```

## DESCRIPTION
Creates and modifies the ssh config file in their profile.

## EXAMPLES

### EXAMPLE 1
```
$rr = [PSCustomObject]@{
```

Host         = 'esx00'
	HostName     = '192.168.10.19'
	User         = 'root'
	Port         = '22'
	IdentityFile = 'C:\Users\xx\.ssh\yyy.id'
}
Edit-SSHConfigFile -AddObject $rr

## PARAMETERS

### -Show
Show current records.

```yaml
Type: SwitchParameter
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Remove
Remove a record

```yaml
Type: SwitchParameter
Parameter Sets: remove
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoveString
Looks for a record in host and hostname, and removes it.

```yaml
Type: String
Parameter Sets: removestring
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Add
Add a record.

```yaml
Type: SwitchParameter
Parameter Sets: add
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -AddObject
Adds an entry from a already created object.

```yaml
Type: PSObject
Parameter Sets: addobject
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OpenInNotepad
Open the config file in notepad

```yaml
Type: SwitchParameter
Parameter Sets: notepad
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
