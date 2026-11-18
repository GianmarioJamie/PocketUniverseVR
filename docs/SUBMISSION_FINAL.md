# Pocket Universe VR

Tagline: Grab a world, discover its story, and take a three-stop journey through a miniature solar system.

Track: Entertainment

Division: New Experience

## Inspiration

The solar system is usually something we look at from a distance. We wanted to turn it into a small, quiet place you can explore with your hands while seated: eight worlds moving around a star, each with a story to discover.

## What it does

Pocket Universe VR puts a miniature solar system in front of you. Grab or pinch a planet to inspect it, then release it and watch it return to its moving orbit. Select any planet or the Sun to see an illustrated preview, astronomical facts and a short description on a movable side card.

Holding Earth reveals the Moon and illustrative models of the International Space Station and Hubble Space Telescope. Holding the Sun lets you reposition the whole solar system. Pause the orbits, change their animation speed, or use zoom buttons to see more detail.

An optional Three Wonders journey offers a short, satisfying visit: discover Earth's Moon, inspect Saturn's rings, then move the universe by its Sun and pause the orbits. Three stars and gentle original chimes mark discoveries. There is no timer or penalty, and you can return to free exploration at any time.

The side card can be grabbed across its free surface, with attached + / − controls for its distance. Planet-name buttons make small worlds easier to select. Recenter view and Reset scene help you restore a comfortable arrangement, and Exit ends the experience.

Planet sizes are proportional to NASA mean diameters. The Sun's size, orbital spacing and animation times are adapted for viewing; information cards provide the real astronomical values. Surfaces and spacecraft are original illustrations rather than photographic or engineering reproductions.

## How we built it

We used Godot 4, OpenXR and the Godot OpenXR Vendors plugin to build a standalone Android VR application. Lightweight geometry, procedural materials and static previews keep the content compact. Shared interaction logic supports both a desktop preview and hand-based XR use.

The experience runs locally, without an account or external content service. Tracking loss and system-menu interactions release held objects and guard against unintended input.

## What's next

We want to refine accessibility, visual clarity and hand interaction through more headset testing and feedback, then expand the guided discoveries while keeping each visit brief and comfortable.
