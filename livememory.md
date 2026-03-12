# Live Memory

## Estado arquitetural recente
- `2026-03-07`: fundacao inicial do `Voitran` criada.
- padrao `MrQuentinha` adotado desde o primeiro commit.
- `backend/control-plane` definido em `Go`.
- shell `SwiftUI` do `VoitranMac` publicado como app de navegacao com estados mockados.
- `packages/realtime-core-swift` publicado com contratos iniciais.
- `2026-03-12`: repositorio dedicado publicado em `origin/main` e isolado do repo pai.

## Foco ativo
- iniciar `Etapa 1A`: captura de audio, `VAD`, `STT` local e benchmark;
- preservar higiene do Git em volume externo, evitando artefatos `AppleDouble`;
- validar a primeira trilha de trabalho de produto no `macOS`.

## Riscos ativos
- app `SwiftUI` inicial ainda e shell sem audio real;
- backend ainda nao possui banco, auth ou emissao real de token;
- policy de voz clonada ainda nao tem enforcement de runtime, apenas contrato documental.

## Proximo checkpoint
- abrir o primeiro ciclo de implementacao da `Etapa 1A`;
- definir o recorte inicial de captura de audio e integracao com `WhisperKit`.
