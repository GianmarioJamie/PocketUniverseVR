# Android / Meta Quest

Toolchain isolata sul SSD: `tools/android-sdk`, `tools/jdk`, `tools/gradle`, `.cache`.
Il launcher configura JAVA_HOME, Android SDK e Gradle senza cambiare le impostazioni globali.

Godot 4.7.2 richiede nella configurazione sorgente API36 e build-tools36.1.0. Viene usata una copia del Temurin21 già installato, compatibile con Gradle e con destinazione bytecode Java17. Il download aggiuntivo di JDK17 è stato interrotto per evitare traffico inutile.

Build: `bash scripts/build-android.sh`.
Installazione dopo aver attivato developer mode e autorizzato il computer nel visore:
`tools/android-sdk/platform-tools/adb install -r builds/android/pocket-universe-debug.apk`

Questa è una build di prova. Per Competition occorre configurare firma release, versionamento, app Meta, canale Competition e link d'invito. Proteggere e conservare il keystore; non inserirlo nel repository.

## Release 0.5.2

`bash scripts/build-android.sh --release` produce `builds/android/pocket-universe-release-v0.5.2.apk`. Firma dedicata in `signing/` sul SSD, credenziali in `signing/release.env`, esclusi dal pacchetto e dal versionamento. Conservare entrambi i file: non rigenerare la chiave per gli aggiornamenti. Il target dell'app è API 34; API 36 serve per compilare il template e può restare installata.

Il file `android/build/pocket-manifest.gradle` corregge la dichiarazione 6DoF generata da Godot prima del merge. Va conservato insieme al relativo `apply from` in build.gradle se si reinstalla il template Android.

Controllo riproducibile: dopo `source scripts/android-env.sh` in bash, eseguire `python3 scripts/verify-apk.py builds/android/pocket-universe-release-v0.5.2.apk --release --report builds/android/release-build-info.json`.

La release è destinata alla Dashboard Competition. Ha firma diversa dal debug già installato: non può sostituirlo tramite `adb install -r`. Per continuare le prove senza disinstallare usare l'APK debug con la firma precedente. Nessuna disinstallazione automatica è prevista.

## Eccezione cache autorizzata

Il SSD è exFAT: i file AppleDouble `._*` interrompono Gradle e la lavorazione delle risorse Android. L’utente ha autorizzato la sola cache temporanea interna. `scripts/android-env.sh` usa `/private/tmp/pocket-universe-build-cache` per Gradle, temporanei e intermedi di compilazione. Progetto, SDK, Java, keystore e APK restano sul SSD. Non è una seconda copia del progetto.

Prima compilazione debug completata e firma APK verificata. Il keystore di debug serve soltanto alle prove.

## Nuova versione 0.6.0

Il comando --release usa ora il numero di versione da export_presets.cfg e produce pocket-universe-release-v0.6.0.apk. La firma release resta la stessa della 0.5.2, così come la firma debug: confronti certificati superati. Per SideQuest sopra il debug precedente usare pocket-universe-debug-v0.6.0.apk. I controlli aggiuntivi si attivano con --expect-journey nel verificatore APK.
