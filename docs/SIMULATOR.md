# Meta XR Simulator sul Mac

La modalità desktop del progetto e il simulatore XR sono due percorsi distinti. La prima permette di controllare scena e schede con il mouse; il simulatore esegue il percorso OpenXR con testa e mani simulate. Nessuno dei due certifica le prestazioni o il tracking ottico sul Quest reale.

## Configurazione prevista

- Mac Apple Silicon (arm64).
- Godot nella cartella `tools/Godot.app` sul SSD.
- Meta XR Simulator per Mac ARM 207.1 nella cartella `tools/meta-xr-simulator` sul SSD.
- Rendering Mobile/Vulkan durante la simulazione. Il renderer Compatibility/OpenGL non è supportato da Meta XR Simulator.
- Il launcher imposta `XR_RUNTIME_JSON` solo per il processo avviato: non richiede di cambiare il runtime globale del Mac.

## Avvio

Fare doppio clic su `run-xr-simulator.command` nella cartella del progetto, oppure eseguire `bash scripts/run-xr-simulator.sh` dal Terminale. Il log di Godot è in `logs/xr-simulator.log`.

Il runtime deve essere stato scaricato ed estratto prima dell'avvio. Il launcher controlla la presenza di `meta_openxr_simulator.json` e interrompe l'avvio con un messaggio leggibile se manca.

## Uso dal Godot Editor

In Editor Settings, attivare le opzioni avanzate e cercare `xr/openxr/runtime_paths`. Aggiungere al dizionario una voce chiamata `Meta XR Simulator` con il percorso assoluto a `meta_openxr_simulator.json`. Scegliere questo runtime dal menu in alto a destra, impostare il renderer Mobile/Vulkan e avviare il progetto.

Il Godot Meta Toolkit espone la stessa configurazione attraverso `Project > Tools > Configure Meta XR Simulator...`. Non è necessario aggiungere il suo Platform SDK al progetto: il launcher e le impostazioni native del Godot Editor consentono lo stesso avvio. Una copia ufficiale del toolkit è conservata sotto `tools/meta-toolkit-optional` per riferimento, separata dal progetto esportato.

## Mani simulate

Nella finestra del simulatore:

1. Aprire `Inputs` e quindi `Global Input Settings`.
2. Scegliere `Hand` per Left e/o Right.
3. Usare il mouse per il puntamento. Il clic sinistro simula il pinch delle mani abilitate.
4. I tasti documentati sono `1` per aim, `2` per poke, `3` per pinch, `4` per grab. Le assegnazioni sono consultabili e modificabili in `Input Bindings`.

Per cambiare modello, usare `Inputs > Device info > Device` dopo che un'app si è connessa. Fermare e riavviare l'app dopo ogni cambio profilo. Provare almeno i profili Quest 2, Quest 3, Quest 3S e Quest Pro disponibili nella versione installata. Un profilo nel simulatore verifica le API e la presentazione simulate, non l'hardware fisico.

## Verifiche sul Quest reale

Quando il Quest è disponibile, controllare installazione APK, avvio senza controller, selezione e rilascio del pinch, tracking perso e recuperato, leggibilità delle schede e fluidità. Non dichiarare un modello fisicamente testato sulla sola base del simulatore.

## Fonti ufficiali

- [Meta XR Simulator Mac ARM](https://developers.meta.com/vr/downloads/package/meta-xr-simulator-mac-arm/)
- [Requisiti e API grafiche](https://developers.meta.com/vr/documentation/native/xrsim-intro/)
- [Avvio e scelta del dispositivo](https://developers.meta.com/vr/documentation/native/xrsim-getting-started/)
- [Simulazione del hand tracking](https://developers.meta.com/vr/documentation/native/xrsim-hand-tracking/)
- [Configurazione del Godot Meta Toolkit](https://godot-sdk-integrations.github.io/godot-meta-toolkit/manual/xr_simulator.html)
- [Sorgente della configurazione del runtime](https://github.com/godot-sdk-integrations/godot-meta-toolkit/blob/main/toolkit/src/main/cpp/editor/meta_xr_simulator_dialog.cpp)

Verifica documentale: 16 novembre 2026. Lo stato delle prove effettivamente eseguite sarà riportato nel registro di validazione del progetto.

## Stato installazione

Meta XR Simulator 207.1 è installato ed è stata osservata la scena in esecuzione con profilo Quest 3, mani simulate e raggi visibili. Le interazioni pinch sono passate nel test sintetico del progetto; la selezione dal mouse del frontend Meta non è stata confermata e resta da verificare insieme al gesto sul visore reale.

La scritta “XR Simulator runtime disabled” indica il runtime globale del Mac: il nostro launcher imposta quello Meta soltanto per il processo Godot, quindi può esserci una scena attiva anche con quella scritta. Non occorre attivare il runtime globale.

Dati e log Meta sono reindirizzati a `.cache/meta-xr-simulator` sul SSD tramite un collegamento dal percorso standard del Mac.
