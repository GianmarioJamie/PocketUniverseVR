# Planet data and visual scale

Data verified on 16 November 2026 against NASA's planetary fact sheets and NASA Science. `data/planets.json` is an array in order from Mercury to Neptune. English facts are short original paraphrases, not quotations. No third-party images, logos or models are included.

## Definitions

- `diameter_km`: twice the **volumetric mean radius** in the individual NASA fact sheet. This convention is consistent across all eight planets and suitable for the spherical meshes. It is not the equatorial diameter used by NASA's summary comparison table.
- `radius_ratio_earth`: `diameter_km / 12742.0`, rounded to nine decimal places. Apply one common radius multiplier to preserve relative planetary sizes.
- `distance_million_km`: orbital **semimajor axis**, in millions of kilometers; an approximate average Sun distance for a compact card. It is not the planet's current distance.
- `orbital_period_days`: **sidereal orbital period**, measured in Earth days. The summary comparison table uses tropical periods, which differ noticeably for the outer planets. Use these individual-sheet values consistently.
- `color`: an artistic UI/material color chosen for visibility; it is not a calibrated scientific surface-color measurement. Neptune is kept pale blue rather than using the highly enhanced dark blue of familiar Voyager images.

## Numeric sources

| Planet | Mean diameter (km) | Semimajor axis (million km) | Sidereal period (Earth days) | Source |
| --- | ---: | ---: | ---: | --- |
| Mercury | 4,879.4 | 57.909 | 87.969 | [NASA Mercury fact sheet](https://nssdc.gsfc.nasa.gov/planetary/factsheet/mercuryfact.html) |
| Venus | 12,103.6 | 108.210 | 224.701 | [NASA Venus fact sheet](https://nssdc.gsfc.nasa.gov/planetary/factsheet/venusfact.html) |
| Earth | 12,742 | 149.598 | 365.256 | [NASA Earth fact sheet](https://nssdc.gsfc.nasa.gov/planetary/factsheet/earthfact.html) |
| Mars | 6,779 | 227.956 | 686.980 | [NASA Mars fact sheet](https://nssdc.gsfc.nasa.gov/planetary/factsheet/marsfact.html) |
| Jupiter | 139,822 | 778.479 | 4,332.589 | [NASA Jupiter fact sheet](https://nssdc.gsfc.nasa.gov/planetary/factsheet/jupiterfact.html) |
| Saturn | 116,464 | 1,432.041 | 10,755.699 | [NASA Saturn fact sheet](https://nssdc.gsfc.nasa.gov/planetary/factsheet/saturnfact.html) |
| Uranus | 50,724 | 2,867.043 | 30,685.400 | [NASA Uranus fact sheet](https://nssdc.gsfc.nasa.gov/planetary/factsheet/uranusfact.html) |
| Neptune | 49,244 | 4,514.953 | 60,189.018 | [NASA Neptune fact sheet](https://nssdc.gsfc.nasa.gov/planetary/factsheet/neptunefact.html) |

See [NASA definitions for individual fact sheets](https://nssdc.gsfc.nasa.gov/planetary/factsheet/fact_notes.html) for measurement conventions.

## Short fact sources

- Mercury: [NASA Mercury facts](https://science.nasa.gov/mercury/facts/), introduction.
- Venus: [NASA Venus facts](https://science.nasa.gov/venus/venus-facts/), introduction and atmosphere.
- Earth: [NASA Earth facts](https://science.nasa.gov/earth/facts/), surface.
- Mars: [NASA Mars facts](https://science.nasa.gov/mars/facts/), largest volcano.
- Jupiter: [NASA Jupiter facts](https://science.nasa.gov/jupiter/jupiter-facts/), introduction.
- Saturn: [NASA Saturn facts](https://science.nasa.gov/saturn/facts/), rings.
- Uranus: [NASA Uranus facts](https://science.nasa.gov/uranus/facts/), orbit and rotation.
- Neptune: [NASA Neptune facts](https://science.nasa.gov/neptune/neptune-facts/), atmosphere, including the discussion of color-enhanced Voyager images.

## Presentation contract

Keep planetary sphere radii proportional to the supplied mean diameters. Reduce the Sun independently and compress orbital spacing so the miniature fits in front of a seated viewer. Circular orbits and chosen initial phases are illustrative, not present-day ephemerides. Invisible selection targets can be larger than the planet meshes. Enlarged inspection views should be clearly indicated.

Suggested visible note: **“Planet sizes are proportional. Sun size, orbit spacing and time are adapted for exploration.”** If all orbital speeds retain the true ratios under one common time multiplier, replace the final clause with **“Time is accelerated.”** Do not claim physical accuracy for an independently sped-up set of orbit animations.

## Sun (version 0.3.0)

https://science.nasa.gov/sun/facts/ — about 4.5 billion years old, mainly hydrogen and helium, about 150 million km from Earth. Educational description of gravity and energy paraphrased from NASA. Sun size in the scene is reduced.
