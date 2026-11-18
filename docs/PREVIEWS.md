# Preview images

`assets/previews/*.png` are original static renders of this project's own procedural planet/spacecraft models, generated with `scripts/render_previews.gd` using Godot. They are model previews, not NASA photos or astronomical observations. Saturn includes its rings; each planet uses the same material family as the main scene. The Sun has an illustrative procedural surface. The sizes in each preview are normalized for clarity.

There are 12 images: Sun, eight planets, Moon, ISS and Hubble. No external models, logos or photos were downloaded. Source definitions for the spacecraft remain documented in `EARTH_COMPANIONS.md`.

The shipped app loads static textures. The information card's 2D viewport redraws only when content, hover or control status changes; no second 3D scene is rendered for its preview during normal use.

Version 0.5.0 correction: preview generation now awaits completed GPU draws before saving each model. All previews were regenerated. Sun is explicitly preloaded by the card and its orange center is checked in the interaction tests.
