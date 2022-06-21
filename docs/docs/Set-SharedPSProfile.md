---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Set-SharedPSProfile

## SYNOPSIS
Redirects PowerShell and WindowsPowerShell profile folder to another path.

## SYNTAX

### Current (Default)
```
Set-SharedPSProfile [-CurrentUser] [-PathToSharedProfile <DirectoryInfo>] [<CommonParameters>]
```

### Other
```
Set-SharedPSProfile [-OtherUser] [-OtherUserName <String>] [-PathToSharedProfile <DirectoryInfo>]
 [<CommonParameters>]
```

## DESCRIPTION
Redirects PowerShell and WindowsPowerShell profile folder to another path.

## EXAMPLES

### EXAMPLE 1
```
Set-SharedPSProfile -CurrentUser -PathToSharedProfile "\\nas01\profile"
```

## PARAMETERS

### -CurrentUser
Will change the currently logged on user's folders.

```yaml
Type: SwitchParameter
Parameter Sets: Current
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -OtherUser
Will change another user's folders.

```yaml
Type: SwitchParameter
Parameter Sets: Other
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -OtherUserName
The username of the other user.

```yaml
Type: String
Parameter Sets: Other
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PathToSharedProfile
Path to new folder.
Folders PowerShell and WindowsPowerShell will be created if it doesn't exists.

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
General notes

## RELATED LINKS
