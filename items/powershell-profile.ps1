# oh-my-posh init pwsh --config $ENV:POSH_THEMES_PATH\montys.omp.json | Invoke-Expression
# oh-my-posh init pwsh --config $ENV:POSH_THEMES_PATH\kushal.omp.json | Invoke-Expression
oh-my-posh init pwsh --config $ENV:POSH_THEMES_PATH\amro.omp.json | Invoke-Expression

Import-Module -Name CompletionPredictor
Import-Module -Name terminal-icons

# Commented out values are not used but kept for changing
$PSReadlineColors = @{
    Default            = "#C8D1DF"
    Comment            = "#4D5868"
    Keyword            = "#BA7BCC"
    String             = "#98C379"
    Operator           = "#BA7BCC"
    Variable           = "#88ABF9"
    Command            = "#53C6BA"
    Parameter          = "#C8D1DF"
    Type               = "#BA7BCC"
    Number             = "#E6A26F"
    Member             = "#E6A26F"
    ContinuationPrompt = "#4D5868"
    ListPrediction     = "#E6A26F"
    # Emphasis
    # Error
    # ListPredictionSelected
}

set-PSReadLineOption -PredictionViewStyle ListView -ContinuationPrompt "$([char]0x276F) " -Colors $PSReadlineColors

oh-my-posh completion powershell | Out-String | Invoke-Expression
