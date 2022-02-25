---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Edit-HostsFile

## SYNOPSIS
Edit the hosts file

## SYNTAX

### Show (Default)
```
Edit-HostsFile [-ShowCurrent] [<CommonParameters>]
```

### Remove
```
Edit-HostsFile [-Remove] [-RemoveText <String>] [<CommonParameters>]
```

### Add
```
Edit-HostsFile [-Add] [-AddIP <String>] [-AddFQDN <String>] [-AddHost <String>] [<CommonParameters>]
```

### Notepad
```
Edit-HostsFile [-OpenInNotepad] [<CommonParameters>]
```

## DESCRIPTION
Edit the hosts file

## EXAMPLES

### EXAMPLE 1
```
Edit-HostsFile -Remove -RemoveText blah
```

## PARAMETERS

### -ShowCurrent
Show existing entries

```yaml
Type: SwitchParameter
Parameter Sets: Show
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Remove
Remove an entry

```yaml
Type: SwitchParameter
Parameter Sets: Remove
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoveText
What to remove, either ip fqdn or host

```yaml
Type: String
Parameter Sets: Remove
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Add
Add an entry

```yaml
Type: SwitchParameter
Parameter Sets: Add
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -AddIP
Ip to add.

```yaml
Type: String
Parameter Sets: Add
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AddFQDN
FQDN to add

```yaml
Type: String
Parameter Sets: Add
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AddHost
Host to add.

```yaml
Type: String
Parameter Sets: Add
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OpenInNotepad
Open the file in notepad.

```yaml
Type: SwitchParameter
Parameter Sets: Notepad
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
