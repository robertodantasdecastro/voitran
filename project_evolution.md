# Evolucao do Projeto

## 2026-03-07 - Bootstrap da linha base do Voitran
- adotado o modelo estrutural, de memoria e governanca inspirado no `MrQuentinha`;
- definidos os artefatos vivos obrigatorios do projeto;
- fixada a stack inicial:
  - `SwiftUI` no `macOS`;
  - `Go` no backend/control-plane;
  - `runtime` externo em `/Volumes/SSDExterno/Voitran_runtime`;
- formalizado o `Voice Lab` como trilha de produto e governanca, nao como area informal de P&D;
- criada a timeline editavel de 90 dias e 12 meses.

## Fases de evolucao
### Fase 0 - Fundacao e governanca
- memoria viva;
- workflows;
- shell `macOS`;
- backend stubado;
- estrutura de release.

### Fase 1 - Base local do macOS
- captura de audio;
- `VAD`;
- `STT`;
- traducao local;
- `TTS`.

### Fase 2 - Sessao e dual-band
- backend;
- negociacao de capacidade;
- presenca;
- eventos;
- smoke de duas pontas.

### Fase 3 - Mobile nativo
- `iOS`;
- `Android`;
- degradacao por tier de dispositivo.
