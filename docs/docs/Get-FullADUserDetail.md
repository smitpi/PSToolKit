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
Get-FullADUserDetail [-UserToQuery <String>] [-DomainFQDN <String>] [-DomainCredential <PSCredential>]
 [<CommonParameters>]
```

### OtherDomain
```
Get-FullADUserDetail [-UserToQuery <String>] [-DomainFQDN <String>] [-DomainCredential <PSCredential>]
 [<CommonParameters>]
```

## DESCRIPTION
Extract user details from the domain

## EXAMPLES

### EXAMPLE 1
```
Get-FullADUserDetail -UserToQuery ps
```

## PARAMETERS

### -UserToQuery
User id to search for.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DomainFQDN
Domain to search

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DomainCredential
Userid to connect to that domain.

```yaml
Type: PSCredential
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

## RELATED LINKS
