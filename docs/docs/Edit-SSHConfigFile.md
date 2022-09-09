---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
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

### Example 1: EXAMPLE 1

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

### -Add

Add a record.

```yaml
Type: SwitchParameter
Parameter Sets: add
Aliases: 
Accepted values: 

Required: True (None) False (add)
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -AddObject

Adds an entry from a already created object.

```yaml
Type: PSObject
Parameter Sets: addobject
Aliases: 
Accepted values: 

Required: True (None) False (addobject)
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -OpenInNotepad

Open the config file in notepad

```yaml
Type: SwitchParameter
Parameter Sets: notepad
Aliases: 
Accepted values: 

Required: True (None) False (notepad)
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Remove

Remove a record

```yaml
Type: SwitchParameter
Parameter Sets: remove
Aliases: 
Accepted values: 

Required: True (None) False (remove)
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -RemoveString

Looks for a record in host and hostname, and removes it.

```yaml
Type: String
Parameter Sets: removestring
Aliases: 
Accepted values: 

Required: True (None) False (removestring)
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Show

Show current records.

```yaml
Type: SwitchParameter
Parameter Sets: List
Aliases: 
Accepted values: 

Required: True (None) False (List)
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## OUTPUTS

### System.Object[]


## NOTES



## RELATED LINKS

Fill Related Links Here

