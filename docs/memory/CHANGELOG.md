# Changelog - Voitran

## 2026-03-12
- `Voice Lab` passou a reconciliar o estado com perfis ja existentes, evitando tela presa em `consent-required` quando um perfil local ativo ja foi carregado;
- modo debug do app macOS ativado com logs locais em `/Volumes/SSDExterno/Voitran_runtime/logs/app/voitran-macos.log`;
- `Diagnostics` e `Settings` passaram a expor o estado do debug e o tail dos logs para apoiar investigacao local;
- `Voice Lab` passou a medir a duracao das gravacoes pelo arquivo WAV final, corrigindo amostras que apareciam como `0,0s` na UI;
- contratos JSON de voz foram alinhados em `snake_case` para o sidecar, corrigindo erros como `voice_profile_id e obrigatorio` em sintese e revogacao;
- bundle instalado do `VoitranMac` passou a embarcar scripts operacionais em `Contents/Resources/scripts`;
- resolucao de paths do app macOS foi ajustada para priorizar recursos do bundle quando executado fora do repo;
- `install_voitran_macos.sh` e `package_voitran_macos.sh` passaram a usar `ditto` para copiar o `.app` com consistencia;
- `bootstrap_voice_runtime.sh` passou a reutilizar o `venv` local quando `requirements` nao mudam;
- instalacao em `/Applications/VoitranMac.app` validada com sucesso e os scripts do bundle responderam a `health` e `status-all`;
- ciclo de vida do app instalado foi validado: launch inicia o bootstrap local e quit encerra o app sem deixar processo residual;
- lifecycle do `VoitranMac` passou a iniciar dependencias no launch e encerrar servicos gerenciados no quit;
- painel de configuracao e gerenciamento de servicos dependentes adicionado ao app;
- scripts de gerenciamento de servicos, build do `.app`, empacotamento `.pkg` e instalacao local do macOS adicionados;
- bundle `VoitranMac.app` e pacote `VoitranMac.pkg` gerados com sucesso em `dist/`;
- `VoitranMac` evoluido de shell para fluxo guiado de `Voice Lab` com consentimento, captura local, build de perfil e sintese de preview;
- contratos de voz local adicionados ao `realtime-core-swift`;
- sidecar local em `Python` com CLI JSON criado para `health`, `enroll`, `list-profiles`, `inspect-profile`, `revoke-profile` e `synthesize`;
- bootstrap do runtime de voz e wrappers operacionais adicionados em `scripts/`;
- smoke test do sidecar validado com `enroll` e `synthesize` locais;
- fallback atual de sintese usa `system-say` quando `OpenVoice V2` nao esta instalado no runtime.
- repositorio Git dedicado do `Voitran` inicializado na raiz do projeto;
- `origin` configurado em `git@github.com:robertodantasdecastro/voitran.git`;
- branch `main` publicada com commit inicial de bootstrap;
- isolamento operacional em relacao ao workspace pai validado;
- `.gitignore` endurecido para ignorar artefatos `AppleDouble` `._*`.

## 2026-03-07
- bootstrap do repositorio criado;
- fundacao documental, governanca e memoria viva publicadas;
- workflow oficial `WF_NovoProjeto` definido;
- backend/control-plane em `Go` stubado;
- shell `SwiftUI` do `VoitranMac` publicado;
- placeholders `iOS` e `Android` criados.
