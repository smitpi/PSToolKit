---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Compare-ADMembership

## SYNOPSIS
Compare two users AD group memberships

## SYNTAX

### CurrentDomain (Default)
```
Compare-ADMembership [-ReferenceUser <String>] [-DifferenceUser <String>] [-DomainFQDN <String>]
 [-DomainCredential <PSCredential>] [<CommonParameters>]
```

### OtherDomain
```
Compare-ADMembership [-ReferenceUser <String>] [-DifferenceUser <String>] [-DomainFQDN <String>]
 [-DomainCredential <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION
Compare two users AD group memberships

## EXAMPLES

### EXAMPLE 1
```
Compare-ADMembership -Export HTML -ReportPath C:\temp
```

## PARAMETERS

### -ReferenceUser
{{ Fill ReferenceUser Description }}

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

### -DifferenceUser
{{ Fill DifferenceUser Description }}

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
{{ Fill DomainFQDN Description }}

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
{{ Fill DomainCredential Description }}

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

### System.Object[]
## NOTES

## RELATED LINKS
