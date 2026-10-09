# Limpeza semanal automática do Mole (agendada no Agendador de Tarefas: "Mole - Limpeza semanal")
# Log de cada execução: C:\Users\Bruno\.config\mole\auto-clean.log
# Teste sem apagar nada: powershell -File auto-clean.ps1 -DryRun
param([switch]$DryRun)

$log = Join-Path $PSScriptRoot 'auto-clean.log'
$ansi = "$([char]27)\[[0-9;]*[a-zA-Z]"
$mode = if ($DryRun) { ' (simulacao)' } else { '' }
"===== $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')$mode =====" | Out-File -FilePath $log -Append -Encoding utf8

$cleanArgs = @('clean')
if ($DryRun) { $cleanArgs += '--dry-run' }
& 'C:\Users\Bruno\Mole\mole.ps1' @cleanArgs *>&1 |
    Where-Object { $_ -isnot [hashtable] } |
    ForEach-Object { ($_ | Out-String).TrimEnd() -replace $ansi, '' } |
    Out-File -FilePath $log -Append -Encoding utf8
