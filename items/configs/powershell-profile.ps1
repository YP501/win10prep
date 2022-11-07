oh-my-posh init pwsh --config $ENV:POSH_THEMES_PATH\amro.omp.json | Invoke-Expression

Import-Module -Name PSReadline
set-PSReadLineOption -PredictionViewStyle ListView
set-PSReadLineOption -PredictionSource History

Import-Module -Name Terminal-Icons
Import-Module -Name z

oh-my-posh completion powershell | Out-String | Invoke-Expression