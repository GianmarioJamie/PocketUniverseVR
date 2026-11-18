# Pocket Universe

Tagline: Hold a solar system in your view. Point, pinch, and discover eight worlds at your own pace.

Track: Entertainment
Division: New Experience
Status: updated for 0.6.7. Use SUBMISSION_FINAL.md for the clean English description and TESTING_INSTRUCTIONS.md for current controls. Dashboard links, video, privacy hosting remain to be completed. A short Quest 2 debug FPS sample is available in PERFORMANCE_QUEST2.md; release/full-content VRC validation remains outstanding. See COMPETITION_AUDIT.md.

## Inspiration

The solar system is often shown on a flat page. We wanted to make it a small, quiet place you could explore while seated: eight worlds moving around a star, with their differences in size visible at a glance.

## What it does

An optional Three Wonders journey gives visitors a short path through the experience: hold Earth and discover its Moon, inspect Saturn's rings, then move the universe by its Sun and pause the orbits. Three stars and gentle original chimes mark discoveries, with no timer, score or penalties. Visitors can return to free exploration at any time.

Pocket Universe presents an animated miniature solar system. Select a planet to reveal its diameter, distance from the Sun, orbital period and a short fact. Hold a pinch to bring a planet into your hand, then release it to send it back to its moving orbit. Grab Earth to reveal the Moon and two illustrative spacecraft in the same scene. Pause the orbits or change the animation speed to explore at your own pace. Large planet-name buttons provide an alternative target for the smallest worlds.

Planet sizes are proportional to NASA mean diameters. The Sun, orbital spacing and animation times are adapted for comfortable viewing; each information card shows the real astronomical values. The surfaces are illustrative procedural materials.

## How we built it

Built with Godot, OpenXR and the Godot OpenXR Vendors plugin. Shared interaction logic connects desktop mouse input and hand-based XR selection to the same content. Lightweight geometry and materials keep the scene small. The application runs locally and does not need a third-party content or AI service.

## Hand interactions

Point and pinch to select a planet, pause, change speed or return to the overview. Grab or hold a pinch to inspect planets, and use Zoom + and Zoom - to resize the system. Grab any free area of the side card; a nearby closed-hand grab also works over its controls. The attached + / − buttons adjust card distance. Grab the Sun to move the entire system. Recenter view realigns the experience with your current seated position; Exit closes it. The application provides visible rays, feedback and model previews. Tracking loss, system gestures and loss of input focus release holds and prevent unintended activation.

## Next steps

Refine accessibility, visual clarity and hand interaction based on headset testing and user feedback.

## Before submitting

Add target launch date, team details, Competition channel invite URL and public demo video URL. Complete Dashboard privacy and app metadata. Do not claim a device was tested if only its simulator profile was used. See COMPETITION_AUDIT.md and SUBMISSION_CHECKLIST.md.

## Demo outline — target 2 minutes

- 0:00–0:15: show the running solar system and state the idea.
- 0:15–0:50: start Three Wonders, grab/pinch Earth and discover the Moon; show readable information.
- 0:50–1:15: grab/pinch Saturn and show its rings and second star.
- 1:15–1:40: grab/pinch the Sun, move the system and pause orbits to finish the journey.
- 1:40–2:00: move the card, show its attached + / − controls and return to free exploration. State that planet sizes are proportional while orbital spacing and the Sun are adapted.

Record actual headset or XR simulator footage. Desktop mouse preview alone should not be represented as headset footage.
