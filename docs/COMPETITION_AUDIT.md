# Pocket Universe VR — verifica finale, aggiornamento 18 novembre 2026

**Aggiornamento fisico del 18 novembre:** dopo aver rimosso la debug, l’utente ha installato la release 0.6.7 e confermato che funziona sul Quest 2. La misura FPS descritta sotto riguarda la debug, non la release.

**Controlli locali superati per la 0.6.7.** L'utente conferma il funzionamento dell'esperienza sul proprio visore. Non è una certificazione Meta: caricamento Dashboard, accesso giudici e hosting privacy restano da completare. Misura breve sul Quest 2 disponibile; procedura VRC completa sulla release non dimostrata.

## Build da consegnare

- APK: `builds/android/pocket-universe-release-v0.6.7.apk`.
- Package `com.jamiejoe.pocketuniverse`, versione 0.6.7, versionCode 15, 82.436.737 byte.
- SHA-256: `5c091abd25bb794ad3097c5d4a21098c9d9daa7eba309883fbee8ab858047faa`.
- Copia per la consegna: `builds/submission/v0.6.7/`, con descrizione inglese, istruzioni, checklist e report. Nessuna chiave privata.
- Report sul binario effettivo: `builds/android/final-release-audit.json`.

Verificati firma v2 release, app non debuggable, continuità del certificato con la release precedente, ZIP integro, ARM64, allineamento ZIP/ELF 16 KB, SDK minimo 29 e target 34, 6DoF e hand tracking richiesti, categorie Meta/OpenXR, esclusione dai recenti, licenze incluse e assenza di materiale di firma. Nessun permesso Internet o eye tracking. Valori coerenti con il [manifest Meta](https://developers.meta.com/vr/resources/publish-mobile-manifest/); il controllo locale non sostituisce l'accettazione Dashboard.

Debug e release hanno firme diverse. Per la Dashboard usare **release**. Sopra una precedente installazione debug usare la debug corrispondente; installare release sopra debug causa conflitto di firma. Conservare privatamente `signing/` e riusare il keystore release per gli aggiornamenti.

## Collaudo finale

Nuovamente superati, senza errori di script o assertion nei log finali:

- `logs/final-smoke-console.log`: orbite e anelli separati, selezione, grab/pinch, ritorno in orbita, Sole, compagni Terra, reset/recenter, anteprime e card.
- `logs/final-journey-test.log`: Three Wonders completo, alternativa Discover Moon, tre ricompense, riavvio e uscita libera dal tour.
- `logs/final-card-grab-test.log`: superficie card, priorità pulsanti, rotazione, trascinamento, rilascio e perdita tracking.
- `logs/final-card-distance-test.log`: + / − seguono la card, bersagli dopo spostamento/rotazione, limiti e reset.
- Gestione sintetica di entrambe le mani: palmi rivolti al volto, gesti riservati, perdita/ripresa focus e riarmo delle prese.

Il test XR già eseguito sulla stessa revisione 0.6.7 (`logs/default-layout-xr-test.log`) identifica **Meta Quest Pro / Meta XR Simulator 207.1**: due tracker mani, recenter e controlli scriptati passati; distanza iniziale card 1,184 m e sistema 0,53 m sotto la testa. Nessuna ricompilazione o modifica del codice applicativo durante questi controlli finali.

## Compatibilità: evidenze e limiti

| Dispositivo | Evidenza |
|---|---|
| Quest 2 | Quest 2 fisico confermato via ADB; hash della debug 0.6.7 installata coincide con l'artefatto locale. Misura breve: 71–72 FPS a 72 Hz. Release separata non installata/misurata. |
| Quest 3 | Identità runtime, mani, scena, recenter e interazioni scriptate nel simulatore; nessuna prova fisica. |
| Quest 3S | Dichiarato nell'APK; nessuna prova fisica o sessione simulata dedicata. |
| Quest Pro | Test simulati, inclusa disposizione iniziale 0.6.7, superati; nessuna prova fisica. |

Il simulatore esegue il progetto nativo OpenXR sul Mac, non l'APK Android. Non dimostra prestazioni o compatibilità fisica universale. Quest 1, Go, Rift e Meta VR Glasses non sono target dichiarati di questo APK.

**Misura FPS sul Quest 2 del 18 novembre:** 182 campioni VrApi filtrati sul PID dell’app, circa 3 minuti, media **71,995 FPS**, minimo **71**, massimo **72**, refresh **72 Hz**, nessun campione sotto 60 e nessun errore script/fatale nei log raccolti. Contatori runtime: 2 Stale e 36 Tear; causa non determinata. Test sulla debug 0.6.7 installata, non sulla release separata; sequenza precisa delle azioni non strumentata. Dettagli in `PERFORMANCE_QUEST2.md`. Il [VRC Performance.1](https://developers.meta.com/vr/resources/vrc-quest-performance-1/) richiede almeno 60 fps e refresh ammesso; la procedura formale usa OVR Metrics per la durata del contenuto o 45 minuti, il minore dei due. Questa misura breve non certifica tale procedura. [Definizione Meta dei contatori VrApi](https://developers.meta.com/vr/documentation/unreal/ts-logcat-stats/).

Ultimo controllo manuale sulla release: completare e riavviare Three Wonders, aprire/chiudere il menu Meta durante una presa, verificare ritorno mani, Exit e avvio a freddo. La revisione del codice non ha trovato omissioni bloccanti nel percorso hands-only.

## Consegna ancora da completare

1. Dashboard: campi obbligatori, privacy e dichiarazioni dati; caricare la release nel nuovo canale **Competition**, ottenere l'**Invite URL** e verificare l'accesso da un account tester autorizzato.
2. Privacy: `PRIVACY_POLICY.md` e `privacy-policy.html` sono completati con Jamie e l'email fornita dall'utente. Ospitare l'informativa su HTTPS pubblico e inserire l'URL nella Dashboard. [Requisiti Meta](https://developers.meta.com/vr/policy/privacy-policy/).
3. Video pubblico YouTube/Vimeo **inferiore a 3 minuti**, registrazione effettiva Quest o simulatore, inglese o sottotitoli inglesi.
4. Devpost: proposta **Entertainment / New Experience**; descrizione inglese, tagline entro 140 caratteri, data di lancio prevista, membri/ruoli/email, Invite URL e video; effettuare l'invio finale.
5. Account Developer e Start confermati dall'utente. Idoneità personale, residenza, conflitti e assenza di finanziamenti Meta separati restano dichiarazioni del partecipante.
6. Termine: **18 novembre 2026, ore 21:00 italiane**. Accesso gratuito ai giudici fino all'annuncio dei vincitori; non modificare la candidatura dopo la scadenza.

Fonti ricontrollate il 17 novembre: [consegna](https://start-developer-competition-26.devpost.com/), [regolamento](https://start-developer-competition-26.devpost.com/rules). Pubblicazione completa nello Store e canale Competition sono percorsi distinti. Stato Dashboard e invio Devpost non verificati.
