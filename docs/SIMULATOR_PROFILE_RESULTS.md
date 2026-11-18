# Quest 3 e Quest Pro — 16 novembre 2026

Progetto 0.5.2, Godot 4.7.2, Mobile/Vulkan, Meta XR Simulator 207.1, macOS ARM64. Due sessioni OpenXR distinte, riavviando dopo il cambio profilo. Identità confermate da `get_system_info()`: **Meta Quest 3** e **Meta Quest Pro**.

| Controllo | Quest 3 | Quest Pro |
|---|---|---|
| Loading, scena e scheda laterale osservati nel frontend | OK | OK |
| Due mani fornite dal runtime | OK | OK |
| Recenter effettivo con articolazioni allineate | OK | OK |
| Presa/rilascio e ritorno in orbita, Terra e compagni | Test scriptato OK | Test scriptato OK |
| Zoom, scheda spostabile e bersagli dei pulsanti | Test scriptato OK | Test scriptato OK |
| Presa del Sole, spostamento sistema e anteprima | Test scriptato OK | Test scriptato OK |

I test scriptati usano sorgenti di presa separate, senza sostituire i tracker delle mani del runtime. Entrambi i log contengono `XR_PROFILE_RECENTER_HANDS_PASS count=2` e `XR_PROFILE_CHECKS_COMPLETE`, senza `SCRIPT ERROR`.

**Limiti:** pinch/selezione manuale dal mouse del frontend non confermati. L'osservatore non ha registrato selezioni/prese durante i tentativi mouse/tastiera su Quest 3. I test scriptati non dimostrano quindi l'intero percorso gestuale del frontend. Il valore 72 fps nella UI è una configurazione, non una misura prestazionale.

Questa prova esegue il progetto OpenXR nativo sul Mac, non l'APK Android. Tracking ottico, comfort, pausa/ripresa reali e FPS richiedono hardware fisico. Restano i messaggi noti del runtime/plugin su color space e teardown.

Evidenze: `logs/xr-quest3-profile-console.log`, `logs/xr-questpro-profile-console.log`, `builds/android/simulator-profile-results.json`.

Ripetizione: scegliere il profilo mentre un'app è connessa, arrestarla e avviare `bash scripts/run-xr-simulator.sh --quit-after 1000 --script scripts/test-xr-profile.gd`. Il runner chiude l'esperienza alla fine; `--interactive` la lascia aperta per l'osservazione. `--smoke-test` usa invece tracker sintetici e non va confuso con questa verifica.

Fonte sul cambio profilo e riavvio: [guida ufficiale Meta](https://developers.meta.com/vr/documentation/native/xrsim-getting-started/).
