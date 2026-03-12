# Backend Realtime

## Objetivo
Definir a linha base do `backend/control-plane`.

## Responsabilidades
- criar e gerenciar sessoes;
- emitir tokens e metadados de capacidade;
- registrar eventos operacionais;
- expor `health` e `capabilities`;
- manter o backend fora do caminho de audio pesado por padrao.

## Endpoints iniciais
- `GET /health`
- `GET /v1/capabilities`
- `POST /v1/sessions`
- `POST /v1/sessions/{id}/token`
- `POST /v1/sessions/{id}/events`

## Principios
- baixa latencia operacional;
- concorrencia previsivel;
- configuracao deterministica por ambiente;
- segredos fora do repo.
