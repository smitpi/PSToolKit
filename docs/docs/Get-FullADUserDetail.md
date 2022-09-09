---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# Get-FullADUserDetail

## SYNOPSIS

Extract user details from the domain

## SYNTAX

### CurrentDomain (Default)

```
Get-FullADUserDetail [-UserToQuery <String[]>] [<CommonParameters>]
```

### OtherDomain

```
Get-FullADUserDetail [-DomainCredential <PSCredential>] [-DomainFQDN <String>] [-UserToQuery <String[]>] [<CommonParameters>]
```

## DESCRIPTION

Extract user details from the domain


## EXAMPLES

### Example 1: EXAMPLE 1

```
Get-FullADUserDetail -UserToQuery ps
```








## PARAMETERS

### -DomainCredential

Userid to connect to that domain.

```yaml
Type: PSCredential
Parameter Sets: OtherDomain
Aliases: 
Accepted values: 

Required: True (None) False (OtherDomain)
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -DomainFQDN

Domain to search

```yaml
Type: String
Parameter Sets: OtherDomain
Aliases: 
Accepted values: 

Required: True (None) False (OtherDomain)
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -UserToQuery

User id to search for.

```yaml
Type: String[]
Parameter Sets: (All), OtherDomain, CurrentDomain
Aliases: Name,UserName,Identity
Accepted values: 

Required: True (All) False (OtherDomain, CurrentDomain)
Position: Named
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

