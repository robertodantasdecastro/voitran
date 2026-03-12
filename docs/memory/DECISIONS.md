# Decisions - Voitran

## 2026-03-07 - Adocao do padrao de memoria e continuidade do MrQuentinha
- Decisao:
  - adotar a mesma espinha dorsal de memoria viva, workflows e regras de sincronizacao;
  - tornar `WF_NovoProjeto` o ponto de entrada do projeto;
  - manter compatibilidade de paths para `Antigravity IDE`.
- Motivo:
  - reduzir perda de contexto entre ciclos e agentes;
  - padronizar continuidade operacional desde o primeiro commit.

## 2026-03-07 - Repositorio dedicado dentro do workspace maior
- Decisao:
  - inicializar um `.git` proprio dentro de `/Volumes/SSDExterno/Desenvolvimento/iatools/voitran`;
  - usar `main` como branch base;
  - configurar `origin` em `git@github.com:robertodantasdecastro/voitran.git`.
- Motivo:
  - manter identidade e historico isolados do workspace pai;
  - permitir governanca propria do produto.

## 2026-03-07 - Backend/control-plane em Go
- Decisao:
  - usar `Go` como base do backend.
- Motivo:
  - priorizar velocidade operacional, concorrencia previsivel e baixa latencia.

## 2026-03-07 - App inicial em SwiftUI no macOS
- Decisao:
  - iniciar pelo `macOS` em `SwiftUI`.
- Motivo:
  - melhor caminho para `Apple Silicon`, audio local e integracao com frameworks do ecossistema Apple.

## 2026-03-07 - Topologia local-first
- Decisao:
  - manter `STT`, traducao e `TTS` localmente nas pontas como baseline do produto.
- Motivo:
  - reduzir latencia percebida, custo operacional e dependencia de backend pesado.

## 2026-03-07 - Voz clonada como feature central com consentimento obrigatorio
- Decisao:
  - tratar identidade vocal e clonagem como area central do produto;
  - exigir consentimento explicito e rastreavel desde o inicio.
- Motivo:
  - alinhar arquitetura, produto e risco desde a fundacao.

## 2026-03-12 - Publicacao efetiva do Git dedicado do Voitran
- Decisao:
  - efetivar o `.git` proprio na raiz de `/Volumes/SSDExterno/Desenvolvimento/iatools/voitran`;
  - publicar o bootstrap em `origin/main`;
  - ignorar artefatos `AppleDouble` `._*` no repo para reduzir ruido operacional em volume externo.
- Motivo:
  - remover dependencia acidental do repo pai `peticionei`;
  - garantir identidade de historico e fluxo de entrega do `Voitran`;
  - reduzir falhas e ruido de Git causados por metadados do macOS no SSD externo.

## 2026-03-12 - Sidecar local de voz em Python controlado pelo app macOS
- Decisao:
  - integrar a fase 1 de voz local por sidecar `Python` com CLI JSON, controlado pelo `VoitranMac`;
  - manter `OpenVoice V2` como engine alvo;
  - operar com fallback local de `system-say` enquanto o runtime do `OpenVoice V2` nao estiver instalado.
- Motivo:
  - acelerar a entrega da UX e do contrato do `Voice Lab` sem bloquear o app por empacotamento pesado;
  - preservar o caminho de evolucao para clonagem local real e futura pipeline de traducao;
  - manter o runtime pesado fora do workspace versionado.

## 2026-03-12 - Lifecycle do app controla dependencias reais da fase atual
- Decisao:
  - iniciar automaticamente no launch apenas `Voice Runtime` e `Voice Sidecar CLI`, que sao dependencias reais do `Voice Lab`;
  - manter o `control-plane` como servico opcional e gerenciavel pela interface, sem subir automaticamente nesta fase;
  - empacotar o app em bundle `.app` e pacote `.pkg` por scripts do repositorio.
- Motivo:
  - alinhar lifecycle automatico com o escopo real da fase local de voz;
  - evitar falhas de abertura do app por dependencias ainda nao necessarias ao fluxo atual;
  - deixar a aplicacao pronta para instalacao e teste local imediato.
