oh-my-posh init pwsh --config $ENV:POSH_THEMES_PATH\amro.omp.json | Invoke-Expression

Import-Module -Name PSReadline
Import-Module -Name CompletionPredictor
Import-Module -Name Terminal-Icons
Import-Module -Name z

set-PSReadLineOption -PredictionViewStyle ListView
set-PSReadLineOption -PredictionSource HistoryAndPlugin

oh-my-posh completion powershell | Out-String | Invoke-Expression