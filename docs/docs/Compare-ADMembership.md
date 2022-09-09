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
Compare-ADMembership [-DifferenceUser <String>] [-DomainCredential <PSCredential>] [-DomainFQDN <String>] [-Export <String>] [-ReferenceUser <String>] [-ReportPath <DirectoryInfo>] [<CommonParameters>]
```

### OtherDomain

```
Compare-ADMembership [-DifferenceUser <String>] [-DomainCredential <PSCredential>] [-DomainFQDN <String>] [-Export <String>] [-ReferenceUser <String>] [-ReportPath <DirectoryInfo>] [<CommonParameters>]
```

## DESCRIPTION

Compare two users AD group memberships


## EXAMPLES

### Example 1: EXAMPLE 1

```
$compare = Compare-ADMembership -ReferenceUser ps -DifferenceUser ctxuser1
```








## PARAMETERS

### -DifferenceUser

Second user name

```yaml
Type: String
Parameter Sets: (All), OtherDomain, CurrentDomain
Aliases: 
Accepted values: 

Required: True (All) False (OtherDomain, CurrentDomain)
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -DomainCredential

Userid to connect to that domain.

```yaml
Type: PSCredential
Parameter Sets: (All), OtherDomain
Aliases: 
Accepted values: 

Required: True (None) False (All, OtherDomain)
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
Parameter Sets: (All), OtherDomain
Aliases: 
Accepted values: 

Required: True (None) False (All, OtherDomain)
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Export

Export the result to a report file.
(Excel or html)

```yaml
Type: String
Parameter Sets: OtherDomain, CurrentDomain
Aliases: 
Accepted values: 

Required: True (None) False (OtherDomain, CurrentDomain)
Position: Named
Default value: Host
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ReferenceUser

First user name.

```yaml
Type: String
Parameter Sets: (All), OtherDomain, CurrentDomain
Aliases: 
Accepted values: 

Required: True (All) False (OtherDomain, CurrentDomain)
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ReportPath

Where to save the report.

```yaml
Type: DirectoryInfo
Parameter Sets: OtherDomain, CurrentDomain
Aliases: 
Accepted values: 

Required: True (None) False (OtherDomain, CurrentDomain)
Position: Named
Default value: C:\Temp
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

