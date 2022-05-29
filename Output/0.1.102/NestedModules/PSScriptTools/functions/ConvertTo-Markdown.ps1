Function ConvertTo-Markdown {
    [cmdletbinding(DefaultParameterSetName = "text")]
    [outputtype([string[]])]
    [alias('ctm')]

    Param(
        [Parameter(Position = 0, ValueFromPipeline)]
        [object]$Inputobject,
        [Parameter()]
        [string]$Title,
        [string[]]$PreContent,
        [string[]]$PostContent,
        [Parameter(ParameterSetName = "text")]
        [ValidateScript({ $_ -ge 10 })]
        [int]$Width = 80,
        [Parameter(ParameterSetName = "table", HelpMessage = "Display results as a markdown table")]
        [alias("table")]
        [switch]$AsTable,
        [Parameter(ParameterSetName = "list", HelpMessage = "Display results as a 2 column markdown table.")]
        [alias("list")]
        [switch]$AsList
    )

    Begin {
        Write-Verbose "[BEGIN  ] Starting $($myinvocation.MyCommand)"
        #initialize a collection to hold incoming data
        $data = [System.Collections.Generic.list[object]]::new()
        #initialize a list for markdown text
        $text = [System.Collections.Generic.list[string]]::New()

        If ($title) {
            Write-Verbose "[BEGIN  ] Adding Title: $Title"
            $text.Add("# $Title`r`n")
        }
        If ($precontent) {
            Write-Verbose "[BEGIN  ] Adding Precontent"
            $text.Add("$precontent`r`n")
            #$text.Add("`n`n")
        }

        #set a flag for the Process block so that the Write-Verbose
        #statement only runs once
        $flag = $True
    } #begin
    Process {
        if ($flag) {
            Write-Verbose "[PROCESS] Adding processed object[s]"
            #turn off the flag so the verbose message only appears once
            $flag = $False
        }
        #add incoming objects to data array
        $data.Add($inputobject)
    } #process
    End {
        #add the data to the text
        if ($data.count -gt 0) {
            Switch ($pscmdlet.ParameterSetName) {
                "Table" {
                    Write-Verbose "[END    ] Formatting as a table"
                    $names = $data[0].psobject.Properties.name
                    $head = "| $($names -join " | ") |"
                    $text.Add($head)

                    $bars = "| $(($names -replace '.','-') -join " | ") |"

                    $text.Add($bars)

                    foreach ($item in $data) {
                        $line = "| "
                        $values = @()
                        for ($i = 0; $i -lt $names.count; $i++) {
                            #if an item value contains return and new line replace them with <br> Issue #97
                            if ($item.($names[$i]) -match "`n") {
                                Write-Verbose "[END    ] Replacing line returns for property $($names[$i])"
                                [string]$val = $($item.($names[$i])).replace("`r`n", "<br>") -join ""
                            }
                            else {
                                [string]$val = $item.($names[$i])
                            }
                            $values += $val
                        }
                        $line += $values -join " | "
                        $line += " |"
                        $text.Add($line)
                        Write-Verbose "[END    ] Appended: $line"
                    } #foreach item
                    $text.Add("")
                    Write-Verbose "[END    ] Finished building table"
                } #asTable
                "List" {
                    Write-Verbose "[END    ] Formatting as a list table"
                    $text.Add("|    |    |")
                    $text.Add("|----|----|")
                    foreach ($item in $data) {
                        $item.psobject.properties | ForEach-Object {
                            if ($_.value) {
                                $v = $_.value.toString()
                            }
                            else {
                                $v = $null
                            }
                            $line = "|$($_.name)|$v|"
                            Write-Verbose "[END    ] Appended: $line"
                            $text.Add($line)
                        }
                    }
                    $text.Add("")
                } #asList
                "Text" {
                    Write-Verbose "[END    ] Formatting as a text"
                    #convert data to strings and trim each line
                    Write-Verbose "[END    ] Converting data to strings"
                    [string]$trimmed = (($data | Out-String -Width $width).split("`n")).ForEach({ "$($_.trim())`n" })
                    Write-Verbose "[END    ] Adding to markdown"
                    $clean = $($trimmed.trimend())
                    $text.Add("``````text")
                    $text.Add($clean)
                    $text.Add("```````r`n")
                } #text
            } #switch
        } #if $data

        If ($postcontent) {
            Write-Verbose "[END    ] Adding postcontent"
            $text.Add("$postcontent`r`n")
        }

        #write the markdown to the pipeline
        Write-Verbose "[END    ] Writing final markdown to the pipeline"
        $text
        Write-Verbose "[END    ] Ending $($myinvocation.MyCommand)"
    } #end

} #close ConvertTo-Markdown