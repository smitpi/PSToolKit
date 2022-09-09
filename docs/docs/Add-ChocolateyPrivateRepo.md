---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# Add-ChocolateyPrivateRepo

## SYNOPSIS

Add a private repository to Chocolatey.

## SYNTAX

### __AllParameterSets

```
Add-ChocolateyPrivateRepo [-RepoName] <String> [-RepoURL] <String> [-Priority] <Int32> [[-RepoApiKey <String>]] [-DisableCommunityRepo] [<CommonParameters>]
```

## DESCRIPTION

Add a private repository to Chocolatey.


## EXAMPLES

### Example 1: EXAMPLE 1

```
Add-ChocolateyPrivateRepo -RepoName XXX -RepoURL https://choco.xxx.lab/chocolatey -Priority 3
```








## PARAMETERS

### -DisableCommunityRepo

Disable the community repo, and will only use the private one.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Priority

Priority of server, 1 being the highest.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (All) False (None)
Position: 2
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -RepoApiKey

API key to allow uploads to the server.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 3
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -RepoName

Name of the repo

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (All) False (None)
Position: 0
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -RepoURL

URL of the repo

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (All) False (None)
Position: 1
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## NOTES



## RELATED LINKS

Fill Related Links Here

