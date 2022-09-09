---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# Update-PSDefaultParameter

## SYNOPSIS

Updates the $PSDefaultParameterValues variable

## SYNTAX

### Set1 (Default)

```
Update-PSDefaultParameter [[-Function <String>]] [[-Parameter <String>]] [[-value <String>]] [-WriteToProfile] [<CommonParameters>]
```

## DESCRIPTION

Updates the $PSDefaultParameterValues variable, and saves it to your profile.


## EXAMPLES

### Example 1: EXAMPLE 1

```
Update-PSDefaultParameter -Function Connect-VMWareCluster -Parameter vCenterIp -value '192.168.x.x' -WriteToProfile
```








## PARAMETERS

### -Function

The function name to add, you can also add wildcards.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 0
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Parameter

The Parameter in that function to add.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 1
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -value

Value of the parameter

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 2
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -WriteToProfile

Also write the result to your profile.

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


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## OUTPUTS

### System.Object[]


## NOTES



## RELATED LINKS

Fill Related Links Here

