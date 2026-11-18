# Pocket Universe VR — Quest 2 performance sample

Measured on November 18, 2026 (Europe/Rome), approximately 00:03:00–00:06:01.

Physical Meta Quest 2, installed **0.6.7 (15) debug**, package `com.jamiejoe.pocketuniverse`, application process 22645. The installed APK SHA-256 previously matched `pocket-universe-debug-v0.6.7.apk`. No app, APK or device setting was changed for this measurement.

| Measurement | Result |
|---|---:|
| Capture duration | 180.58 seconds |
| Approximately one-second samples | 182 |
| Average application rendering FPS | 71.995 |
| Minimum / maximum sampled FPS | 71 / 72 |
| Display refresh | 72 Hz |
| Samples below 60 FPS | 0 |
| Highest reported app GPU time | 5.48 ms |
| Stale frames reported | 2 in 1 sample |
| Tear counter total | 36 across 26 samples, maximum 4 per sample |
| Highest power-save level reported | 0 (normal) |
| Script or fatal errors in captured app logs | 0 |

## Method and interpretation

Read-only ADB capture filtered to the Pocket Universe process, using Meta's VrApi runtime telemetry. Meta defines `FPS=rendered/display` as application frames rendered per second and display refresh rate. The headset was Awake and Pocket Universe appeared as a top resumed activity during the capture. The entrant was asked to exercise the journey, Earth and maximum zoom; exact interactions were not instrumented and cannot be established from these logs.

The sample shows no application rendering FPS below 60. Stale and Tear counters were nonzero; their cause was not determined. This short sample does not establish a full-content/thermal VRC pass, performance on other models, or measurements of the separately signed release APK. Meta's formal procedure uses OVR Metrics for the content duration or 45 minutes, whichever is shorter. A final release-channel test remains appropriate.

Raw log: `logs/quest2-fps-20261117-230300.log`. Structured result: `logs/final-quest2-fps-latest.json`. State evidence: `logs/final-fps-device-state.txt`.

Sources: [Meta logcat field definitions](https://developers.meta.com/vr/documentation/unreal/ts-logcat-stats/), [VRC performance criteria and test procedure](https://developers.meta.com/vr/resources/vrc-quest-performance-1/).
