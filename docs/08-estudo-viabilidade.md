# Estudo de Viabilidade do Voitran

## Conclusao executiva
O produto e tecnicamente viavel. Ja existem referencias de mercado e blocos tecnicos maduros para traducao de voz em tempo real, tanto `on-device` quanto com coordenacao por backend.

## Referencias de produto
- Apple ja documenta `Live Translation` em `Messages`, `Phone` e `FaceTime`, executando `entirely on device`.
- Google anunciou traducao de fala no `Meet` e capacidades de `speech-to-speech` no `Google Translate`.
- Mozilla distribui traducao offline/local no `Firefox`.

## Referencias tecnicas
- `WhisperKit`: referencia forte para `STT` local em `Apple Silicon`.
- `whisper.cpp`: referencia de portabilidade e fallback, inclusive para Android via `NDK`.
- `TranslateGemma`: referencia para traducao local orientada a edge.
- `Seamless Communication`: referencia de benchmark, nao backbone inicial.
- `TTSKit`: base de sintese local em `Apple`.
- `coqui-ai-TTS`: referencia de laboratorio para clonagem/vozes.
- `LiveKit`: referencia de transporte e sinalizacao para sessao dual-band.

## Decisoes de viabilidade
- MVP limitado a `PT-BR <-> EN`.
- `macOS` em `Apple Silicon` e a primeira plataforma alvo.
- backend em `Go` prioriza operacao de baixa latencia.
- voz clonada e parte central do produto, mas sob governanca obrigatoria.

## Riscos principais
- custo de latencia de cada etapa da pipeline;
- abuso ou uso indevido de voz clonada;
- heterogeneidade de hardware no Android;
- custo de memoria e aquecimento em dispositivos moveis.

## Links de referencia
- [Apple Live Translation no Mac](https://support.apple.com/lv-lv/guide/mac-help/mchl58dfbdba/mac)
- [Apple Live Translation no iPhone](https://support.apple.com/en-afri/123720)
- [Google Meet translated speech](https://workspace.google.com/blog/product-announcements/new-ways-to-do-your-best-work)
- [Google Translate speech-to-speech beta](https://blog.google/products-and-platforms/products/search/gemini-capabilities-translation-upgrades/)
- [Mozilla Firefox offline translation](https://blog.mozilla.org/en/firefox/cjk-translation-on-android/)
- [WhisperKit](https://github.com/argmaxinc/WhisperKit)
- [whisper.cpp](https://github.com/ggml-org/whisper.cpp)
- [Seamless Communication](https://github.com/facebookresearch/seamless_communication)
- [TranslateGemma](https://blog.google/innovation-and-ai/technology/developers-tools/translategemma/)
- [LiveKit](https://docs.livekit.io/frontends/start/frontends/)
- [coqui-ai-TTS](https://github.com/idiap/coqui-ai-TTS)
