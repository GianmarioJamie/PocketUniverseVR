# Pocket Universe VR

A small, seated solar system built with Godot and OpenXR for the Meta VR Start Developer Competition 2026.

## Consegna finale — 0.6.7

Controlli locali finali superati il 17 novembre 2026; l'utente conferma il funzionamento dell'esperienza sul visore. File Dashboard: `builds/submission/v0.6.7/pocket-universe-release-v0.6.7.apk`. Descrizione inglese, istruzioni e checklist nella stessa cartella. Dettagli in `docs/COMPETITION_AUDIT.md`; misura breve del 18 novembre sul Quest 2: 71–72 FPS a 72 Hz (debug 0.6.7, dettagli in `docs/PERFORMANCE_QUEST2.md`). Restano hosting HTTPS della privacy, caricamento Competition, video e invio Devpost; collaudo della release distribuita e procedura VRC completa non dimostrati.

Per SideQuest sopra le precedenti versioni debug usare `builds/android/pocket-universe-debug-v0.6.7.apk`. Le firme debug/release sono distinte.

## Cronologia 0.6.x — Three Wonders

Aggiornamento **0.6.7**: sistema solare iniziale 15 cm più in basso e scheda più vicina (circa 1.18 m dalla testa, prima 1.63 m). La stessa disposizione viene ripristinata da Recenter view e Reset scene; + / − seguono sempre la scheda. APK: `builds/android/pocket-universe-debug-v0.6.7.apk` e `builds/android/pocket-universe-release-v0.6.7.apk`.

Aggiornamento **0.6.6**: **+ / − sono agganciati al lato destro della card** e la seguono quando viene presa, spostata, ruotata o avvicinata/allontanata. Lo stesso vale per il trascinamento e la scala dell'anteprima desktop. APK: `builds/android/pocket-universe-debug-v0.6.6.apk` e `builds/android/pocket-universe-release-v0.6.6.apk`.

Aggiornamento **0.6.5**: i controlli della distanza sono soltanto **+ / −**, in colonna sul lato destro (+ avvicina, − allontana). Testi della scheda e delle tre tappe aggiornati a **Grab / Pinch**. APK attuali: `builds/android/pocket-universe-debug-v0.6.5.apk` e `builds/android/pocket-universe-release-v0.6.5.apk`.

Aggiornamento **0.6.4**: pulsanti esterni **Card closer / Card farther** per avvicinare/allontanare la scheda senza trascinarla. In VR il piccolo dock resta nella posizione iniziale sotto la scheda anche quando questa si sposta; i pulsanti regolano la distanza in passi da 15 cm, tra 0.55 e 2.60 m dalla testa. Recenter view e Reset scene ripristinano la scheda. Nel desktop la riga esterna rimane fissa e regola la dimensione dell'anteprima. APK attuali: `builds/android/pocket-universe-debug-v0.6.4.apk` e `builds/android/pocket-universe-release-v0.6.4.apk`.

Aggiornamento **0.6.3**: scheda afferrabile da tutta la superficie libera con pinch, anche da lontano. Da vicino una presa a mano chiusa consente di prenderla anche sopra i pulsanti; il pinch sui pulsanti li attiva normalmente. Nel desktop si trascina anche lo sfondo della scheda. APK: `builds/android/pocket-universe-debug-v0.6.3.apk` per SideQuest e `builds/android/pocket-universe-release-v0.6.3.apk` per la Dashboard.

Aggiornamento **0.6.2**: le mani con tracking valido rimangono visibili quando il palmo segnala il gesto Meta; vengono bloccate solo le interazioni, mentre la perdita effettiva di focus continua a nasconderle. Terra afferrata semplificata: nessun pulsante sotto, nessuna etichetta flottante dei compagni e nome Earth nascosto durante la presa. Info e Discover Moon rimangono sulla scheda. APK: `builds/android/pocket-universe-debug-v0.6.2.apk` e `builds/android/pocket-universe-release-v0.6.2.apk`.

Aggiornamento **0.6.1**: orbita di Saturno e orbite esterne distanziate per evitare l'intersezione degli anelli con Giove e Urano. Pannello laterale spostato di 20 cm per conservare il margine dalle orbite. APK attuali: `builds/android/pocket-universe-debug-v0.6.1.apk` (SideQuest) e `builds/android/pocket-universe-release-v0.6.1.apk` (Dashboard). Le rispettive firme sono conservate.

Viaggio opzionale nella scheda laterale: **Start journey**, poi Terra/Luna, Saturno e Sole con pausa delle orbite. Tre stelle e piccoli suoni originali accompagnano le scoperte, senza cronometro o punteggio. Dopo aver preso la Terra, **Discover Moon** rende la prima tappa accessibile anche con una mano o il mouse. **Explore freely** interrompe il tour; **Start again** lo ricomincia.

SideQuest: `builds/android/pocket-universe-debug-v0.6.0.apk`. Dashboard Meta: `builds/android/pocket-universe-release-v0.6.0.apk`. Entrambi riutilizzano le rispettive firme 0.5.2; debug e release rimangono due firme distinte. Prova fisica della nuova versione da eseguire.

Backup sicuro precedente: `builds/backups/0.5.2-before-guided-tour-20261117-202811`. Dettagli: `docs/GUIDED_JOURNEY.md`.

## Avvio sul Mac

