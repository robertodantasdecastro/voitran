# Changelog - Voitran

## 2026-03-12
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
