@{
    AliasesToExport      = @('EmailHTML', 'Add-JavaScript', 'New-JavaScript', 'Add-JS', 'Add-CSS', 'ConvertTo-CSS', 'CalendarEvent', 'ChartCategory', 'ChartAxisX', 'New-ChartCategory', 'ChartAxisY', 'ChartBar', 'ChartBarOptions', 'New-ChartFill', 'ChartDonut', 'ChartGrid', 'ChartLegend', 'ChartLine', 'ChartPie', 'ChartRadial', 'ChartSpark', 'ChartTheme', 'ChartTimeLine', 'ChartToolbar', 'DiagramEdge', 'DiagramEdges', 'New-DiagramEdge', 'DiagramLink', 'DiagramNode', 'DiagramOptionsInteraction', 'DiagramOptionsLayout', 'DiagramOptionsEdges', 'New-DiagramOptionsEdges', 'DiagramOptionsLinks', 'DiagramOptionsManipulation', 'DiagramOptionsNodes', 'DiagramOptionsPhysics', 'HierarchicalTreeNode', 'Dashboard', 'New-HTMLLink', 'Calendar', 'Chart', 'Container', 'Diagram', 'New-Diagram', 'Footer', 'Header', 'Image', 'EmailImage', 'EmailList', 'Main', 'New-HTMLColumn', 'Panel', 'New-HTMLPanelOption', 'New-PanelOption', 'PanelOption', 'New-PanelStyle', 'PanelStyle', 'New-HTMLContent', 'Section', 'New-HTMLSectionOptions', 'SectionOption', 'New-HTMLSectionOption', 'Tab', 'Table', 'EmailTable', 'New-TableOption', 'TableOption', 'EmailTableOption', 'EmailTableStyle', 'TableStyle', 'New-TableStyle', 'TabOptions', 'New-TabOption', 'New-HTMLTabOptions', 'TabOption', 'New-HTMLTabOption', 'TabStyle', 'HTMLText', 'Text', 'EmailText', 'EmailTextBox', 'New-HTMLNavItem', 'New-HTMLNavLink', 'New-HTMLNavTopMenu', 'TableAlphabetSearch', 'New-HTMLTableAlphabetSearch', 'TableButtonCopy', 'EmailTableButtonCopy', 'New-HTMLTableButtonCopy', 'TableButtonCSV', 'EmailTableButtonCSV', 'New-HTMLTableButtonCSV', 'TableButtonExcel', 'EmailTableButtonExcel', 'New-HTMLTableButtonExcel', 'TableButtonPageLength', 'EmailTableButtonPageLength', 'New-HTMLTableButtonPageLength', 'TableButtonPDF', 'EmailTableButtonPDF', 'New-HTMLTableButtonPDF', 'TableButtonPrint', 'EmailTableButtonPrint', 'New-HTMLTableButtonPrint', 'TableButtonSearchBuilder', 'EmailTableButtonSearchBuilder', 'New-HTMLTableButtonSearchBuilder', 'EmailTableColumnOption', 'TableColumnOption', 'New-HTMLTableColumnOption', 'EmailTableCondition', 'TableConditionalFormatting', 'New-HTMLTableCondition', 'TableCondition', 'EmailTableConditionGroup', 'TableConditionGroup', 'New-HTMLTableConditionGroup', 'TableContent', 'EmailTableContent', 'New-HTMLTableContent', 'TableHeader', 'EmailTableHeader', 'New-HTMLTableHeader', 'TablePercentageBar', 'New-HTMLTablePercentageBar', 'TableReplace', 'EmailTableReplace', 'New-HTMLTableReplace', 'TableRowGrouping', 'EmailTableRowGrouping', 'New-HTMLTableRowGrouping', 'Out-GridHtml', 'ohv')
    Author               = 'Przemyslaw Klys'
    CmdletsToExport      = @()
    CompanyName          = 'Evotec'
    CompatiblePSEditions = @('Desktop', 'Core')
    Copyright            = '(c) 2011 - 2022 Przemyslaw Klys @ Evotec. All rights reserved.'
    Description          = 'PSWriteHTML is PowerShell Module to generate beautiful HTML reports, pages, emails without any knowledge of HTML, CSS or JavaScript. To get started basics PowerShell knowledge is required.'
    FunctionsToExport    = @('Add-HTML', 'Add-HTMLScript', 'Add-HTMLStyle', 'ConvertTo-CascadingStyleSheets', 'Email', 'EmailAttachment', 'EmailBCC', 'EmailBody', 'EmailCC', 'EmailFrom', 'EmailHeader', 'EmailLayout', 'EmailLayoutColumn', 'EmailLayoutRow', 'EmailListItem', 'EmailOptions', 'EmailReplyTo', 'EmailServer', 'EmailSubject', 'EmailTo', 'Enable-HTMLFeature', 'New-AccordionItem', 'New-CalendarEvent', 'New-CarouselSlide', 'New-ChartAxisX', 'New-ChartAxisY', 'New-ChartBar', 'New-ChartBarOptions', 'New-ChartDataLabel', 'New-ChartDesign', 'New-ChartDonut', 'New-ChartEvent', 'New-ChartGrid', 'New-ChartLegend', 'New-ChartLine', 'New-ChartMarker', 'New-ChartPie', 'New-ChartRadial', 'New-ChartRadialOptions', 'New-ChartSpark', 'New-ChartTheme', 'New-ChartTimeLine', 'New-ChartToolbar', 'New-ChartToolTip', 'New-DiagramEvent', 'New-DiagramLink', 'New-DiagramNode', 'New-DiagramOptionsInteraction', 'New-DiagramOptionsLayout', 'New-DiagramOptionsLinks', 'New-DiagramOptionsManipulation', 'New-DiagramOptionsNodes', 'New-DiagramOptionsPhysics', 'New-GageSector', 'New-HierarchicalTreeNode', 'New-HTML', 'New-HTMLAccordion', 'New-HTMLAnchor', 'New-HTMLCalendar', 'New-HTMLCarousel', 'New-HTMLCarouselStyle', 'New-HTMLChart', 'New-HTMLCodeBlock', 'New-HTMLContainer', 'New-HTMLDiagram', 'New-HTMLFontIcon', 'New-HTMLFooter', 'New-HTMLFrame', 'New-HTMLGage', 'New-HTMLHeader', 'New-HTMLHeading', 'New-HTMLHierarchicalTree', 'New-HTMLHorizontalLine', 'New-HTMLImage', 'New-HTMLList', 'New-HTMLListItem', 'New-HTMLLogo', 'New-HTMLMain', 'New-HTMLMap', 'New-HTMLNav', 'New-HTMLNavFloat', 'New-HTMLNavTop', 'New-HTMLOrgChart', 'New-HTMLPage', 'New-HTMLPanel', 'New-HTMLPanelStyle', 'New-HTMLQRCode', 'New-HTMLSection', 'New-HTMLSectionScrolling', 'New-HTMLSectionScrollingItem', 'New-HTMLSectionStyle', 'New-HTMLSpanStyle', 'New-HTMLStatus', 'New-HTMLStatusItem', 'New-HTMLSummary', 'New-HTMLSummaryItem', 'New-HTMLSummaryItemData', 'New-HTMLTab', 'New-HTMLTable', 'New-HTMLTableOption', 'New-HTMLTableStyle', 'New-HTMLTabPanel', 'New-HTMLTabStyle', 'New-HTMLTag', 'New-HTMLText', 'New-HTMLTextBox', 'New-HTMLTimeline', 'New-HTMLTimelineItem', 'New-HTMLToast', 'New-HTMLTree', 'New-HTMLWinBox', 'New-HTMLWizard', 'New-HTMLWizardStep', 'New-NavFloatWidget', 'New-NavFloatWidgetItem', 'New-NavItem', 'New-NavLink', 'New-NavTopMenu', 'New-OrgChartNode', 'New-TableAlphabetSearch', 'New-TableButtonCopy', 'New-TableButtonCSV', 'New-TableButtonExcel', 'New-TableButtonPageLength', 'New-TableButtonPDF', 'New-TableButtonPrint', 'New-TableButtonSearchBuilder', 'New-TableColumnOption', 'New-TableCondition', 'New-TableConditionGroup', 'New-TableContent', 'New-TableEvent', 'New-TableHeader', 'New-TableLanguage', 'New-TablePercentageBar', 'New-TableReplace', 'New-TableRowGrouping', 'New-TreeNode', 'Out-HtmlView', 'Save-HTML')
    GUID                 = 'a7bdf640-f5cb-4acf-9de0-365b322d245c'
    ModuleVersion        = '0.0.174'
    PowerShellVersion    = '5.1'
    PrivateData          = @{
        PSData = @{
            Tags       = @('HTML', 'WWW', 'JavaScript', 'CSS', 'Reports', 'Reporting', 'Windows', 'MacOS', 'Linux')
            ProjectUri = 'https://github.com/EvotecIT/PSWriteHTML'
            IconUri    = 'https://evotec.xyz/wp-content/uploads/2018/12/PSWriteHTML.png'
        }
    }
    RootModule           = 'PSWriteHTML.psm1'
    ScriptsToProcess     = @()
}
# SIG # Begin signature block
# MIIhjgYJKoZIhvcNAQcCoIIhfzCCIXsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUY54y+idzgCe55t/i4kTzfr50
# MnmgghusMIIDtzCCAp+gAwIBAgIQDOfg5RfYRv6P5WD8G/AwOTANBgkqhkiG9w0B
# AQUFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVk
# IElEIFJvb3QgQ0EwHhcNMDYxMTEwMDAwMDAwWhcNMzExMTEwMDAwMDAwWjBlMQsw
# CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cu
# ZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3Qg
# Q0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCtDhXO5EOAXLGH87dg
# +XESpa7cJpSIqvTO9SA5KFhgDPiA2qkVlTJhPLWxKISKityfCgyDF3qPkKyK53lT
# XDGEKvYPmDI2dsze3Tyoou9q+yHyUmHfnyDXH+Kx2f4YZNISW1/5WBg1vEfNoTb5
# a3/UsDg+wRvDjDPZ2C8Y/igPs6eD1sNuRMBhNZYW/lmci3Zt1/GiSw0r/wty2p5g
# 0I6QNcZ4VYcgoc/lbQrISXwxmDNsIumH0DJaoroTghHtORedmTpyoeb6pNnVFzF1
# roV9Iq4/AUaG9ih5yLHa5FcXxH4cDrC0kqZWs72yl+2qp/C3xag/lRbQ/6GW6whf
# GHdPAgMBAAGjYzBhMA4GA1UdDwEB/wQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB0G
# A1UdDgQWBBRF66Kv9JLLgjEtUYunpyGd823IDzAfBgNVHSMEGDAWgBRF66Kv9JLL
# gjEtUYunpyGd823IDzANBgkqhkiG9w0BAQUFAAOCAQEAog683+Lt8ONyc3pklL/3
# cmbYMuRCdWKuh+vy1dneVrOfzM4UKLkNl2BcEkxY5NM9g0lFWJc1aRqoR+pWxnmr
# EthngYTffwk8lOa4JiwgvT2zKIn3X/8i4peEH+ll74fg38FnSbNd67IJKusm7Xi+
# fT8r87cmNW1fiQG2SVufAQWbqz0lwcy2f8Lxb4bG+mRo64EtlOtCt/qMHt1i8b5Q
# Z7dsvfPxH2sMNgcWfzd8qVttevESRmCD1ycEvkvOl77DZypoEd+A5wwzZr8TDRRu
# 838fYxAe+o0bJW1sj6W3YQGx0qMmoRBxna3iw/nDmVG3KwcIzi7mULKn+gpFL6Lw
# 8jCCBTAwggQYoAMCAQICEAQJGBtf1btmdVNDtW+VUAgwDQYJKoZIhvcNAQELBQAw
# ZTELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQ
# d3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBS
# b290IENBMB4XDTEzMTAyMjEyMDAwMFoXDTI4MTAyMjEyMDAwMFowcjELMAkGA1UE
# BhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2lj
# ZXJ0LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIENvZGUg
# U2lnbmluZyBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAPjTsxx/
# DhGvZ3cH0wsxSRnP0PtFmbE620T1f+Wondsy13Hqdp0FLreP+pJDwKX5idQ3Gde2
# qvCchqXYJawOeSg6funRZ9PG+yknx9N7I5TkkSOWkHeC+aGEI2YSVDNQdLEoJrsk
# acLCUvIUZ4qJRdQtoaPpiCwgla4cSocI3wz14k1gGL6qxLKucDFmM3E+rHCiq85/
# 6XzLkqHlOzEcz+ryCuRXu0q16XTmK/5sy350OTYNkO/ktU6kqepqCquE86xnTrXE
# 94zRICUj6whkPlKWwfIPEvTFjg/BougsUfdzvL2FsWKDc0GCB+Q4i2pzINAPZHM8
# np+mM6n9Gd8lk9ECAwEAAaOCAc0wggHJMBIGA1UdEwEB/wQIMAYBAf8CAQAwDgYD
# VR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUFBwMDMHkGCCsGAQUFBwEBBG0w
# azAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUF
# BzAChjdodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVk
# SURSb290Q0EuY3J0MIGBBgNVHR8EejB4MDqgOKA2hjRodHRwOi8vY3JsNC5kaWdp
# Y2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMDqgOKA2hjRodHRw
# Oi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3Js
# ME8GA1UdIARIMEYwOAYKYIZIAYb9bAACBDAqMCgGCCsGAQUFBwIBFhxodHRwczov
# L3d3dy5kaWdpY2VydC5jb20vQ1BTMAoGCGCGSAGG/WwDMB0GA1UdDgQWBBRaxLl7
# KgqjpepxA8Bg+S32ZXUOWDAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823I
# DzANBgkqhkiG9w0BAQsFAAOCAQEAPuwNWiSz8yLRFcgsfCUpdqgdXRwtOhrE7zBh
# 134LYP3DPQ/Er4v97yrfIFU3sOH20ZJ1D1G0bqWOWuJeJIFOEKTuP3GOYw4TS63X
# X0R58zYUBor3nEZOXP+QsRsHDpEV+7qvtVHCjSSuJMbHJyqhKSgaOnEoAjwukaPA
# JRHinBRHoXpoaK+bp1wgXNlxsQyPu6j4xRJon89Ay0BEpRPw5mQMJQhCMrI2iiQC
# /i9yfhzXSUWW6Fkd6fp0ZGuy62ZD2rOwjNXpDd32ASDOmTFjPQgaGLOBm0/GkxAG
# /AeB+ova+YJJ92JuoVP6EpQYhS6SkepobEQysmah5xikmmRR7zCCBT0wggQloAMC
# AQICEATV3B9I6snYUgC6zZqbKqcwDQYJKoZIhvcNAQELBQAwcjELMAkGA1UEBhMC
# VVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0
# LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIENvZGUgU2ln
# bmluZyBDQTAeFw0yMDA2MjYwMDAwMDBaFw0yMzA3MDcxMjAwMDBaMHoxCzAJBgNV
# BAYTAlBMMRIwEAYDVQQIDAnFmmzEhXNraWUxETAPBgNVBAcTCEthdG93aWNlMSEw
# HwYDVQQKDBhQcnplbXlzxYJhdyBLxYJ5cyBFVk9URUMxITAfBgNVBAMMGFByemVt
# eXPFgmF3IEvFgnlzIEVWT1RFQzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
# ggEBAL+ygd4sga4ZC1G2xXvasYSijwWKgwapZ69wLaWaZZIlY6YvXTGQnIUnk+Tg
# 7EoT7mQiMSaeSPOrn/Im6N74tkvRfQJXxY1cnt3U8//U5grhh/CULdd6M3/Z4h3n
# MCq7LQ1YVaa4MYub9F8WOdXO84DANoNVG/t7YotL4vzqZil3S9pHjaidp3kOXGJc
# vxrCPAkRFBKvUmYo23QPFa0Rd0qA3bFhn97WWczup1p90y2CkOf28OVOOObv1fNE
# EqMpLMx0Yr04/h+LPAAYn6K4YtIu+m3gOhGuNc3B+MybgKePAeFIY4EQzbqvCMy1
# iuHZb6q6ggRyqrJ6xegZga7/gV0CAwEAAaOCAcUwggHBMB8GA1UdIwQYMBaAFFrE
# uXsqCqOl6nEDwGD5LfZldQ5YMB0GA1UdDgQWBBQYsTUn6BxQICZOCZA0CxS0TZSU
# ZjAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwdwYDVR0fBHAw
# bjA1oDOgMYYvaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL3NoYTItYXNzdXJlZC1j
# cy1nMS5jcmwwNaAzoDGGL2h0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9zaGEyLWFz
# c3VyZWQtY3MtZzEuY3JsMEwGA1UdIARFMEMwNwYJYIZIAYb9bAMBMCowKAYIKwYB
# BQUHAgEWHGh0dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwCAYGZ4EMAQQBMIGE
# BggrBgEFBQcBAQR4MHYwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0
# LmNvbTBOBggrBgEFBQcwAoZCaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0Rp
# Z2lDZXJ0U0hBMkFzc3VyZWRJRENvZGVTaWduaW5nQ0EuY3J0MAwGA1UdEwEB/wQC
# MAAwDQYJKoZIhvcNAQELBQADggEBAJq9bM+JbCwEYuMBtXoNAfH1SRaMLXnLe0py
# VK6el0Z1BtPxiNcF4iyHqMNVD4iOrgzLEVzx1Bf/sYycPEnyG8Gr2tnl7u1KGSjY
# enX4LIXCZqNEDQCeTyMstNv931421ERByDa0wrz1Wz5lepMeCqXeyiawqOxA9fB/
# 106liR12vL2tzGC62yXrV6WhD6W+s5PpfEY/chuIwVUYXp1AVFI9wi2lg0gaTgP/
# rMfP1wfVvaKWH2Bm/tU5mwpIVIO0wd4A+qOhEia3vn3J2Zz1QDxEprLcLE9e3Gmd
# G5+8xEypTR23NavhJvZMgY2kEXBEKEEDaXs0LoPbn6hMcepR2A4wggauMIIElqAD
# AgECAhAHNje3JFR82Ees/ShmKl5bMA0GCSqGSIb3DQEBCwUAMGIxCzAJBgNVBAYT
# AlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2Vy
# dC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDAeFw0yMjAz
# MjMwMDAwMDBaFw0zNzAzMjIyMzU5NTlaMGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQK
# Ew5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBS
# U0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0EwggIiMA0GCSqGSIb3DQEBAQUA
# A4ICDwAwggIKAoICAQDGhjUGSbPBPXJJUVXHJQPE8pE3qZdRodbSg9GeTKJtoLDM
# g/la9hGhRBVCX6SI82j6ffOciQt/nR+eDzMfUBMLJnOWbfhXqAJ9/UO0hNoR8XOx
# s+4rgISKIhjf69o9xBd/qxkrPkLcZ47qUT3w1lbU5ygt69OxtXXnHwZljZQp09ns
# ad/ZkIdGAHvbREGJ3HxqV3rwN3mfXazL6IRktFLydkf3YYMZ3V+0VAshaG43IbtA
# rF+y3kp9zvU5EmfvDqVjbOSmxR3NNg1c1eYbqMFkdECnwHLFuk4fsbVYTXn+149z
# k6wsOeKlSNbwsDETqVcplicu9Yemj052FVUmcJgmf6AaRyBD40NjgHt1biclkJg6
# OBGz9vae5jtb7IHeIhTZgirHkr+g3uM+onP65x9abJTyUpURK1h0QCirc0PO30qh
# HGs4xSnzyqqWc0Jon7ZGs506o9UD4L/wojzKQtwYSH8UNM/STKvvmz3+DrhkKvp1
# KCRB7UK/BZxmSVJQ9FHzNklNiyDSLFc1eSuo80VgvCONWPfcYd6T/jnA+bIwpUzX
# 6ZhKWD7TA4j+s4/TXkt2ElGTyYwMO1uKIqjBJgj5FBASA31fI7tk42PgpuE+9sJ0
# sj8eCXbsq11GdeJgo1gJASgADoRU7s7pXcheMBK9Rp6103a50g5rmQzSM7TNsQID
# AQABo4IBXTCCAVkwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQUuhbZbU2F
# L3MpdpovdYxqII+eyG8wHwYDVR0jBBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08w
# DgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUFBwMIMHcGCCsGAQUFBwEB
# BGswaTAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsG
# AQUFBzAChjVodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVz
# dGVkUm9vdEc0LmNydDBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdp
# Y2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNybDAgBgNVHSAEGTAXMAgG
# BmeBDAEEAjALBglghkgBhv1sBwEwDQYJKoZIhvcNAQELBQADggIBAH1ZjsCTtm+Y
# qUQiAX5m1tghQuGwGC4QTRPPMFPOvxj7x1Bd4ksp+3CKDaopafxpwc8dB+k+YMjY
# C+VcW9dth/qEICU0MWfNthKWb8RQTGIdDAiCqBa9qVbPFXONASIlzpVpP0d3+3J0
# FNf/q0+KLHqrhc1DX+1gtqpPkWaeLJ7giqzl/Yy8ZCaHbJK9nXzQcAp876i8dU+6
# WvepELJd6f8oVInw1YpxdmXazPByoyP6wCeCRK6ZJxurJB4mwbfeKuv2nrF5mYGj
# VoarCkXJ38SNoOeY+/umnXKvxMfBwWpx2cYTgAnEtp/Nh4cku0+jSbl3ZpHxcpzp
# SwJSpzd+k1OsOx0ISQ+UzTl63f8lY5knLD0/a6fxZsNBzU+2QJshIUDQtxMkzdwd
# eDrknq3lNHGS1yZr5Dhzq6YBT70/O3itTK37xJV77QpfMzmHQXh6OOmc4d0j/R0o
# 08f56PGYX/sr2H7yRp11LB4nLCbbbxV7HhmLNriT1ObyF5lZynDwN7+YAN8gFk8n
# +2BnFqFmut1VwDophrCYoCvtlUG3OtUVmDG0YgkPCr2B2RP+v6TR81fZvAT6gt4y
# 3wSJ8ADNXcL50CN/AAvkdgIm2fBldkKmKYcJRyvmfxqkhQ/8mJb2VVQrH4D6wPIO
# K+XW+6kvRBVK5xMOHds3OBqhK/bt1nz8MIIGxjCCBK6gAwIBAgIQCnpKiJ7JmUKQ
# BmM4TYaXnTANBgkqhkiG9w0BAQsFADBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMO
# RGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNB
# NDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENBMB4XDTIyMDMyOTAwMDAwMFoXDTMz
# MDMxNDIzNTk1OVowTDELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJ
# bmMuMSQwIgYDVQQDExtEaWdpQ2VydCBUaW1lc3RhbXAgMjAyMiAtIDIwggIiMA0G
# CSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC5KpYjply8X9ZJ8BWCGPQz7sxcbOPg
# JS7SMeQ8QK77q8TjeF1+XDbq9SWNQ6OB6zhj+TyIad480jBRDTEHukZu6aNLSOiJ
# QX8Nstb5hPGYPgu/CoQScWyhYiYB087DbP2sO37cKhypvTDGFtjavOuy8YPRn80J
# xblBakVCI0Fa+GDTZSw+fl69lqfw/LH09CjPQnkfO8eTB2ho5UQ0Ul8PUN7UWSxE
# dMAyRxlb4pguj9DKP//GZ888k5VOhOl2GJiZERTFKwygM9tNJIXogpThLwPuf4UC
# yYbh1RgUtwRF8+A4vaK9enGY7BXn/S7s0psAiqwdjTuAaP7QWZgmzuDtrn8oLsKe
# 4AtLyAjRMruD+iM82f/SjLv3QyPf58NaBWJ+cCzlK7I9Y+rIroEga0OJyH5fsBrd
# Gb2fdEEKr7mOCdN0oS+wVHbBkE+U7IZh/9sRL5IDMM4wt4sPXUSzQx0jUM2R1y+d
# +/zNscGnxA7E70A+GToC1DGpaaBJ+XXhm+ho5GoMj+vksSF7hmdYfn8f6CvkFLIW
# 1oGhytowkGvub3XAsDYmsgg7/72+f2wTGN/GbaR5Sa2Lf2GHBWj31HDjQpXonrub
# S7LitkE956+nGijJrWGwoEEYGU7tR5thle0+C2Fa6j56mJJRzT/JROeAiylCcvd5
# st2E6ifu/n16awIDAQABo4IBizCCAYcwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB
# /wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwIAYDVR0gBBkwFzAIBgZngQwB
# BAIwCwYJYIZIAYb9bAcBMB8GA1UdIwQYMBaAFLoW2W1NhS9zKXaaL3WMaiCPnshv
# MB0GA1UdDgQWBBSNZLeJIf5WWESEYafqbxw2j92vDTBaBgNVHR8EUzBRME+gTaBL
# hklodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRSU0E0
# MDk2U0hBMjU2VGltZVN0YW1waW5nQ0EuY3JsMIGQBggrBgEFBQcBAQSBgzCBgDAk
# BggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMFgGCCsGAQUFBzAC
# hkxodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRS
# U0E0MDk2U0hBMjU2VGltZVN0YW1waW5nQ0EuY3J0MA0GCSqGSIb3DQEBCwUAA4IC
# AQANLSN0ptH1+OpLmT8B5PYM5K8WndmzjJeCKZxDbwEtqzi1cBG/hBmLP13lhk++
# kzreKjlaOU7YhFmlvBuYquhs79FIaRk4W8+JOR1wcNlO3yMibNXf9lnLocLqTHbK
# odyhK5a4m1WpGmt90fUCCU+C1qVziMSYgN/uSZW3s8zFp+4O4e8eOIqf7xHJMUpY
# tt84fMv6XPfkU79uCnx+196Y1SlliQ+inMBl9AEiZcfqXnSmWzWSUHz0F6aHZE8+
# RokWYyBry/J70DXjSnBIqbbnHWC9BCIVJXAGcqlEO2lHEdPu6cegPk8QuTA25POq
# aQmoi35komWUEftuMvH1uzitzcCTEdUyeEpLNypM81zctoXAu3AwVXjWmP5UbX9x
# qUgaeN1Gdy4besAzivhKKIwSqHPPLfnTI/KeGeANlCig69saUaCVgo4oa6TOnXbe
# qXOqSGpZQ65f6vgPBkKd3wZolv4qoHRbY2beayy4eKpNcG3wLPEHFX41tOa1DKKZ
# pdcVazUOhdbgLMzgDCS4fFILHpl878jIxYxYaa+rPeHPzH0VrhS/inHfypex2Efq
# HIXgRU4SHBQpWMxv03/LvsEOSm8gnK7ZczJZCOctkqEaEf4ymKZdK5fgi9OczG21
# Da5HYzhHF1tvE9pqEG4fSbdEW7QICodaWQR2EaGndwITHDGCBUwwggVIAgEBMIGG
# MHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsT
# EHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJl
# ZCBJRCBDb2RlIFNpZ25pbmcgQ0ECEATV3B9I6snYUgC6zZqbKqcwCQYFKw4DAhoF
# AKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcN
# AQkEMRYEFHJlEk1TyBje3mpBp79xvr6XIHuPMA0GCSqGSIb3DQEBAQUABIIBABiC
# 0mCtOcSnSWC0AoFY+LIhyfHtdUo7xyL7kdHrURIAE40cXlt+NjjRPwyYaP2g2IU3
# XNWOg89ZmlEkMizE6GlV/VgEhNlCCHxjtdxPI2yqI1GG01w42BAZ5FVhhYs0eAVL
# 0j6iIXYG5U4TlSQbsHF+jmnGSE6hdSBKiNv2xlIgtOftOFsixomJtoHq84RfREch
# R7puj0a7JBqfH8d7HyWw4H2/h6XWGAWZe1wNd0TH5W/CXRm/9Sck9JYoIm1Lvuvg
# JOQjIvX716K9FQWFvDit8WCPi0lbI/GNeeC6S2KraG0l5eiMlcRy4l0oI0i316yn
# xZRTDV9n8it9tPdU0gahggMgMIIDHAYJKoZIhvcNAQkGMYIDDTCCAwkCAQEwdzBj
# MQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMT
# MkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5n
# IENBAhAKekqInsmZQpAGYzhNhpedMA0GCWCGSAFlAwQCAQUAoGkwGAYJKoZIhvcN
# AQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjIwNTIwMDY1NzUyWjAv
# BgkqhkiG9w0BCQQxIgQgOnXcQ4nUL+7DvK99MPhggiWErFgb0MGcpbrx1gtK+M0w
# DQYJKoZIhvcNAQEBBQAEggIAEnK3kj5eZo3s+J/OmWyV+3HPsdb1F4EOSye9wHVO
# tpoHLazW9ZaHUCFNskJDPMMIvHVoSN5gxrEpQd7rFM8+5eLfY8dPaU8dr8y9xui+
# O2SJn9RLrrcG7093SbeYgrGEBbTd4zjhhGxuG9NKIPyybTU2eBCu42Z53OAK1UGW
# NPlSFDBqgffDwtM9Oxc2+Grn+NI83w4K56YVcAu6sZjho0sMYjFnpQJQVcyIz7FV
# 9FD7c3ffhs3X3aBefljLS5tTJ9WCacjqUrKWa73jLnwIdMtcwQcBzDzTBwmm7kQz
# qo3p00lpVN5Ztm+4J/J/3Omixj5xO3Mi41Bb+YXDsCKAPdwrlBND0hKmnZxTCGPC
# T6GS2OlU3cVrO5bMK29Vr6MwSe12AxKZBhirfKt8NEJ5XpwBD5/wxp8CC/ogQhnx
# tthImrvluN4djLGtv2Jmy9i9P6hYz50JPQYS8RKJ16vXzTwfB3WkvdeKSgLpiGRk
# ApV3t181FWBQI/IbHqw3qxu8iupQ/+81l9Nsf0DIF4kt3A3VWLHBmXddCeulKbEc
# gr1OLcMLeMHg6Kvd1b3rhpl2wOrd+NyrxwpgWTiIGVx89uLvZiGRmYP6QQCzLD/n
# LYIF3rj2jyGwSYVySHHpXYl8D5x9u8YQit6HPNLsCpIt0TkV3qhOVOvWxncYup4v
# NDk=
# SIG # End signature block
