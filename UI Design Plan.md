# UI/UX Design Document — Unity-Grade Visual Interface
### Stylized Near-Future Sci-Fi Direction (URP Target)

| | |
|---|---|
| **Scope** | A standalone visual/interaction design bible for an application targeting AAA-comparable UI/UX polish |
| **Engine target** | Unity, **Universal Render Pipeline (URP)** — see the pipeline note below |
| **Aesthetic** | Stylized near-future sci-fi / technological realism |
| **Status** | Draft v1.0 — August 2026 |

> **Pipeline note:** this document targets URP specifically, not "URP or HDRP." As of Unity's 2026 render-pipeline strategy, URP is the actively-developed pipeline recommended for new projects of any genre, while HDRP is in maintenance mode (stability fixes and Nintendo Switch 2 support only, no new features). Every technique below — including material, lighting, and post-processing work that would once have implied HDRP — is scoped to what URP can deliver in the current cycle, including its newly-expanding dynamic lighting and Shader Graph capability.

---

## Table of Contents
1. [Mood Board & Style References](#1-mood-board--style-references)
2. [Visual Style Direction](#2-visual-style-direction)
3. [Layout and Composition](#3-layout-and-composition)
4. [Typography and Iconography](#4-typography-and-iconography)
5. [Interactive Elements](#5-interactive-elements)
6. [Background and Environmental Layers](#6-background-and-environmental-layers)
7. [HUD and Information Display](#7-hud-and-information-display)
8. [Animation and Motion Principles](#8-animation-and-motion-principles)
9. [Performance and Accessibility Considerations](#9-performance-and-accessibility-considerations)
10. [Technical Implementation Mapping](#10-technical-implementation-mapping)
11. [Implementation Roadmap: Prototype to Polish](#11-implementation-roadmap-prototype-to-polish)

---

## 1. Mood Board & Style References

No single existing title is being copied; the direction triangulates between three reference qualities, described here as text so this document stands alone without external images:

| Reference quality | What it contributes |
|---|---|
| **Holographic panel language** | Semi-transparent surfaces, bright Fresnel edge-glow, thin geometric line-work, information that feels projected rather than printed |
| **Emissive circuit/signal texture** | Slow-scrolling data-trace patterns for backgrounds and loading states — the sense of a system that's "alive" and processing, not a static image |
| **Brushed metal + rim light** | Physical surfaces behind the UI (world geometry, diegetic panels) read as real, lit materials — grounds the holographic elements in something tangible instead of everything floating on flat black |

**Core palette** (final swatches; every subsequent section reads colors from this table, never a one-off hex):

| Role | Hex | Usage |
|---|---|---|
| Base — deep space | `#0A0E1A` | Primary background, furthest depth layer |
| Base — panel surface | `#141B2E` | Mid-ground panels, cards |
| Primary accent — signal cyan | `#00D9FF` | Default interactive accent, holographic glow |
| Secondary — warning amber | `#FFB800` | Caution states, charging/loading fills |
| Tertiary — rare magenta | `#FF2E9A` | Rare/high-value elements only — used sparingly so it stays meaningful |
| Success | `#39FF9E` | Confirmations, positive state changes |
| Error | `#FF3B5C` | Errors, danger states |
| Text — primary | `#E8F4FF` | Body/label text on dark surfaces |
| Text — muted | `#7C8AA3` | Secondary/disabled text |

---

## 2. Visual Style Direction

### 2.1 Lighting Model
- **Primary lighting**: URP's Forward+ rendering path with baked lightmaps and real-time light probes for dynamic/moving elements — full real-time GI is deliberately avoided as a baseline requirement (Section 9 covers why), reserved as a High-tier-only enhancement using URP's emerging dynamic-GI work rather than assumed everywhere.
- **Volumetric lighting**: light shafts and fog-interaction light via URP's Volume system (High/Medium tiers only — see Section 9's tier table).
- **Image-based lighting**: reflection probes placed at key panel/prop locations so metallic and glass-like UI-adjacent materials pick up believable environment reflection instead of a flat specular dot.
- **Key/fill/rim three-point setup** for any character or entity presence in-frame, with the rim light specifically tuned to the signal-cyan accent — this is the single lighting choice that most reinforces "this world runs on the same light language as its UI."

### 2.2 Material Rendering Approach
- **PBR metallic/smoothness workflow** for all physical (non-UI) surfaces: albedo, metallic, smoothness, normal, and occlusion maps per material, authored so surfaces read correctly under the lighting model above without any baked-in fake highlights.
- **UI-specific "holopanel" shader**: an unlit-lit hybrid — unlit base color with an emission channel driven by a Fresnel Effect node (Shader Graph), producing the signature bright-edge/transparent-core holographic look. This shader is the single most-reused asset in the whole system; every glowing panel, health bar, and HUD frame is an instance of it with different tint/intensity parameters, not a bespoke shader per element.
- **Emission budget**: exactly one "hero" emissive element per screen region at full intensity at any time — everything else emits at 40-60% of hero intensity. Without this rule, an all-glowing UI reads as noisy rather than premium; the rule is what makes the one thing that matters (a new notification, a critical HUD state) actually stand out.

### 2.3 Color Grading
- **ACES tonemapping** as the base transform (URP's Volume-based color grading stack), with a single custom LUT layered on top for the game's specific mood — cooler shadows, slightly warm midtones, cyan-shifted highlights to reinforce the accent palette even in fully-lit scenes.
- **Post-processing stack**: Bloom (tuned to the emission budget above — bloom threshold set so only "hero" emissive elements actually bloom, not every UI line), subtle film grain (adds a rendered, non-flat-vector texture), vignette (light, environmental only — never applied over HUD-critical regions), chromatic aberration reserved exclusively for damage/error/glitch states, never as ambient flavor.
- **Tiering**: the full grading stack above is the High tier. Medium drops real-time volumetrics and reduces bloom passes; Low drops the custom LUT for a flat, cheaper color curve and disables film grain/chromatic aberration entirely (full breakdown in Section 9).

---

## 3. Layout and Composition

### 3.1 Depth-Based Layering
A fixed five-layer Z-model, used consistently across every screen so "depth" means the same thing everywhere rather than being reinvented per view:

| Layer | Contents | Parallax rate | Camera analogy |
|---|---|---|---|
| 0 — Deep background | Skybox / distant environment | 2-4% counter-offset to input | Far background plate |
| 1 — Mid background | Environmental silhouettes, blurred | 8-12% counter-offset | Mid-distance dressing |
| 2 — World-space diegetic | Entities, attached health bars, spatial prompts | Follows 3D camera directly (true perspective, not faked) | Actual scene geometry |
| 3 — HUD / screen-space | Menus, buttons, primary UI | Fixed to screen, zero parallax | Virtual "lens" plane |
| 4 — Foreground overlay | Modals, full-screen transitions, loading states | Fixed, renders above everything | Overlay/compositing pass |

### 3.2 Parallax
Background layers (0-1) shift a small, capped amount opposite to cursor position (desktop) or device tilt via gyroscope (mobile) — magnitudes fixed at the percentages in the table above. Capping matters more than the effect itself: uncapped parallax reads as loose/cheap, while a tight 2-12% range reads as deliberate depth without ever disorienting a menu the player is trying to read.

### 3.3 Camera-Like Transitions
Menu-to-menu navigation is modeled as a virtual camera move rather than a flat slide or cross-fade, borrowing Cinemachine's blend vocabulary even for what is ultimately 2D UI motion:
- **Push-in (dolly)**: selecting a submenu scales + perspective-warps the current view slightly away while the new panel scales in from a matching vanishing point — reads as "the camera moved forward through the selection," not "a new card slid over the old one."
- **Orbit**: used specifically for radial/carousel selections (world select, item categories) — the selected option swings toward center on a shallow arc rather than snapping.
- **Cut**: reserved for the loading-boundary transitions in Section 8 only — a hard cut anywhere else would break the "camera" illusion this whole layout model depends on.

Every transition in this section shares one timing/easing source (Section 8's curve library) so the "camera" always feels like the same physical rig, never a different speed/weight per screen.

---

## 4. Typography and Iconography

### 4.1 Typography
- **Typefaces**: `Exo 2` (headers, HUD labels) and `Rajdhani` (body/dense data readouts) — both genuinely-licensed geometric sans faces with the technical/HUD character this direction calls for, avoiding any single-title-associated custom font.
- **Rendering**: Signed Distance Field (SDF) text throughout, implemented via TextMeshPro — SDF is what makes the same text asset scale crisply from a small inventory tooltip to a full-screen title without ever shipping multiple font sizes as separate assets.
- **Glow**: TMP's built-in Underlay pass with an emission-tinted color (signal-cyan or context accent) and a soft dilate — not a separate bloom-only effect, since driving it through the text material itself keeps glow intensity consistent with the emission-budget rule in Section 2.2.
- **Outline**: TMP's native outline width/softness parameters, used specifically where text sits over variable-brightness backgrounds (world-space diegetic labels over the 3D scene) — the outline is what keeps those legible independent of what's behind them, which matters more once Section 9's contrast requirements are factored in.

### 4.2 Iconography
- **Consistent light source**: every icon in the set is authored as if lit from the same upper-left key light — this single discipline is what makes a large, multi-artist icon set read as one cohesive family rather than a pile of individually-nice icons.
- **Dimensional depth via three passes per icon**: a base normal-mapped bevel (or, for 2D-authored icons, a faked soft inner-shadow + highlight arc standing in for the bevel), a baked ambient-occlusion pass in the icon's crevices/inner edges, and a small bright specular highlight consistent with the shared light-source rule above.
- **Format**: authored at a high base resolution and packed into per-screen-family texture atlases (Section 10) — never scaled up from a low-res source, since the bevel/AO detail is exactly what falls apart first under upscaling.

---

## 5. Interactive Elements

### 5.1 Buttons
| State | Visual behavior | Duration |
|---|---|---|
| Default | Holopanel shader at 50% emission (Section 2.2 budget) | — |
| Hover | Fresnel rim brightens to 100%; a single scanline sweeps once across the button surface | 150ms lerp, one-shot sweep |
| Pressed | Scale to 0.96x; radial particle burst (6-10 particles, accent-tinted); synced haptic pulse | 80ms scale, burst plays independently |
| Focused (controller/keyboard nav) | Same as hover, plus a thin animated outline trace (see 5.3) so non-pointer navigation is never a visually dead state | persists while focused |
| Disabled | Desaturated to ~20% of the base palette, emission off entirely | — |

The pressed-state particle burst uses a lightweight CPU particle system (Shuriken, not VFX Graph — see Section 10) specifically because it needs to fire reliably from a UI event callback with near-zero latency; GPU-driven VFX Graph is reserved for denser, less latency-critical background effects.

### 5.2 Sliders & Toggles
- **Toggle knob travel**: a damped-spring curve with a slight overshoot (Unity `AnimationCurve` authored with overshoot tangents, or DOTween's `Ease.OutBack`) — never linear. Linear toggle motion is one of the fastest ways to make an otherwise-premium UI feel like a default component.
- **Toggle track fill**: an emissive color wipe from off-state to on-state color, timed to finish slightly before the knob completes its travel — the fill "arriving first" is a small but consistent anticipation cue.
- **Slider fill**: rendered as a "charge meter" — the filled portion carries a subtle particle trail at its leading edge while actively being dragged, which stops the instant the drag ends (a trail that persists after release reads as a bug, not a feature).

### 5.3 Input Fields
- **Focus state**: an animated border trace — a line that draws itself around the field's perimeter over ~200ms (implemented as a fill-amount/dissolve parameter on a border shader, or a segmented `Image.fillAmount` trick), reinforcing the "system powering on to accept input" language used everywhere else in this direction.
- **Invalid input**: a brief chromatic-aberration pulse plus a color shift to the warning-amber accent — deliberately using the one context (Section 2.3) where chromatic aberration is allowed, so its rarity elsewhere makes it register as "something's wrong" instantly.

### 5.4 Physically-Based Animation Curves
A small, named, reused curve library — every interactive element pulls from this set rather than a hand-tuned one-off per component:

| Curve | Shape | Used for |
|---|---|---|
| `EaseOutBack` | Overshoot past target, settle back | Confirmations, toggle knobs, celebratory reveals |
| `EaseInOutCubic` | Symmetric accelerate/decelerate | Standard panel transitions |
| `EaseInOutSine` | Gentle, no hard start/stop | Idle/ambient loops (background shader drift, breathing glow) |
| `Anticipation` (custom) | 10-15% pull opposite the main motion for ~80ms, then main ease | Any primary button press — see the worked example in Section 8 |

### 5.5 Haptic-Responsive Feedback
Every particle-burst or state-confirmation moment above carries a paired haptic event, triggered on the same frame as the visual peak (not the start) — e.g. the button-press haptic fires at the burst's spawn frame, not at the initial 0.96x-scale-down frame, so the felt pulse lines up with the moment that reads as "impact" rather than the moment that reads as "wind-up."

---

## 6. Background and Environmental Layers

### 6.1 Animated Shader Backgrounds
A procedural Shader Graph background — layered Simplex noise scrolling over time (`_Time.y`-driven UV offset) generating a slow circuit/data-trace pattern, composited with a parallax starfield or drifting particle field. Fully procedural rather than a looping video texture or animated sprite sheet: procedural costs less memory, never shows a visible loop seam, and can be parameter-driven by the states below rather than being a fixed asset.

### 6.2 Dynamic Lighting
A lighting-preset lerp system rather than true real-time-everything: 2-3 authored lighting presets (e.g. "calm," "tense," "critical") blended via a single float parameter driven by application state — tied to narrative/session progress rather than literal wall-clock time of day, since that's the more meaningful axis for most interactive applications. Real wall-clock time-of-day lighting is a reasonable variant if the application has a genuine day/night structure, using the same lerp mechanism against a 0-24 float instead.

### 6.3 Fog Density Shifts
Volumetric fog density (URP Volume system, Fog override) driven by the same state parameter as 6.2 — thickening subtly during high-tension moments, clearing during calm/success states. Density changes are capped to a narrow range (never full whiteout, never fully clear) so the shift reads as atmospheric rather than as a visibility problem.

### 6.4 Environmental Storytelling
Background objects that react to nearby interaction rather than sitting inert: ambient screens/terminals in the environment flicker to life or display a relevant data snippet when the player completes a nearby action, and small "world is alive" details (a passing light, a distant flicker) fire on a randomized idle-timer long enough that they never feel like they're on a visible loop. These are explicitly non-blocking flavor — they never gate progress and never demand attention away from the primary task.

---

## 7. HUD and Information Display

### 7.0 The Four HUD Categories (framing for everything below)
Game-UI design draws a standard distinction worth stating explicitly, since it decides where every element in this section actually lives:

| Category | Exists in-world? | Visible to the in-world character? | Example here |
|---|---|---|---|
| **Diegetic** | Yes | Yes | An entity's health readout, rendered as a physical panel on the entity itself |
| **Non-diegetic** | No | No | A traditional corner health bar overlay |
| **Meta** | Represented in-world, not spatial | Indirectly | Screen-edge color shift signaling low health |
| **Spatial** | Yes | Not necessarily | An off-screen waypoint arrow |

This plan leans diegetic wherever it doesn't cost readability, and falls back to non-diegetic/meta only where a purely spatial solution would be unreliable (Section 9 covers exactly when that fallback triggers).

### 7.1 Diegetic Health Bars
Rendered as a World Space Canvas parented to the entity's transform and billboarded to face the camera — this is what lets the bar move, scale with distance, and get correctly occluded by scene geometry the same way any other object would, rather than being faked as a screen-space overlay that happens to track a position.

### 7.2 Radial Menus with 3D Depth
Options sit on a shallow arc in world/panel space rather than a flat circle: the option nearer the "front" of the arc renders slightly larger and closer, with a subtle depth-of-field falloff on the others. Selection swings the chosen option toward center using the Orbit transition from Section 3.3, keeping the whole system consistent with the layout model rather than being a one-off widget with its own motion language.

### 7.3 Spatial Inventory Grids
Grid slots are recessed (inset shadow, reinforcing the "physical container" read) and items render as small pre-lit 3D captures rather than flat icon sprites — each item rendered once to a small RenderTexture under the same three-point lighting rig used everywhere else (Section 2.1), then displayed as that texture in the grid. This is what makes inventory items look like objects sitting in the world rather than stickers pasted over it.

### 7.4 Proximity-Based Contextual Prompts
Prompt opacity is a function of player-to-interactable distance rather than a binary show/hide — a near-linear falloff between a "fully visible" and "fully hidden" threshold, recalculated on a throttled interval (not every frame) for performance. Below the fully-hidden threshold the prompt unloads its Canvas entirely rather than sitting invisibly, since an invisible-but-active Canvas still costs a batch.

### 7.5 What Stays Non-Diegetic
A few elements are deliberately kept non-diegetic/meta rather than pushed into the world, because reliability matters more than immersion for them specifically: critical failure/error states (Section 5.3's invalid-input treatment), and any HUD element the player needs to reference while looking somewhere else in the scene. Diegetic placement is a tool for immersion, not a rule applied unconditionally — Section 9 states the readability floor that governs this trade-off.

---

## 8. Animation and Motion Principles

### 8.1 Ease Curve Library
Section 5.4's curve set is the whole system's motion vocabulary — restated here as the authoring rule: every curve is built as a reusable `AnimationCurve` asset or DOTween `Ease` preset, referenced by name, never hand-tuned per instance. A team hand-tuning "close enough" curves per component is the single most common way a UI ends up feeling inconsistent even when every individual animation looks fine in isolation.

### 8.2 Screen-Space Effects for Scene Changes
- **Radial wipe**: a Shader Graph full-screen effect driven by a single `_Progress` float (0-1), used for major scene/world transitions.
- **Chromatic pulse + brief motion blur**: reserved for "teleport"-style instant transitions, paired with the Cut transition from Section 3.3.
- **Letterbox bars**: in/out over ~300ms for cinematic/narrative beats, signaling "this is a scripted moment" distinctly from normal navigation.

### 8.3 Loading Sequences Embedded in Environmental Objects
Rather than a generic progress bar, the loading indicator is a diegetic object in the scene — e.g. a reactor or terminal whose emission mask fills as the real asset-load progress (an actual 0-1 float from the loading pipeline, not a simulated timer) drives its shader parameter directly. The object reaching "full charge" and the assets actually being ready are the same event, which avoids the common failure mode of a decorative loading animation that finishes before the content is actually available.

### 8.4 Micro-Interactions: Anticipation - Action - Reaction
Every primary interaction follows the three-beat structure explicitly, not just "an ease-in-out." Worked example — a primary confirm button:

```
ANTICIPATION  (80-100ms)   Button compresses 2-3% opposite the press direction
                           Anticipation curve (5.4), signals "about to respond"
        |
        v
ACTION        (120-150ms)  Scale snaps to 0.96x, EaseOutBack curve
                           Particle burst spawns, haptic fires at burst peak
        |
        v
REACTION      (200-300ms)  Scale settles back to 1.0x with slight overshoot
                           Secondary confirmation (sound, brief emission pulse)
```
This three-beat shape — not any single easing curve — is what the "physically-based" feel in the brief actually comes from; a single well-chosen curve on its own still reads as flat without the anticipation and reaction beats framing it.

---

## 9. Performance and Accessibility Considerations

### 9.1 Frame Rate Targets & Quality Tiers
Baseline target is 60fps on mid-tier+ hardware, with 30fps as an acceptable floor on low-tier devices — enforced via three URP-asset-driven quality tiers rather than one universal setting:

| Tier | Lighting | Fog / Volumetrics | Particles | Post-processing |
|---|---|---|---|---|
| **High** | Light probes + reflection probes + volumetric light shafts | Full volumetric fog (Section 6.3) | Full density, VFX Graph active | Full stack: bloom, LUT grading, film grain |
| **Medium** | Light probes only, no volumetrics | Simple distance fog, no volumetric shafts | Reduced particle count, VFX Graph capped | Bloom + LUT, no film grain/chromatic aberration |
| **Low** | Baked lighting only | Flat distance fog | Sprite-flash substitutes instead of particle systems | Base color curve only, full stack disabled |

Tier assignment is an explicit user-facing setting with an "Auto" default that benchmarks on first launch — never a silent, undisclosed downgrade, since a player noticing the game "looks worse than the screenshots" without knowing why is a worse experience than a game that's honest about running in a lower tier.

### 9.2 Readability Floor (non-negotiable regardless of tier or stylistic effect)
- Critical text/icons maintain WCAG AA-equivalent contrast against their *immediate* backing, independent of whatever bloom/glow sits behind them — enforced by giving critical HUD text its own subtle backing scrim (10-20% black) or a guaranteed outline pass (Section 4.1), never by hoping the background stays dark enough.
- Bloom/glow renders on a layer that composites *behind* critical text, never in a way that can wash it out — this is a render-order rule (Section 10), not just an art-direction intention.
- The colorblind-safe rule already established for data displays elsewhere in this system (state conveyed by shape/icon, never color alone) applies identically to every HUD status indicator here — health, hint costs, error states.
- `MediaQuery`/OS-level reduced-motion equivalents (Unity: a project-level accessibility setting) disable every non-essential animation in Sections 5 and 8, substituting a plain cut or fade — checked once, centrally, not per-effect.

---

## 10. Technical Implementation Mapping

### 10.1 Element-to-Tool Map

| Plan element | Primary tool | Notes |
|---|---|---|
| Menus, inventory, radial menus (screen-space) | **UI Toolkit** (UI Documents + USS) | The modern, data-driven system — now gaining native world-space UI, custom shaders, and vector graphics this cycle, which narrows the gap with uGUI below |
| Diegetic world-space HUD (health bars, spatial prompts) | **UI Toolkit's new world-space UI** where available; **uGUI World Space Canvas** as the proven fallback | Both are viable as of the current cycle; uGUI remains the more battle-tested path if UI Toolkit's world-space feature is still maturing when implementation starts — worth a short spike to confirm before committing one way for the whole project |
| Holopanel material, Fresnel rim, emissive glow | **Shader Graph** (URP) | Unlit-lit hybrid per Section 2.2; Shader Graph's current UI-template additions are a direct fit |
| Particle bursts (buttons, low-latency UI feedback) | **Shuriken** (built-in particle system) | Chosen specifically for callback-triggered reliability, not visual ceiling |
| Environmental/background particles, dense effects | **VFX Graph** | GPU-driven, for anything with hundreds of particles or physical simulation the CPU system shouldn't own |
| Text (glow, outline, SDF scaling) | **TextMeshPro** | Native SDF rendering, built-in outline/underlay |
| Screen-space transitions, color grading, bloom, fog | **URP Volume system** | One Volume Profile per quality tier (Section 9.1), swapped or blended at runtime |
| Animation curves & sequencing | **Unity Animator** for state-driven UI, **DOTween** for one-off tweened micro-interactions, **Timeline** for scripted/cinematic sequences | DOTween specifically because authoring every Section 5/8 micro-interaction as a full AnimationClip is disproportionate overhead for high-frequency polish work |
| Item render-to-texture (spatial inventory) | Secondary camera + `RenderTexture` per item archetype | Rendered once and cached, not re-rendered every frame |

### 10.2 Render Order
UI content renders in its own **camera stack layer (URP Overlay camera)** above the base 3D scene camera. This is what lets world-space diegetic elements (Section 7) still be correctly occluded by 3D geometry — a health bar behind a wall doesn't show through — while pure screen-space HUD (Section 3's Layer 3-4) always composites on top regardless of scene depth. Bloom/glow post-processing is scoped to the base scene camera's stack so it never bleeds over the top-most HUD layer in a way that would violate Section 9.2's readability floor.

### 10.3 Draw Call Optimization
- Shared materials with per-instance `MaterialPropertyBlock` for tint/intensity variation (button accent color, health-bar fill level) instead of a unique material per instance — this is what keeps hundreds of holopanel-shader instances from becoming hundreds of draw calls.
- UI Toolkit and uGUI both batch aggressively when elements share a texture/material; the practical rule is simply not breaking that sharing unnecessarily.
- Particle systems (Shuriken) triggered from UI share a single pooled system per burst *type*, not a new GameObject instantiated per press.

### 10.4 Texture Atlas Strategy
One atlas per screen-family rather than one mega-atlas for the whole application: e.g. all Main Menu icons/buttons in one 2048x2048 atlas, all in-HUD icons in a separate one. This balances the draw-call benefit of atlasing against memory residency — a single mega-atlas would force the entire icon set resident in memory even when only a handful of icons from it are ever on screen at once. Built via Unity's Sprite Atlas system for uGUI/2D content, referenced through USS `background-image` for UI Toolkit content.

---

## 11. Implementation Roadmap: Prototype to Polish

> Each phase has an explicit exit criterion — this is deliberately ordered so the expensive/slow work (shaders, VFX polish) never starts before the cheap/fast work (information architecture, layout) is validated. Building Phase 4 material polish onto a HUD layout that later needs to change is the single most common way this kind of visual ambition runs over budget.

| Phase | Focus | Exit criterion |
|---|---|---|
| **0 — Style Prototype** | Validate the lighting model and holopanel shader (Section 2) on primitive shapes, no final art | The core material/lighting language is approved before a single final asset is built on top of it |
| **1 — Core HUD Functional Pass** | Every screen exists with correct information and layout (Section 3), using flat non-diegetic placeholders — no shaders, no particles yet | The application is fully navigable and legible in "programmer art" |
| **2 — Material & Shader Pass** | Apply the holopanel/PBR material language (Section 2, 4.1) to real components | Every screen matches the Section 1 mood board without any motion yet |
| **3 — Motion & Micro-interaction Pass** | Apply the curve library and anticipation-action-reaction structure (Sections 5, 8) to every interactive element | Every button/toggle/slider passes the Section 8.4 three-beat structure check |
| **4 — Environmental & Diegetic Integration** | World-space HUD, environmental storytelling, dynamic lighting/fog (Sections 6, 7) | Diegetic elements are in place and the Section 7.5 non-diegetic fallback list is confirmed correct |
| **5 — Performance Tiering** | Build and benchmark the three quality tiers (Section 9.1) on representative low/mid/high hardware | 60fps sustained on mid-tier target hardware in the Medium tier |
| **6 — Accessibility Pass** | Contrast audit, reduced-motion pass, colorblind-safe verification (Section 9.2) | Every critical HUD element independently passes a contrast check with all stylistic effects active |
| **7 — Final Polish** | VFX Graph particle refinement, LUT/color-grade finalization, overall "juice" pass | No further scope added — this phase only tunes what already exists |

Phases 0-1 are the only ones that gate everything downstream; from Phase 2 onward, several phases can run in parallel across different screens once the shared systems (shader library, curve library, tier system) they all depend on are locked.

---

*End of document. This plan is intentionally engine-and-project-agnostic beyond its URP target — if useful, the same structure (mood board, palette, layered depth model, curve library, tier table) can be re-run scoped specifically to Query's Flutter implementation, translating each Unity-native technique to its Flutter-appropriate equivalent.*
