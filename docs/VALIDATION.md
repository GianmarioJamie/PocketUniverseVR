# Stato di verifica

## Verificato sul Mac Apple M4

- Godot 4.7.2 ufficiale, plugin OpenXR Vendors 5.2.0 importato.
- Parsing e avvio scena con otto pianeti.
- Test automatico: selezione di tutti i pianeti, ray picking Terra, pausa del tempo, cambio velocità, panoramica.
- Test con XRHandTracker sintetico: pinch seleziona Terra, perdita tracking nasconde cursore e disarma la selezione.
- Anteprima desktop eseguita con renderer Compatibility; screenshot ispezionato, etichette e scheda Terra leggibili.
- Immagine: `builds/screenshots/desktop.png`.

## Da verificare

- Meta XR Simulator 207.1 installato: scena e mani viste sul profilo Quest 3. Da confermare selezione tramite frontend Meta; il test sintetico pinch passa.
- APK debug compilato, firma v2 verificata, ARM64 e hand tracking nel manifest. Installazione sul visore ancora da eseguire.
- Tracking ottico reale, stabilità su Quest, comfort da seduti, prestazioni e pausa/ripresa dal sistema.
- Quest 3 / 3S / Pro: configurazione prevista, nessuna prova su hardware fisico.
- Registrazione, app Meta, canale Competition e accesso giudici.

## Percorsi

Progetto, strumenti, APK e dati applicativi sono sul SSD. La cache di compilazione temporanea interna è autorizzata dall’utente: `/private/tmp/pocket-universe-build-cache`. Un collegamento creato nel percorso standard del Mac è `~/Library/Application Support/Pocket Universe`, che punta a `.cache/userdata` sul SSD e non contiene una copia interna dei dati. L'editor usa la modalità self-contained (`_sc_`) per preferenze e cache.

Godot in headless nella sandbox può segnalare l'accesso negato al portachiavi CA del sistema; l'esecuzione grafica autorizzata non presenta quell'errore. Non è un errore del progetto.

Il simulatore segnala “Color space is not supported: 3”; il rendering della scena è stato comunque osservato. La cattura diretta del framebuffer XR da Godot produce un’immagine nera: per la demo utilizzare la registrazione del frontend Meta o il visore, non quel readback.

## Aggiornamento interattivo 0.2.0

La versione 0.1.0 è stata confermata funzionante sul visore dall'utente. Copia APK e sorgenti base in `builds/backups/0.1.0`.

Nuovi controlli automatici: pianeta afferrato segue il punto di presa; perdita tracking rilascia; ritorno alla posizione orbitale con ripristino della scala; due mani ingrandiscono e ruotano il gruppo; passaggio a una mano senza salto; trascinamento del pannello; Terra con tre compagni e selezione della scheda ISS; reset. Anteprima desktop ravvicinata ispezionata.

Le nuove interazioni devono essere confermate sul Quest reale. Fonti e provenienza dei modelli in `docs/EARTH_COMPANIONS.md`.

Vista XR 0.2.0 osservata nel Meta XR Simulator (profilo Quest 3): Terra ingrandita, Luna e modelli di ISS/Hubble, targhette, maniglie sistema/pannello. Nessuna prova fisica della versione 0.2.0 ancora eseguita.

APK 0.2.0 (versionCode 2) compilato, firma v2 e integrità ZIP verificate. Moduli di presa e compagni Terra presenti nel pacchetto. File esplicito per SideQuest: `builds/android/pocket-universe-interactive-v0.2.0.apk`.

## 0.3.0 — zoom a pulsanti e Sole

Su richiesta dopo la prova sul visore: rimossi spostamento e rotazione gestuali dell’intero sistema, relative maniglie e pulsante Rotate. Inseriti Zoom + / Zoom - nella UI XR. I pulsanti mantengono posizione e orientamento del Sole, limitando la scala 0.45×–2.5×. Selezione del Sole via sfera o pulsante Sun con dati NASA.