- `run-desktop.command`: anteprima con mouse, senza visore.
- `install-quest.command`: installa l’APK di prova quando un Quest autorizzato è collegato via USB.
- `open-editor.command`: apre il progetto Godot.
- `run-xr-simulator.command`: avvia il percorso OpenXR nel Meta XR Simulator, quando installato.

Il progetto è `project.godot` in questa cartella. Motore, SDK, download e APK sono sul SSD esterno. La cache temporanea di compilazione usa il disco interno, come autorizzato, per evitare un problema Gradle con exFAT. I launcher impostano i percorsi; evitare di spostare singoli file.

## Controlli

Desktop: clic su un pianeta o sul suo nome; trascinamento con tasto destro per ruotare la vista; rotella per zoom; Spazio per pausa; tasti 1–8 per scegliere un pianeta; Esc per panoramica.

XR: puntare e unire pollice e indice (pinch). Schede, pausa, velocità e panoramica hanno pulsanti spaziali selezionabili con la stessa interazione. I pulsanti con i nomi facilitano la scelta dei pianeti piccoli.

## Scala e dati

Le dimensioni dei pianeti rispettano i rapporti dei diametri medi NASA. Sole ridotto, distanze compresse e periodi animati adattati per osservare il movimento. Le schede mostrano i valori astronomici effettivi, non quelli della visualizzazione. Materiali illustrativi procedurali, non fotografie scientifiche. Fonti: `docs/PLANET_SOURCES.md`.

## Android

`bash scripts/build-android.sh` prepara l'APK di debug in `builds/android`. La creazione richiede il completamento dell'installazione degli strumenti. L'APK deve essere provato sul Quest reale prima di dichiarare il funzionamento di tracking e prestazioni. La configurazione punta alla famiglia Meta Quest, con arm64 e OpenXR.

## Consegna

Verifica aggiornata al 16 novembre: [docs/COMPETITION_AUDIT.md](docs/COMPETITION_AUDIT.md). Release locale 0.5.2: `builds/android/pocket-universe-release-v0.5.2.apk`; test/debug: `builds/android/pocket-universe-debug-v0.5.2.apk`. La 0.5.1 è stata confermata sul Quest 2 dall'utente; 3/3S/Pro sono target dichiarati, senza prova fisica. Report e limiti sono nell'audit.

Restano da completare la registrazione Devpost, la creazione dell'app Meta e il canale Competition. Non sono eseguite automaticamente dal progetto. Servono inoltre una build accessibile ai giudici, il link d'invito e un video reale inferiore a tre minuti. Vedere `docs/VALIDATION.md` per lo stato effettivamente verificato.

Nota macOS: il percorso standard dei dati utente contiene solo un collegamento a `.cache/userdata` sul SSD; le preferenze dell’editor sono nella sua cartella self-contained.

Godot Engine e dipendenze: [godotengine.org/license](https://godotengine.org/license), testi inclusi in `assets/licenses` e nell'APK. Il testo MIT di Godot è inoltre disponibile nel log applicativo Android all'avvio.

## Versione 0.5.1 — mani dopo recenter e scheda sul fianco

- **Mani:** articolazioni, posizione di presa e puntamento allineati allo stesso riferimento di camera e controller dopo il ricentramento. Il loading trasferisce esplicitamente il rig XR alla scena principale.
- **Scheda laterale:** posizione iniziale oltre il bordo destro delle orbite; guardare verso destra per consultarla o afferrarla. Rimane riposizionabile e Recenter view ripristina questa disposizione laterale.
- **Avvio:** schermata `Pocket Universe VR` durante la preparazione della scena, anche nel percorso XR.
- **Anteprime corrette:** Sole e altri corpi hanno le immagini dei rispettivi modelli. La generazione attende il completamento dei frame GPU; l'anteprima del Sole è anche una dipendenza esplicita del pannello.
- **Sole:** tenere il pinch sulla sfera del Sole per traslare l'intero sistema. Nessuno scatto iniziale, rotazione o zoom gestuale. Al rilascio il sistema resta lì. Il pulsante `Sun` nel pannello apre solo la scheda informativa.
- **Recenter view:** ricentra la vista sulla posizione e direzione attuali del visore e riporta contenuto e scheda davanti all'utente. Tiene il mondo orizzontale e conserva zoom, tempo e pausa. Usa `XRServer.center_on_hmd(RESET_BUT_KEEP_TILT, false)` con spazio Stage, e gestisce anche il segnale `pose_recentered` del runtime, quindi anche il ricentramento del tasto Meta. Tasto R nell'anteprima desktop.
- **Reset scene:** rimette lo zoom a 1× e ripristina la disposizione del contenuto rispetto alla vista già centrata. È distinto da Recenter view.
- **Exit:** chiude l'applicazione; sul Quest il sistema operativo torna all'ambiente Home. Da confermare sul visore reale.
- **Scheda:** tenere il pinch su una qualsiasi area libera per spostarla, oppure afferrarla da vicino con la mano chiusa anche sopra i pulsanti. Pinch sui pulsanti per usarli. L'altra mano può continuare a muovere i pianeti.
- **Terra:** Luna, ISS e Hubble compaiono mentre la si tiene. Selezionare modelli/targhette con l'altra mano per i dati.
- **Zoom + / Zoom -:** scala il sistema intorno al Sole. I pianeti già in mano restano indipendenti.

APK per SideQuest: `builds/android/pocket-universe-hands-fix-v0.5.1.apk`.
Versioni precedenti conservate in `builds/android`, sorgenti precedenti in `builds/backups`.
