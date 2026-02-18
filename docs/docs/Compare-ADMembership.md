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
 [-DomainCredential <PSCredential>] [-Export <String>] [-ReportPath <DirectoryInfo>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### OtherDomain
```
Compare-ADMembership [-ReferenceUser <String>] [-DifferenceUser <String>] [-DomainFQDN <String>]
 [-DomainCredential <PSCredential>] [-Export <String>] [-ReportPath <DirectoryInfo>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Compare two users AD group memberships

## EXAMPLES

### EXAMPLE 1
```
$compare = Compare-ADMembership -ReferenceUser ps -DifferenceUser ctxuser1
```

## PARAMETERS

### -ReferenceUser
First user name.

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
Second user name

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

### -Export
Export the result to a report file.
(Excel or html)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Host
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReportPath
Where to save the report.

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: C:\Temp
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

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