Test passati: limiti zoom, centro/orientamento invariati, vecchio gesto del sistema ignorato, selezione geometrica del Sole e sua scheda, regressioni su presa/rilascio pianeti, tracking perso, pannello e compagni Terra. Anteprima Mac ispezionata. Nuova verifica fisica sul Quest da eseguire.

## 0.4.0 — scheda laterale con anteprime

Sostituita la UI XR centrale con una sola scheda a destra, afferrabile dalla barra superiore. Scheda condivisa con l'anteprima desktop, con immagini originali statiche per Sole, otto pianeti e i tre compagni della Terra. Le descrizioni e tutti i comandi sono nella scheda. Nessun render 3D aggiuntivo per le anteprime durante l'uso sul visore.

Verifiche: tutti i PNG caricati e correttamente associati alle selezioni; presa simultanea Terra/scheda con due sorgenti indipendenti; rilascio scheda senza rilascio Terra; zoom e navigazione mentre si tiene un pianeta; corrispondenza geometrica dei bersagli XR di tutti i pulsanti dopo rotazione della scheda; sfondo della scheda intercetta i raggi per impedire prese involontarie dietro. Test di regressione su orbite, Sole, prese e compagni Terra passati.

Anteprima desktop Terra ispezionata. Vista XR osservata nel Meta XR Simulator, profilo Quest 3: scheda completamente visibile sul lato destro e zona centrale libera. Prova della nuova versione su hardware reale ancora da eseguire.

APK finale 0.4.0 (versionCode 4) compilato: firma verificata, integrità ZIP verificata, dodici immagini con texture importate e modulo side_card presenti nel pacchetto. File: `builds/android/pocket-universe-side-card-v0.4.0.apk`.

## 0.5.0 — anteprime corrette, Sole afferrabile, recenter, exit e loading

Corretto un problema reale della generazione anteprime: contando callback CPU anziché attendere i frame GPU, alcune immagini erano associate al modello precedente (Sun mostrava Saturn). Rigenerate tutte attendendo `RenderingServer.frame_post_draw`, verificata l'immagine arancione del Sole e aggiunto controllo automatico del colore centrale.

Sun grip: traslazione senza snap/rotazione, rilascio mantiene posizione, perdita tracking rilascia, un pianeta nell'altra mano mantiene la propria posizione. Nuovo Recenter view distinto da Reset scene: Stage reference space esplicito, `XRServer.center_on_hmd(RESET_BUT_KEEP_TILT, false)`, attesa tracking aggiornato, contenuto riallineato alla posizione/yaw correnti senza tilt e conservando zoom/tempo/pausa. Gestito anche `OpenXRInterface.pose_recentered`.

Caricamento reale: boot splash con titolo e scena di attesa visibile; caricamento threaded della scena, poi transizione al contenuto. Verificato screenshot loading desktop e transizione. Exit invoca la chiusura dell'esperienza e rilascia le prese.

Meta XR Simulator (Quest 3) ha eseguito LOADING_SCREEN_VISIBLE, LOADING_COMPLETE, VIEW_RECENTERED, XR_RECENTER_TEST_PASS ed EXIT_EXPERIENCE_REQUESTED. Test geometrici/due mani/card e chiusura headless passati. I messaggi di teardown delle estensioni vendor/interaction profile provengono dal runtime/plugin sul Mac; la prova della nuova versione su Quest reale resta necessaria.

Fonti tecniche: https://docs.godotengine.org/en/stable/tutorials/xr/openxr_settings.html e https://docs.godotengine.org/en/stable/classes/class_xrserver.html .

APK finale 0.5.0 (versionCode 5) compilato: firma e integrità ZIP verificate; modulo boot, schermata loading e dodici anteprime con relative texture importate presenti. File: `builds/android/pocket-universe-recenter-v0.5.0.apk`.

## 0.5.1 — allineamento mani e scheda fuori dalle orbite

