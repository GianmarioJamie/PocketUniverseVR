# Pocket Universe VR — testing instructions

Version: 0.6.7 (15). Package: `com.jamiejoe.pocketuniverse`.

Use the build provided through the Competition channel invite URL. Sit comfortably, enable hand tracking on the headset, put controllers aside and keep your hands in the tracking cameras' view. There is no login, purchase or network service needed inside the application.

## Free exploration

1. After the Pocket Universe VR loading screen, an animated solar system appears in front of you and an information card appears to your right.
2. Point at a planet or the Sun and pinch to see its preview and facts. The name buttons on the card also select each body.
3. Grab a nearby planet with a closed hand, or point and hold a pinch. Move it for inspection, then release it; it returns to its orbit.
4. Grab Earth to reveal its Moon, ISS and Hubble. Select these bodies to display their information on the card.
5. Grab the Sun to move the solar system. Release to leave the system there.
6. Use the card's solar-system zoom buttons, Pause / Play and Time speed. The small + / − buttons attached to the card's right edge instead move the card nearer or farther.
7. Pinch and drag any free area of the card to move it. A nearby closed-hand grab can also hold it over a button. Pinching a button activates the button.

## Three Wonders journey

1. Select Start journey. Grab / Pinch Earth, then select the Moon or use Discover Moon. The first star appears.
2. Select Next discovery and Grab / Pinch Saturn to earn the second star.
3. Select Next discovery. Grab / Pinch the Sun and move the system slightly, then pause the orbits to earn the third star. If already paused, leave them paused.
4. Use Start again to repeat, or Explore freely to leave the journey at any point.

## Comfort and lifecycle

Reset scene restores the arrangement. Recenter view aligns it with your current seated position; the headset's system recenter is also supported. Release a hand gesture and open the hand if tracking or the system menu interrupted a hold. Exit closes the application.

For a final headset check, complete and restart the journey, open and close the system menu while holding a body, confirm hands return, then Exit and relaunch. Measure application rendering FPS on-device with OVR Metrics; perceived smoothness and simulator performance do not establish the required frame rate.

The APK declares Quest 2, Quest 3, Quest 3S and Quest Pro. The current experience is reported working by the entrant on their headset, previously identified as Quest 2. Quest 3 and Pro have simulator evidence; physical Quest 3/3S/Pro compatibility has not been validated. A short physical Quest 2 debug 0.6.7 sample collected 182 app-PID VrApi readings: mean 71.995 FPS, minimum 71, maximum 72 at 72 Hz; no readings below 60. See PERFORMANCE_QUEST2.md for nonzero compositor counters and scope limits. The separately signed release APK and full VRC duration were not measured. The Mac simulator runs the native OpenXR project, not this Android APK.

Update, November 18: after uninstalling the debug build, the entrant installed the release 0.6.7 APK and confirmed it works on Quest 2. The short FPS measurement above remains specific to the debug build.
