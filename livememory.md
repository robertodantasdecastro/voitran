# Live Memory

## Estado arquitetural recente
- `2026-03-07`: fundacao inicial do `Voitran` criada.
- padrao `MrQuentinha` adotado desde o primeiro commit.
- `backend/control-plane` definido em `Go`.
- shell `SwiftUI` do `VoitranMac` publicado como app de navegacao com estados mockados.
- `packages/realtime-core-swift` publicado com contratos iniciais.
- `2026-03-12`: repositorio dedicado publicado em `origin/main` e isolado do repo pai.
- `2026-03-12`: fase 1 do `Voice Lab` implementada com sidecar local, fluxo guiado de enrolment e preview por texto.
- `2026-03-12`: lifecycle do app e instalador macOS preparados para o lote local.
- `2026-03-12`: bundle instalado passou a embarcar scripts operacionais e foi validado em `/Applications`.
- `2026-03-12`: duracao das gravacoes do `Voice Lab` corrigida pela leitura do WAV final; payloads JSON de perfil foram alinhados com o sidecar.
- `2026-03-12`: modo debug do app ativado com log local; estado do `Voice Lab` passou a reconciliar perfis carregados no launch.
- `2026-03-12`: icone do `VoitranMac` passou a ser gerado e empacotado automaticamente no build do app.

## Foco ativo
- consolidar o runtime local de clonagem com `OpenVoice V2` no sidecar;
- validar captacao guiada, perfil vocal e preview local no `VoitranMac`;
- testar manualmente o `Voice Lab` no app ja instalado no macOS alvo;
- preservar higiene do Git em volume externo, evitando artefatos `AppleDouble`;
- preparar a evolucao da mesma base para `STT -> traducao -> TTS`.

## Riscos ativos
- runtime de voz ainda nao tem `OpenVoice V2` instalado; fallback atual usa `system-say` sem clonagem real;
- `control-plane` local permanece opcional nesta fase; lifecycle automatico cobre apenas dependencias reais do `Voice Lab`;
- backend ainda nao possui banco, auth ou emissao real de token;
- enforcement de qualidade do `Voice Lab` ainda usa heuristicas simples de energia e clipping.

## Proximo checkpoint
- instalar e validar `OpenVoice V2` no runtime externo;
- substituir o fallback de sintese por clonagem efetiva com voz do usuario;
- validar manualmente o fluxo guiado do `Voice Lab` no app instalado no macOS;
- iniciar benchmark de latencia e qualidade do `Voice Lab`.