Corretto l'uso delle pose raw di XRHandTracker: camera/controller applicano world_scale e reference_frame, mentre la visualizzazione procedurale delle mani e il punto di presa non lo facevano. Dopo center_on_hmd le mani potevano quindi restare alle coordinate precedenti, fuori dalla visuale. Ora le articolazioni e il punto di pinch usano la stessa conversione di XRPose.get_adjusted_transform. Le distanze delle dita per riconoscere il gesto restano misurate nelle coordinate raw in metri.

Reso esplicito il passaggio di XROrigin3D.current dalla scena loading alla scena principale.

Scheda iniziale spostata sul fianco destro oltre il massimo ingombro laterale delle orbite a zoom 1×, con margine di almeno 6 cm. Il controllo usa gli estremi della scheda ruotata e le dimensioni dei pianeti. L'utente può guardare a destra e spostare la scheda.

Test passati: trasformazione mani con riferimento non identità e world scale, regressioni di presa/card, layout iniziale libero dalle orbite. Test nel Meta XR Simulator: loading, Recenter view, due mani tracciate e visibili con pose corrette (XR_HANDS_AFTER_RECENTER_PASS count=2), poi uscita. L'utente ha successivamente confermato la 0.5.1 perfettamente funzionante sul Quest 2 fisico (16 novembre 2026).

## 0.5.2 — verifica competizione e confezionamento release

Successivamente eseguite sessioni separate Meta Quest 3 e Meta Quest Pro, con identità letta dal runtime. Loading, scena e mani osservati; recenter con due tracker reali del simulatore e test scriptati di presa/card/zoom/Sole passati in entrambi. Il pinch manuale dal frontend resta non confermato. Dettagli in SIMULATOR_PROFILE_RESULTS.md.

Vedere COMPETITION_AUDIT.md per fonti ufficiali, dispositivi, requisiti ed elementi ancora da completare. Release con API target 34, 6DoF obbligatorio, firma dedicata, recents esclusi, eye tracking disabilitato e attribuzioni distribuite. Focus e gesti del sistema corretti con test sintetici per entrambe le mani; regressioni e test XR recenter passati. Report binario in builds/android/release-build-info.json. La prova funzionale completa della 0.5.2 e le misure FPS non sono sostituite dalla conferma dell'utente sulla 0.5.1.

## 0.6.0 — Three Wonders

Aggiornamento 0.6.1: Giove rimane a raggio 0.49; Saturno passa a 0.75, Urano a 0.96, Nettuno a 1.06. Dimensioni e anelli invariati. Il test OUTER_ORBITS_PASS misura gli ingombri dei mesh (inclusa la larghezza dei torus di Saturno) e verifica oltre 2 cm di separazione conservativa a ogni fase orbitale e zoom condiviso. Margini minimi effettivi a 1×: 3.04, 3.28 e 4.12 cm. Il pannello parte a x=1.32, oltre 11 cm fuori dal massimo ingombro orbitale. Regressioni e percorso guidato passati; nuova verifica fisica ancora da eseguire.

Viaggio opzionale di tre tappe, tre stelle, conferme sonore originali e alternativa Discover Moon con una mano/mouse. Percorso e regressioni passati; impaginazione desktop ispezionata; UI spaziale e mani/recenter verificati nel simulatore Quest Pro. Vedere GUIDED_JOURNEY.md per le evidenze. Le firme sono riutilizzate dalle corrispondenti build 0.5.2. Nuova prova fisica ancora necessaria.

## 0.6.2 — palmi visibili e Terra essenziale

Spostata la gestione del gesto Meta dopo l’aggiornamento delle articolazioni: mentre il focus resta all’app, un palmo rivolto verso il visore non viene più nascosto dal codice. Raggi, cursori e input restano sospesi durante i gesti riservati; la perdita effettiva del focus continua a rilasciare e nascondere le mani. Test sintetici PALM_VISIBILITY_PASS per entrambi i palmi ruotati, blocco dei gesti e focus persi/ripresi superati.

Rimossi tutti i tab geometrici sotto la Terra, le etichette Moon/ISS/Hubble e la nota di vicinato. Il nome Earth si nasconde durante la presa e torna al rilascio. Conservati corpi/orbite, bersagli sui modelli, informazioni sulla scheda e alternativa Discover Moon. EARTH_CLEAN_PASS verifica assenza di Label3D e un solo bersaglio per ciascuno dei tre corpi. Tour e regressioni passati. Anteprima desktop: builds/screenshots/earth-clean-v062.png.

