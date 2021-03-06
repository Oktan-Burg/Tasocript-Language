Clear-Host
$variables   = [System.Collections.ArrayList]::new()
if ((Get-Content .\status.log)[0] -eq '0') {
    Write-Host @"
###############################################
### Setup Process Starting...               ###
###############################################
"@ -ForegroundColor Yellow
    Start-Sleep -S 2
    #Invoke-Command -ScriptBlock ([scriptblock]::Create((Get-Content ".\rescources\entry\setup.dll")))
    #-replace "`r`n", "`n"
    "1" | Out-File -FilePath .\status.log
    $username = Read-Host -Prompt "username" | Out-File -FilePath .\userdata.data
    
    Clear-Host
}

if ((Get-Content .\status.log)[0] -eq '1') {
    Write-Host @"
###############################################
###         Command Process Starting        ###
###############################################
"@ -ForegroundColor Yellow
    Start-Sleep -S 2
    Clear-Host
    if ($args[0]) {
        try {
            try {
                $data       = (Get-Content $args[0])
                
                foreach ($line in $data) {
                    if (($line -split " ")[0] -eq "write") {
                        if (($line -split '"')[2]) {
                            $data = (($line -split '"')[2] -split " ")
                            $text = ([regex]::Matches($line, '".*?"').Value -replace '"')
                            $Global:final = ([regex]::Matches($line, '".*?"').Value -replace '"')
                            $Global:color = "White" 
                            foreach ($arg in $data) {
                                if ((($arg -split ' ')[0]).StartsWith("%")) {
                                    $name = (($arg -split ' ')[0] -replace "%",'')
                                    foreach ($var in $variables) {
                                        if (($var -split "/\")[0] -eq $name) {
                                            $value = ($var -split "/\")[1]
                                        }
                                    }
                                    $Global:final = ($text -replace "{$($name)}",$value)
                                }
                                if ((($arg -split ' ')[0]).StartsWith("FG-")) {
                                    if (($arg -split "-")[1]) {
                                        foreach ($color in [Enum]::GetValues([System.ConsoleColor])) {
                                            if ($arg.ToLower() -eq $color.ToLower()) {
                                                $Global:color = "$arg" 
                                            }
                                        }
                                    }
                                }
                            }
                            Write-Host "$Global:final" -ForegroundColor $Global:color
                        } else {
                            Write-Host ([regex]::Matches($line, '".*?"').Value -replace '"')
                        }
                    }
                    if (($line -split " ")[0] -eq "local") {
                        if (($line -split " ")[1]) {
                            $vName  = ($line -split " ")[1]
                            if (($line -split " ")[2]) {
                                $vValue  = ($line -split " ")[2]
                            } else {
                                Write-Host "<:> Error, variable value must be provided." -ForegroundColor DarkRed; exit 500;
                            }
                            try {
                                $variables.Add("$vName/\$vValue")
                            } catch {
                                Write-Host "<:> Error, variable already exists. Try: reset $vName (optional)$vValue" -ForegroundColor DarkRed; exit 500;
                            }
                        } else {
                            Write-Host "<:> Error, variable name must be provided." -ForegroundColor DarkRed; exit 500;
                        }
                    }
                    if (($line -Split " ")[0] -eq "clear") {
                        Clear-Host;
                        if (($shell -Split " ")[1..1] -eq "-echo") {
                            Write-Host "0" -ForegroundColor Blue;
                        };
                    };
                
                    if (($line -Split " ")[0] -eq "echo") {
                        Write-Host $($line -replace '(.*?)echo (.*)', '$2')
                    };
                    if (($line -Split " ")[0] -eq "wait") {
                        if (($line -Split " ")[1]) {
                            try {
                                [int]$time = ($line -Split " ")[1]
                            } catch {
                                Write-Host "<:> Time must only contain numbers" -ForegroundColor DarkRed
                            }
                            Start-Sleep -S $time
                            if (($line -Split " ")[2] -eq "-echo") {
                                Write-Host "<::> Sleep Complete" -ForegroundColor Blue
                            }
                        } else { Write-Host "<:> A duration must be provided" -ForegroundColor DarkRed; exit 500}
                    };

                }                
            } catch {
                Write-Host "<:> We can only process Taso Script Files." -ForegroundColor DarkRed
            }

        } catch {
            Write-Host "<:> Script File does not exist" -ForegroundColor DarkRed
        }
    } else {
        Invoke-Command -ScriptBlock ([scriptblock]::Create((Get-Content ".\rescources\home.dll")))
    }
    Start-Sleep -s 3
    Write-Host "<::> Script Job Completed." -ForegroundColor DarkRed
    exit 500
}
