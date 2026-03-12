# Live Memory

## Estado arquitetural recente
- `2026-03-07`: fundacao inicial do `Voitran` criada.
- padrao `MrQuentinha` adotado desde o primeiro commit.
- `backend/control-plane` definido em `Go`.
- shell `SwiftUI` do `VoitranMac` publicado como app de navegacao com estados mockados.
- `packages/realtime-core-swift` publicado com contratos iniciais.

## Foco ativo
- bootstrap do repositorio e governanca;
- validacao estrutural de `macOS + backend`;
- preparacao para `Etapa 1A`: captura de audio, `VAD`, `STT` local e benchmark.

## Riscos ativos
- app `SwiftUI` inicial ainda e shell sem audio real;
- backend ainda nao possui banco, auth ou emissao real de token;
- policy de voz clonada ainda nao tem enforcement de runtime, apenas contrato documental.

## Proximo checkpoint
- publicar repo inicial em `main`;
- iniciar implementacao de `Etapa 1A`.