Meta XR Simulator 207.1, profilo Quest Pro: scena, tour/card, due tracker reali e recenter passati in logs/hand-earth-xr-test.log. Le prove di rotazione/gesto Meta sono sintetiche; nuovo collaudo fisico ancora necessario, soprattutto se il visore perde realmente il tracking ottico. APK 0.6.2, versionCode 10, firmati con le chiavi già in uso.

## 0.6.3 — scheda afferrabile dappertutto

Lo sfondo completo è un bersaglio di presa, senza passaggio dei raggi ai pianeti dietro. Pinch sulle aree libere per trascinare; da vicino una mano chiusa prende la scheda anche sopra i comandi. La selezione locale mantiene priorità ai pulsanti per il pinch, inclusi tour, zoom e uscita. Stessa superficie utilizzabile per trascinamento mouse sullo sfondo.

WHOLE_CARD_GRAB_PASS verifica aree superiore/centrale/inferiore, angoli, preview e bordi, scheda ruotata, tutti i pulsanti, pinch locale che attiva Pause senza trascinare, mano chiusa che trascina sopra Pause senza attivarlo, assenza di snap, mantenimento presa e rilascio/perdita tracking. Regressioni e tour passati. Log: logs/whole-card-grab-test.log, logs/card-grab-smoke-console.log, logs/card-grab-journey-test.log. Nuova prova fisica da eseguire; certificati riutilizzati.

## 0.6.4 — pulsanti esterni per la distanza della scheda

Dock VR indipendente sotto la posizione iniziale della scheda, ancorato allo spazio e riposizionato insieme allo Stage dal recenter. Azioni 140/141 Card closer e Card farther: passi da 15 cm lungo la direzione testa-scheda, limiti 0.55–2.60 m, orientamento e dimensione conservati. Il dock non segue la scheda e rimane quindi disponibile dopo lo spostamento. Se la scheda era tenuta da una mano, il comando ne rilascia solo la presa per evitare che il trascinamento annulli lo spostamento; i pianeti tenuti non vengono rilasciati. Nessuno spostamento quando il focus manca o durante il recenter.

Desktop: riga di due pulsanti sotto la card e indipendente dal suo trascinamento, con dimensione della scheda limitata allo spazio disponibile nella finestra. CARD_DISTANCE_PASS verifica ray/near targeting, dock fisso, passi e limiti, angolo/scala conservati, pianeta tenuto invariato, reset/recenter, focus e pulsanti desktop. Regressioni di mani, Terra, orbite e tour passate. Meta XR Simulator Quest Pro: XR_CARD_DISTANCE_PASS e due mani allineate dopo il recenter.

Evidenze: logs/card-distance-test.log, logs/card-distance-smoke-console.log, logs/card-distance-journey-test.log, logs/card-distance-xr-test.log. Anteprima: builds/screenshots/card-distance-v064.png. Prova fisica della 0.6.4 ancora da eseguire.

## 0.6.5 — simboli laterali e Grab / Pinch

Dock indipendente spostato sul lato destro della scheda, con + sopra (azione140, avvicina) e − sotto (azione141, allontana). Stessa disposizione verticale nell’anteprima desktop, con spazio riservato a destra e limiti di trascinamento che evitano di coprire i pulsanti. I testi del pannello e delle tappe Terra/Saturno/Sole indicano Grab / Pinch; Moon e Pause / Play sono selezioni Pinch.

CARD_DISTANCE_PASS verifica anche simboli esatti, posizione esterna a destra, bersagli ray/near e mapping azioni. Percorso guidato e regressioni passati. Anteprima: builds/screenshots/card-distance-v065.png. Log: logs/card-signs-test.log, logs/grab-pinch-journey-test.log, logs/card-signs-smoke-console.log. Nuova verifica fisica ancora da eseguire.

