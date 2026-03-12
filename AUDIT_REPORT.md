# Audit Report

## Estado inicial
O projeto acabou de nascer. Nao ha divida tecnica herdada de codigo, mas ha riscos de arquitetura, operacao e governanca que ja precisam ser rastreados.

## Riscos iniciais
1. `Voice cloning` como recurso central aumenta risco tecnico, juridico e de abuso.
2. A maior latencia percebida pelo usuario nao estara no backend HTTP, e sim no pipeline `audio -> STT -> traducao -> TTS -> transporte`.
3. Android provavelmente exigira degradacao por tier de hardware desde o inicio.
4. A definicao do par de idiomas inicial precisa ficar restrita a `PT-BR <-> EN` para manter escopo controlado.

## Acoes mandatórias
- manter consentimento e ownership de identidade vocal desde o design;
- medir latencia por etapa, nao apenas latencia total;
- evitar dependencia unica de um fornecedor ou framework de inferencia;
- manter segredos e amostras reais fora do repositorio.
