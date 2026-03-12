# Governanca de Voz

## Regra central
Nenhuma identidade vocal entra em uso sem `ConsentManifest`.

## Campos obrigatorios do consentimento
- `voice_identity_id`
- `owner`
- `source`
- `scope`
- `expires_at`
- `approved_locales`
- `hash`
- `revocation_policy`

## Regras
- nenhuma amostra real e versionada;
- nenhuma amostra real vai para memoria viva;
- `Voice Lab` e trilha governada do produto, nao sandbox informal;
- liberacao para producao exige benchmark, qualidade minima e aprovacao de risco.