## 0.6.6 — + / − solidali alla card

Corretto il comportamento richiesto: il dock VR è figlio di info_panel, con offset locale sul lato destro; il dock desktop è figlio del canvas. Entrambi seguono traslazione, rotazione e cambio di distanza/scala invece di restare fermi. Preservati simboli, azioni, limiti distanza, reset/recenter e istruzioni Grab / Pinch.

ATTACHED_CARD_BUTTONS_PASS verifica una vera presa con traslazione/rotazione della card, offset locale costante, bersagli ray ancora selezionabili, spostamento con + / − e trascinamento/scala desktop. Regressioni passate; logs/attached-card-buttons-test.log, logs/attached-card-smoke-console.log. Simulatore e anteprima: logs/attached-card-xr-test.log, builds/screenshots/card-distance-v066.png. Nuova prova fisica ancora da eseguire.

## 0.6.7 — posizione iniziale più comoda

Sistema solare locale y=-0.53 m, prima -0.38 m: 15 cm più basso rispetto alla testa. Scheda locale (0.95,0.10,-0.70), circa 1.184 m dalla testa invece di 1.629 m, con orientamento verso il centro. Home/reset/recenter derivano da queste stesse trasformazioni, mantenendo + / − agganciati.

Controllo di separazione iniziale esteso alla distanza verticale, includendo in modo conservativo l’intero raggio degli anelli di Saturno: circa 13.7 cm tra il limite superiore del sistema e il bordo inferiore della scheda, a scala iniziale. Regressioni, tour e controlli della distanza passati; nuova prova fisica da eseguire. Log: logs/default-layout-smoke-console.log, logs/default-layout-card-test.log, logs/default-layout-journey-test.log, logs/default-layout-xr-test.log.

## Controllo finale — 17 novembre 2026, 0.6.7 (15)

Nessuna modifica all'app o ricompilazione. Rieseguiti smoke, Three Wonders, presa completa card e distanza/pulsanti collegati: tutti i marker attesi presenti, nessun errore di script/assertion. Log `logs/final-*.log`. APK release nuovamente verificato da `verify-apk.py --release --expect-journey`: report `builds/android/final-release-audit.json`. Copia per la consegna in `builds/submission/v0.6.7/`, SHA-256 uguale all'originale. Descrizione inglese 403 parole, tagline 97 caratteri.

Quest 2 collegato via ADB: installata versione 0.6.7, versionCode 15, debug. Al momento della lettura app non in esecuzione e visore Asleep; nessuna misura FPS ricavabile. Evidenza in `logs/final-quest2-device-check.txt`. Conferma utente sul funzionamento corrente, distinta da una prova strumentata dell'APK release.

Privacy completata con identità e contatto forniti dall'utente; hosting HTTPS ancora da effettuare. Caricamento Competition, Invite URL, video, metadati e invio Devpost non verificati. Riferimento aggiornato: `docs/COMPETITION_AUDIT.md`.

Confrontato anche SHA-256 del base.apk installato via ADB: coincide con `pocket-universe-debug-v0.6.7.apk` (`2e7985ee650ea5d57d062678d09e7a5e92d29c4bec4880f62d03fc1964b0b0a5`). La release rimane verificata localmente, non installata sopra la debug per evitare rimozione/conflitto di firma.

## 18 novembre 2026 — misura FPS Quest 2 fisico

Installata debug 0.6.7 (15), hash già verificato. Cattura VrApi filtrata PID 22645 per circa 3 minuti: 182 campioni, media 71,995 FPS, minimo 71, massimo 72, refresh 72 Hz, zero campioni sotto 60. App GPU massimo 5,48 ms; 2 Stale e 36 Tear segnalati; nessun errore script/fatale nei log raccolti. Visore Awake e app top resumed durante la misura. Interazioni richieste all’utente ma non strumentate; nessuna garanzia sulla sequenza completa o sulla release separata. Report `docs/PERFORMANCE_QUEST2.md`, dati `logs/final-quest2-fps-latest.json`. Nessuna modifica del codice o dell’APK.
