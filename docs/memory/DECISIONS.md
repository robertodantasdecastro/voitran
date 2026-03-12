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
