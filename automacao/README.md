# Limpeza automática semanal (configuração pessoal)

Configuração usada neste PC para rodar o `mo clean` sozinho toda semana, a partir da branch `windows` deste fork.

## O que está configurado

| Item | Onde fica | Para que serve |
|---|---|---|
| Instalação do Mole | `C:\Users\Bruno\Mole` (este repositório, branch `windows`) | Comandos `mo` / `mole` no PATH do usuário |
| Script da limpeza | `C:\Users\Bruno\.config\mole\auto-clean.ps1` (cópia: [auto-clean.ps1](auto-clean.ps1)) | Roda `mo clean` e grava o resultado no log |
| Lista de proteção | `C:\Users\Bruno\.config\mole\whitelist.txt` (cópia: [whitelist.txt](whitelist.txt)) | Impede a limpeza do cache de shaders da NVIDIA (~3 GB), para os jogos não engasgarem depois |
| Log | `C:\Users\Bruno\.config\mole\auto-clean.log` | Uma entrada por execução |
| Tarefa agendada | Agendador de Tarefas → "Mole - Limpeza semanal" | Domingo às 12h; se o PC estiver desligado, roda quando ligar; limite de 1 hora |

O que a limpeza apaga, aproximadamente 1 GB por semana: temporários com mais de 7 dias, relatórios de erro, caches de navegadores (Edge, Brave), Discord, VS Code, cache de suplementos do Office e logs antigos. Não pede confirmação e não precisa de administrador.

## Como refazer em outro PC (ou depois de formatar)

Rode no PowerShell, ajustando o caminho se o usuário não for `Bruno`:

```powershell
# 1. Clonar o fork na branch windows e instalar
git clone --branch windows https://github.com/bruno8131374/Mole.git $env:USERPROFILE\Mole
cd $env:USERPROFILE\Mole
git remote add upstream https://github.com/tw93/Mole.git
powershell -ExecutionPolicy Bypass -File .\install.ps1 -InstallDir $env:USERPROFILE\Mole -AddToPath

# 2. Copiar script e lista de proteção
New-Item -ItemType Directory -Force $env:USERPROFILE\.config\mole | Out-Null
Copy-Item .\automacao\auto-clean.ps1, .\automacao\whitelist.txt $env:USERPROFILE\.config\mole\

# 3. Criar a tarefa semanal
$action   = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$env:USERPROFILE\.config\mole\auto-clean.ps1`""
$trigger  = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 12:00
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Hours 1)
Register-ScheduledTask -TaskName 'Mole - Limpeza semanal' -Action $action -Trigger $trigger -Settings $settings
```

O script e a lista de proteção têm o caminho `C:\Users\Bruno` escrito direto no arquivo; em outro usuário, edite esses caminhos.

## Uso no dia a dia

```powershell
mo clean --dry-run                    # mostra o que seria apagado, sem apagar
mo clean                              # limpa agora
powershell -File $env:USERPROFILE\.config\mole\auto-clean.ps1 -DryRun   # testa o script agendado sem apagar
Start-ScheduledTask 'Mole - Limpeza semanal'                            # roda a tarefa agora (apaga de verdade)
Unregister-ScheduledTask 'Mole - Limpeza semanal' -Confirm:$false       # desliga a limpeza automática
```

## Atualizar a partir do projeto original

O `mo update` puxa deste fork, não do `tw93/Mole`. Para trazer as novidades do autor:

```powershell
cd $env:USERPROFILE\Mole
git pull upstream windows
git push origin windows
```

## Observações

- A versão Windows do Mole é experimental, segundo o próprio autor.
- `mo status` e `mo analyze` usam executáveis baixados da internet e podem ser bloqueados pelo Controle Inteligente de Aplicativos do Windows. A limpeza não depende deles.
