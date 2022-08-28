---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: https://smitpi.github.io/PSToolKit/Edit-HostsFile
schema: 2.0.0
---

# Install-ChocolateyServer

## SYNOPSIS
This will download, install and setup a new Chocolatey Repo Server

## SYNTAX

```
Install-ChocolateyServer [-SiteName] <String> [-AppPoolName] <String> [-SitePath] <String> [[-APIKey] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
This will download, install and setup a new Chocolatey Repo Server

## EXAMPLES

### EXAMPLE 1
```
Install-ChocolateyServer -SiteName blah -AppPoolName blah -SitePath c:\temp\blah -APIKey 123456789
```

## PARAMETERS

### -SiteName
Name of the new repo

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AppPoolName
Pool name in IIS

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

### -SitePath
Path where packages will be saved.

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

### -APIKey
Change the default api to this key.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
