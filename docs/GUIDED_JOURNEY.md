# Three Wonders — 0.6.0

Viaggio facoltativo nella stessa scheda laterale: Start journey, poi tre tappe. Nessun limite di tempo, punteggio o nuovo gesto.

1. Prendere Terra, poi selezionare Moon. Il pulsante Discover Moon offre la stessa scoperta dalla scheda, anche dopo il rilascio, per una mano o mouse. Il vicinato terrestre rimane visibile durante la tappa. Una stella e Next discovery.
2. Prendere Saturno. Seconda stella e curiosità sugli anelli, poi Next discovery.
3. Prendere il Sole e spostare il sistema di almeno 3 cm, poi mettere in pausa le orbite. Anche la pausa già attiva è valida. Tre stelle e schermata conclusiva, Start again ed Explore freely.

Aloni discreti evidenziano Terra/Saturno/Sole. Selezionare il nome di un pianeta non equivale a prenderlo. Reset/recenter non contano come spostamento del Sole. Explore freely interrompe il tour; Reset scene riposiziona gli oggetti; Start again ricomincia il viaggio.

Tre suoni originali generati localmente: PCM mono 22.05 kHz, durata 0.38 secondi, volume -19 dB. Nessun asset esterno; volume regolabile dal visore.

Codice: src/guided_journey.gd, integrazione src/main.gd e UI src/side_card.gd. Nessun nuovo tracker o spostamento automatico del pannello/sistema.

Verifiche:

- logs/guided-journey-test.log: percorso completo, ordine delle tappe, nessun salto/ricompensa ripetuta, movimento prima della pausa, recenter escluso, riavvio e alternativa con una mano/mouse.
- logs/journey-smoke-console.log: regressioni su prese, scheda, anteprime, Terra e compagni, focus, gesti del sistema e recenter.
- logs/journey-visual-test.log: impaginazione e screenshot builds/screenshots/journey-v060.png e journey-complete-v060.png.
- logs/journey-xr-test.log: Meta XR Simulator 207.1, identità Quest Pro; nuovi pulsanti spaziali, avvio/libera esplorazione, due mani del runtime e recenter. Il percorso completo è verificato in modo scriptato, non tramite pinch manuale del frontend.
- APK: scripts/verify-apk.py --expect-journey controlla manifest, firme, ARM64, integrità, attribuzioni e presenza del nuovo modulo. Certificati confrontati con le rispettive build 0.5.2.

Prova funzionale e FPS della 0.6.0 sul Quest fisico ancora da eseguire. Nessuna nuova compatibilità fisica viene dedotta dal simulatore.
