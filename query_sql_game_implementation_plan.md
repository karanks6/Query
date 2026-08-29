# Query — Implementation Plan
### A Flutter Educational Game for Learning SQL Through Play

| | |
|---|---|
| **Document type** | Game & Technical Design Document (GDD + TDD) |
| **Prepared for** | Development team / AI coding agents (Claude Code, Antigravity) |
| **Platforms** | iOS, Android (MVP) → Web, Desktop (later phases) |
| **Engine** | Flutter (stable channel, currently 3.44.x) / Dart 3.10+, sound null safety |
| **Status** | Draft v1.0 |
| **Last updated** | August 2026 |

> **How to use this document:** each of the 12 sections is self-contained enough to hand to a coding agent as a standalone brief. Section numbers map to the implementation phases in Section 9. Appendix A contains a suggested repo structure and first-sprint ticket breakdown for an agent starting from an empty project.

---

## Table of Contents
1. [Game Overview and Core Concept](#1-game-overview-and-core-concept)
2. [Game Features](#2-game-features)
3. [Game Rules and Mechanics](#3-game-rules-and-mechanics)
4. [Level and Curriculum Design](#4-level-and-curriculum-design)
5. [Screen-by-Screen UI Specification](#5-screen-by-screen-ui-specification)
6. [UI Themes and Visual Design System](#6-ui-themes-and-visual-design-system)
7. [Database and Backend Architecture](#7-database-and-backend-architecture)
8. [Technical Implementation Stack](#8-technical-implementation-stack)
9. [Development Phases and Milestones](#9-development-phases-and-milestones)
10. [Monetization and Business Model](#10-monetization-and-business-model)
11. [Success Metrics and Analytics](#11-success-metrics-and-analytics)
12. [Risk Mitigation and Future-Proofing](#12-risk-mitigation-and-future-proofing)
- [Appendix A: Agent Implementation Quick-Start](#appendix-a-agent-implementation-quick-start)
- [Appendix B: Glossary](#appendix-b-glossary)

---

## 1. Game Overview and Core Concept

### 1.1 Mission
**Query** teaches real, transferable SQL — the same SELECT/JOIN/subquery skills used against production databases — through a self-contained narrative game rather than a quiz app with a database theme bolted on. Every mechanic (drag-to-build queries, schema browsing, boss-level cases) exists to make a genuine SQL skill click, not just to gate content behind a game shell.

### 1.2 Target Audience
| Segment | Description | SQL starting point |
|---|---|---|
| **Primary — Students** | CS/IT/MCA students taking a databases course who want a companion tool that makes practice stick | Zero to "I've seen SELECT before" |
| **Primary — Self-taught / bootcamp learners** | People learning SQL for a career switch into data/analytics/backend roles | Zero to basic |
| **Secondary — Working professionals** | PMs, analysts, junior devs who know *some* SQL and want to get comfortable with JOINs, subqueries, window functions | Intermediate |
| **Secondary — Educators** | Teachers/TAs who want a gamified assignment tool for a databases module | N/A — uses Classroom Mode, Section 2.4 |

Query is explicitly scoped for **beginners through intermediate**: it takes a player from "what is a table" to comfortably writing multi-join queries with window functions. It does not attempt to teach DBA-level administration, production-scale query tuning, or dialect-specific enterprise features.

### 1.3 Unique Value Proposition
Most SQL-learning products fall into two buckets: browser-based "type SQL into a box" tutorials, or generic coding-quiz apps that treat SQL as just another quiz category. Query is positioned differently:

- [ ] **Actually a game, not a quiz with SQL flavor** — persistent narrative, characters, a world map, and boss encounters, not a linear list of questions
- [ ] **Native mobile-first, offline-capable** — practice on a commute with no browser tab and no internet required, unlike most web-only competitors
- [ ] **Progressive construction, not blank-page anxiety** — block-based query building removes syntax-error frustration for true beginners, then transitions to a real code editor as skill grows
- [ ] **Efficiency is graded, not just correctness** — most competitors only check "did you get the right rows"; Query also scores *how* you got there, building query-optimization instincts early
- [ ] **Boss levels force synthesis** — concepts aren't learned in isolation and forgotten; every world ends with a case that mixes everything learned so far

### 1.4 Pedagogical Approach
Query follows an **I do → We do → You do → You teach** scaffold, mapped directly onto level types (full definitions in Section 4.2):

1. **Concept Card** *(I do)* — a short, example-driven explanation of a new clause/keyword before it's ever required in a puzzle
2. **Tutorial Level** *(We do)* — a guided, can't-fail level in Block Mode that walks the concept step-by-step
3. **Puzzle Level** *(You do)* — an independent challenge applying the concept, with hints available
4. **Debugging / Optimization Level** *(You refine)* — given a working-but-flawed query, find the bug or improve its efficiency; this is where understanding gets tested, not just recall
5. **Boss Level** *(You teach / synthesize)* — a multi-concept capstone case requiring everything learned in that world, written in free-type Code Mode

Two learning-science principles are load-bearing throughout:
- **Spaced repetition by design** — every world's boss level, and later worlds' puzzles, deliberately reuse earlier concepts (e.g. a World 4 JOIN puzzle still requires the WHERE-clause filtering taught in World 2) rather than "graduating" a concept and never touching it again.
- **Immediate, explained feedback** — every query execution returns a result *and* a plain-English interpretation of what happened, right or wrong (full spec in Section 3.3). Silence between action and feedback is the single biggest churn risk in a learning game.

### 1.5 Narrative Theme: "The Query Bureau"
Query frames every mechanic inside a detective/investigation narrative:

> You're the newest recruit at **The Query Bureau**, an agency that solves cases by interrogating data. Each case is a different client with their own database — a record label's catalog, a hospital's (fictional, anonymized) patient logs, a space agency's mission archive — and the only tool you have is SQL.

- **Mentor — "Ada"**: guides Worlds 1–3, appears in Concept Cards and tutorial levels; named as a light nod to Ada Lovelace.
- **Antagonist — "The Corruptor"**: a recurring entity that scrambles client databases (broken constraints, malformed data, dropped relationships), directly motivating **Debugging Levels** — you're not just practicing syntax, you're undoing sabotage.
- **World = Case File**: each of the 10 worlds (Section 4) is a new client with a themed sample schema, giving natural variety without breaking the throughline.
- **Boss Level = "Case Closed"**: the climactic query (or short sequence of queries) that cracks that world's central mystery and unlocks the next case file.

This framing does real pedagogical work, not just flavor: it gives a reason for schema variety (new client = new schema = transferable skill, not memorized table names), a reason for debugging levels to exist (sabotage, not "gotcha" bugs), and a natural difficulty ramp (bigger cases mean more tables and more complex queries).

---

## 2. Game Features

### 2.1 Core Gameplay Features
- [ ] Hybrid query construction: **Block Mode** (drag-and-drop clause blocks) and **Code Mode** (real text editor), toggleable wherever a level allows it
- [ ] Real-time query execution against an isolated, sandboxed sample database per level
- [ ] Puzzle progression with branching, non-blocking hint paths
- [ ] Three-tier hint system: *Nudge → Partial Reveal → Full Solution* (cost structure in Section 3.4)
- [ ] Sandbox / free-play mode with importable custom schemas
- [ ] Schema browser panel: mini entity-relationship view plus a searchable table/column inspector
- [ ] Per-level query history with undo/redo
- [ ] Optional "Assist Mode" that suggests the next clause for stuck players without solving the puzzle for them

### 2.2 Learning Features
- [ ] Contextual **Concept Card** shown automatically the first time a new keyword/pattern is required
- [ ] Searchable, tap-to-insert **SQL Syntax Reference** (in-app documentation, Section 5.14)
- [ ] **Common Mistakes** library — keyed to detected error *patterns*, not raw error strings (e.g. "used `=` with NULL" resolves to an explainer on `IS NULL`, not a raw SQLite parser error)
- [ ] **Real-World Scenario Mapping** — every concept card includes a "where you'd actually use this" example
- [ ] Plain-English + technical glossary (Appendix B seeds the initial content)
- [ ] **Concept Mastery Tracker** — flags concepts a player struggles with (high hint-use, low first-attempt success) for extra spaced-repetition exposure in later worlds

### 2.3 Gamification Features
- [ ] XP and Detective Rank progression (world-completion ranks defined in Section 4.3)
- [ ] Daily streak counter with a limited **Streak Freeze** item
- [ ] Achievement/badge system across three axes: **skill** (e.g. "solved a 4-table JOIN unaided"), **exploration** (e.g. "tried every hint type"), and **speed** (Time Medals, Section 4.3)
- [ ] **Daily Challenge** — one rotating puzzle per day, bonus XP/currency, resets a global leaderboard
- [ ] Optional **Speed Query** replay mode on any completed level, for a time-based bonus
- [ ] Cosmetic unlocks: visual themes (Section 6), avatar frames, mascot skins
- [ ] World-completion trophies and title progression ("Junior Analyst" → "Field Detective" → "Senior Investigator" → "Bureau Chief")

### 2.4 Social Features
- [ ] Shareable results card (auto-generated image summarizing a solved query and stats)
- [ ] Asynchronous **Friend Challenges** — send a specific puzzle, compare attempts/efficiency/time
- [ ] **Community Solutions** board — see alternate valid queries other players used for a level, upvote, report; moderated (Section 12.3)
- [ ] Global, friends, and weekly-reset **Leaderboards**
- [ ] **Classroom Mode** — a teacher/TA can assign specific worlds and see aggregate, non-individually-shaming class progress

---

## 3. Game Rules and Mechanics

### 3.1 Query Construction
Two coexisting modes, not a sequential replacement of one by the other:

| Mode | Description | Available |
|---|---|---|
| **Block Mode** | Draggable clause blocks (`SELECT`, `FROM`, `WHERE`, `JOIN`, `GROUP BY` …) snap together in valid order; blocks accept typed values/column names via dropdowns pulled from the level's live schema | Default for Worlds 1–2; optional through World 6 |
| **Code Mode** | A real text editor with SQL syntax highlighting, schema-aware autocomplete, and inline linting | Unlocked from World 2 onward; **mandatory** for Boss Levels from World 4 onward |

Players can toggle modes freely on any level that permits both, so a player ready to "graduate" to typing isn't held back, and a player who wants the safety net of Block Mode for a hard concept isn't forced out of it early.

### 3.2 Validation Rules (Four-Layer Pipeline)
1. **Syntax layer** — the query is parsed against SQL grammar; malformed queries fail fast with a pointer to the exact broken token, not just "syntax error"
2. **Semantic layer** — referenced tables/columns are checked against the level's live schema; type compatibility is checked (e.g. comparing a `TEXT` column to an integer literal is flagged before execution)
3. **Result layer** — the query executes against the sandboxed instance and the result set is diffed against the level's canonical expected output (row order only matters when the puzzle requires `ORDER BY`)
4. **Performance layer** *(active from World 3 onward)* — `EXPLAIN QUERY PLAN` output is parsed to detect full table scans where an index/seek was expected, redundant joins, and unnecessary subqueries, feeding the efficiency star (Section 4.3)

### 3.3 Feedback Loop
```
Player runs query
   |
   v
Syntax OK? --No--> Inline underline + plain-English fix suggestion
   | Yes
   v
Semantic OK? --No--> "Common Mistakes" card matched to the specific error pattern
   | Yes
   v
Execute against sandbox --> Results table renders (color-coded: match / extra / missing)
   |
   v
Result matches expected? --No--> Diff summary ("you returned 12 rows, expected 8 -- check your WHERE")
   | Yes
   v
Performance check --> Star-rating breakdown + optional "fewer scans?" nudge
```
Every error string coming out of the underlying SQLite engine is translated through the Common Mistakes lookup table before it reaches the player — raw engine errors (e.g. `ambiguous column name`) are never shown unexplained.

### 3.4 Attempts, Hints, and Penalties
Query deliberately avoids hard "lives" that lock a struggling learner out of practicing — that's bad pedagogy in an educational product. Instead:

- **Unlimited retries, always.** Failure never blocks further attempts.
- A per-level **Confidence Meter** starts full and dips slightly with each failed attempt; it affects the *First-Attempt* star (Section 4.3) but never blocks retrying.
- **Hints cost Insight Points** (soft in-game currency earned through normal play), *except* a free "grace hint" unlocks automatically after 3 failed attempts on the same level, so a stuck learner is never paywalled out of help.
- Hint tiers: **Nudge** (points to the relevant clause, no code shown) → **Partial Reveal** (fills in one clause) → **Full Solution** (shown only after both prior tiers have been used; using it caps that level's rating at 1 star, completion-only).

### 3.5 Difficulty Scaling
Difficulty scales by concept dependency, not just level number — every world assumes mastery of every prior world's *core* concept (not every optional one): `SELECT`/`FROM` (W1) → `WHERE`/`ORDER BY` (W2) → `GROUP BY`/aggregates (W3) → JOINs (W4) → subqueries (W5) → `INSERT`/`UPDATE`/`DELETE` (W6) → schema/DDL (W7) → window functions/CTEs (W8) → optimization (W9) → mixed-mastery capstone (W10). Full map in Section 4.1.

---

## 4. Level and Curriculum Design

### 4.1 World Map (10 Worlds, 172 Levels)

| # | World (Case File) | Core SQL Concepts | Levels | Sample Client Schema |
|---|---|---|---|---|
| 1 | **The Archive Vaults** | `SELECT`, `FROM`, column aliasing, `LIMIT`, `DISTINCT` | 15 | A small record store's inventory |
| 2 | **Filter District** | `WHERE`, comparison/logical operators, `ORDER BY`, `NULL` handling | 16 | A city's lost-and-found registry |
| 3 | **The Aggregation Exchange** | `GROUP BY`, `HAVING`, `COUNT`/`SUM`/`AVG`/`MIN`/`MAX` | 18 | A stock exchange's trade ledger |
| 4 | **Junction City** | `INNER`/`LEFT`/`RIGHT`/`FULL JOIN`, self-joins, `UNION` | 22 | A ride-share company's trips & drivers |
| 5 | **The Nested Depths** | Scalar & correlated subqueries, `EXISTS`, `IN`, `ANY`/`ALL` | 20 | A university's enrollment records |
| 6 | **Data Forge** | `INSERT`, `UPDATE`, `DELETE`, transactions, constraints | 16 | A warehouse inventory system |
| 7 | **Blueprint Bureau** | `CREATE TABLE`, keys, normalization, `ALTER TABLE`, indexes | 15 | Designing a schema from scratch for a new client |
| 8 | **The Function Foundry** | Window functions (`ROW_NUMBER`, `RANK`, `PARTITION BY`), CTEs, recursive CTEs | 20 | A sports league's season stats |
| 9 | **Optimization Observatory** | Query plans, indexing strategy, rewriting for performance | 15 | A social platform's activity feed at scale |
| 10 | **The Grand Archive** *(Capstone)* | Mixed mastery + dialect awareness (SQLite/PostgreSQL/MySQL differences) | 15 | The Bureau's own case archive — the final confrontation with The Corruptor |

*(World and level counts are a v1.0 baseline. Section 12.1 covers how new worlds/levels ship post-launch without breaking existing save data.)*

### 4.2 Level Types
| Type | Purpose | Mode | Can fail? |
|---|---|---|---|
| **Tutorial** | Guided first exposure to a concept | Block Mode only | No — walks the player through |
| **Puzzle** | Standard independent challenge | Block or Code | Yes, unlimited retries |
| **Debugging** | Given a broken query ("Corruptor sabotage"), find and fix it | Code Mode | Yes |
| **Optimization Challenge** | Given a *correct* but inefficient query, improve it | Code Mode | Yes, efficiency-gated |
| **Boss Level** | Multi-concept synthesis closing out a world | Code Mode (mandatory) | Yes |
| **Speed Trial** *(optional replay)* | Re-run any completed level against a timer | Player's choice | N/A — bonus only |

### 4.3 Star / Grading Criteria
Each standard level (Tutorial and Speed Trial excluded) can earn **up to 3 stars + 1 Time Medal**, kept as separate signals so chasing speed is never required for "100%" completion:

- **Star — Completion**: result set matches the expected output
- **Star — Optimal Query**: passes the Section 3.2 performance layer's efficiency threshold for that level
- **Star — First-Attempt Success**: solved correctly on the first submitted query, Confidence Meter still full
- **Time Medal** *(Bronze/Silver/Gold, separate from stars)*: awarded for solving under level-specific time thresholds, only checked if the player opts into a timed run

World completion (all levels at 3 stars) unlocks that world's Detective Rank title (Section 2.3) and contributes toward theme unlocks (Section 6).

---

## 5. Screen-by-Screen UI Specification

Each screen lists **Purpose**, **Key UI elements**, **Navigation**, and **Responsive notes** (phone vs. tablet). Wireframe sketches are included for the three highest-complexity screens.

### 5.1 Splash Screen & Loading States
- **Purpose**: brand entry point; mask cold-start asset loading (schema data, theme assets, save data)
- **Key elements**: animated Query wordmark, progress indicator, rotating "did you know?" SQL tip
- **Navigation**: auto-advances to Onboarding (first launch) or Main Menu (returning player) — no interaction required
- **Responsive**: identical layout scaled by width; logo never exceeds 40% of the shortest viewport dimension

### 5.2 Onboarding & Tutorial Flow
- **Purpose**: establish the narrative premise ("recruited to the Bureau"), collect a display name, run the very first Tutorial level before any menu is shown
- **Key elements**: 3–4 skippable narrative story cards, name entry field, first Tutorial level embedded directly in the flow
- **Navigation**: linear, ends by dropping the player straight into World 1's Level Map
- **Responsive**: story cards are full-bleed on phone, centered max-width column on tablet

### 5.3 Main Menu / Dashboard
- **Purpose**: home base — snapshot of progress, fastest path back into active play
- **Key elements**: current-world banner with "Continue" CTA, XP/Rank summary, streak flame, daily challenge card, quick links to Sandbox/Achievements/Leaderboard
- **Navigation**: hub screen — routes to every other top-level screen (5.4, 5.9–5.13)
- **Responsive**: phone = vertically stacked cards; tablet = 2-column dashboard grid

```
+-----------------------------------------+
|  QUERY            (i)    Karan   Rank:  |
|                              Field Det.  |
+-------------------------------------------+
|  > CONTINUE: World 4 - Junction City      |
|  [############------------]  12/22 levels|
+-----------------+-------------------------+
| Streak: 7 days   |  Daily Challenge        |
|                  |  "The Missing Order"    |
+-----------------+-------------------------+
| [World Map] [Sandbox] [Achievements]      |
| [Leaderboard] [Reference Library]         |
+-----------------------------------------+
```

### 5.4 Level Selection Map / Grid
- **Purpose**: navigate within and across worlds; surface star progress at a glance
- **Key elements**: horizontally-scrollable world carousel at top, node-map of levels below (locked/unlocked/starred states), world-themed background art
- **Navigation**: tapping a node opens a level-preview sheet → "Start" enters the Gameplay Screen (5.5); the world carousel switches between worlds (locked worlds show their unlock requirement)
- **Responsive**: phone = single-column node path with pinch-zoom; tablet = full node-map visible without scrolling

### 5.5 Active Gameplay Screen
- **Purpose**: the core loop — where players spend the vast majority of session time
- **Key elements**: schema browser (collapsible), query workspace (Block/Code toggle), Run button, results pane, hint/concept-card access, level HUD (star preview, timer if Speed Trial)
- **Navigation**: pause/menu icon asks for confirmation before exiting an in-progress level; "Run" triggers the Execution Feedback overlay (5.6)
- **Responsive**: **tablet** = schema browser and workspace side-by-side (sketched below); **phone** = schema browser collapses to a swipe-up drawer, workspace takes full width, results pane becomes a bottom sheet

```
+-------------------------------------------+
| =  World 4 * Level 12        **- 02:14   |
+-----------------------+---------------------+
|  SCHEMA BROWSER        |  QUERY WORKSPACE     |
|  > customers            |  [Block Mode|Code]  |
|  > orders                | +----------------+ |
|  > products                | SELECT [___]    | |
|                            | FROM   [___]    | |
|                            | WHERE  [___]    | |
|                            +----------------+ |
|                            [ > Run Query ]     |
+-----------------------+---------------------+
| RESULTS                                       |
| id | name       | total                       |
| 1  | J. Smith   | 240.00                       |
+-----------------------------------------------+
| Hint (2 left)    Concept Card    Skip?         |
+-------------------------------------------------+
```

### 5.6 Query Execution & Feedback Overlay
- **Purpose**: surface the Section 3.3 feedback loop without leaving the gameplay context
- **Key elements**: color-coded result diff, plain-English error/success message, star-breakdown animation on level completion, "Next Level" / "Retry" / "Review Solution" CTAs
- **Navigation**: dismissible overlay on top of 5.5; completion state routes to the next level or back to the Level Map
- **Responsive**: centered modal on tablet, full-screen sheet on phone

### 5.7 Hint and Explanation Modals
- **Purpose**: deliver the 3-tier hint system and Concept Cards without breaking flow
- **Key elements**: tiered hint-reveal buttons with the Insight Point cost shown up front, "Common Mistakes" carousel when triggered by a specific error, real-world scenario callout
- **Navigation**: modal over the Gameplay Screen; closing returns exactly to the prior workspace state (query text preserved)
- **Responsive**: bottom sheet on phone, centered modal on tablet

### 5.8 Settings and Preferences
- **Purpose**: account, accessibility, audio, notification, and data controls
- **Key elements**: theme selector (owned themes only, others link to 5.10), sound/music sliders, colorblind-safe result-diff toggle, font-size stepper, notification preferences, data export/reset, sign-out
- **Navigation**: accessible from the Main Menu and a persistent icon on most top-level screens
- **Responsive**: single scrollable list on both form factors; tablet uses a wider two-column layout for grouped toggles

### 5.9 Profile and Statistics
- **Purpose**: personal record-keeping — the "detective file" on the player themself
- **Key elements**: Rank/title, total XP, world-by-world star-completion bars, concept-mastery radar (from the Mastery Tracker, Section 2.2), lifetime stats (queries run, average attempts, fastest boss clear)
- **Navigation**: from the Main Menu or by tapping the player avatar anywhere it appears
- **Responsive**: radar chart and stat cards reflow from stacked (phone) to grid (tablet)

### 5.10 Achievement and Collection Galleries
- **Purpose**: browse earned and locked badges/themes/mascot skins
- **Key elements**: filterable grid (skill / exploration / speed / cosmetic), locked-item unlock-condition tooltip, theme preview-and-apply from within the gallery
- **Navigation**: from the Main Menu or Profile; theme preview can deep-link into Settings to apply
- **Responsive**: grid column count scales with viewport — 3 columns on phone, 5–6 on tablet

### 5.11 Sandbox / Free-Play Mode
- **Purpose**: unstructured practice — no stars, no timer, optional custom schema import
- **Key elements**: the same workspace component as 5.5 minus HUD/scoring chrome, schema picker (bundled sample DBs or import a `.sql`/`.csv`), "save snippet" library
- **Navigation**: from the Main Menu; a fully separate save-state from campaign progress
- **Responsive**: identical layout logic to 5.5

### 5.12 Daily Challenge Screen
- **Purpose**: single rotating puzzle, drives daily return visits
- **Key elements**: countdown to next rotation, today's puzzle card, global "solved today" counter, reward preview
- **Navigation**: from the Main Menu dashboard card; solving routes into a variant of the Gameplay Screen with a Daily-specific HUD
- **Responsive**: same as the Gameplay Screen once entered

### 5.13 Leaderboard and Social Features
- **Purpose**: comparative and asynchronous social play
- **Key elements**: tabbed Global / Friends / Weekly leaderboard, Friend Challenge composer, Community Solutions feed (per level, opt-in view from the Feedback Overlay's "Review Solution")
- **Navigation**: from the Main Menu; Community Solutions also deep-links from 5.6
- **Responsive**: leaderboard rows are a simple scrolling list on both form factors; tablet adds an inline profile-preview pane

### 5.14 In-App Reference Library and SQL Documentation
- **Purpose**: standalone, searchable SQL reference independent of any specific level
- **Key elements**: search bar, keyword/clause index, tap-to-copy code snippets, cross-links into relevant Concept Cards and the world where a concept is first taught
- **Navigation**: accessible from the Main Menu, Settings, and inline from any Hint modal
- **Responsive**: master–detail split view on tablet (index + content pane side-by-side); phone uses a drill-down list → detail page pattern

---

## 6. UI Themes and Visual Design System

### 6.0 Design Principles (apply across every theme)
Regardless of skin, the underlying UI follows one philosophy: **dark-first, one dominant accent per theme, calm motion.** Query is a concentration-heavy, text-dense app — schema names, column types, and result grids need to stay legible above everything else, so no theme sacrifices contrast or adds motion that competes with reading a result table. Every theme gets exactly **one** dominant accent color plus a semantic trio (success/error/warning), never a "rainbow" palette, and every background is a near-black or near-dark *with a deliberate color cast* rather than a flat generic black — the Terminal theme casts green, Nature casts moss, Space casts violet. Micro-interactions (button presses, card flips) stay subtle; spectacle is reserved for level-complete and boss-clear moments, not everyday taps. This is meant to read as a fully-specified, premium design system in the spirit of a real product identity — each theme below ships as a complete token set (colors, type, motion, sound), not a color-swap reskin of one base look.

### 6.1 Theme Roster
| Theme | Unlock condition | Vibe |
|---|---|---|
| **Terminal / Classic** | Available from the start (default) | Retro CRT hacker-terminal |
| **Cyberpunk / Data Center** | Complete World 4 | Neon server-room, synthwave |
| **Nature / Organic Data** | Complete World 6 | Data-as-ecosystem, bioluminescent forest |
| **Space / Cosmic Database** | Complete World 8 | Deep-space observatory |
| **Medieval / Archival** | Complete World 10 (full campaign) | Illuminated-manuscript archive |

### 6.2 Terminal / Classic
- **Palette**: Background `#0A0E0A`, Surface `#12160F`, Primary text `#C8FFC8`, Accent `#39FF6A`, Success `#39FF6A`, Error `#FF5C5C`, Warning `#FFD54A`
- **Typography**: `JetBrains Mono` throughout, even UI chrome, not just code — reinforces the terminal conceit
- **Iconography**: monoline glyph-style icons (single stroke weight, no fill), evoking box-drawing characters
- **Animation character**: cursor-blink accents, togglable scanline flicker on transitions, typewriter-in reveal for Concept Cards
- **Sound design**: mechanical-keyboard clicks for taps, a low modem-esque blip for errors, one warm confirmation tone for success — deliberately minimal, not musical
- **Background environments**: near-black with a faint scanline texture; boss levels add a subtle amber "alert" wash
- **Component adaptation**: buttons render as `[ BRACKETED ]` text-first shapes rather than filled pills, staying true to the terminal metaphor
- **Signature element**: the query workspace cursor is a real blinking block cursor, not a generic text-caret — it's the one piece of chrome every other theme reskins around instead of hiding

### 6.3 Cyberpunk / Data Center
- **Palette**: Background `#0D0221`, Surface `#1A0B2E`, Primary text `#F2E9FF`, Accent `#FF2E9A` (magenta) with `#2EE6FF` (cyan) as the *only* secondary, Success `#2EE6FF`, Error `#FF2E63`, Warning `#FFB800`
- **Typography**: `Orbitron` for headers/titles, `JetBrains Mono` retained for all SQL/code content — never sacrifice code legibility for theme flavor
- **Iconography**: angular, faceted icon set with a thin neon-glow outline
- **Animation character**: glitch-flicker micro-transition between screens, neon trail on drag-and-drop blocks
- **Sound design**: synthwave-inflected UI tones — a soft analog-synth arpeggio sting on level-complete rather than a generic chime, a low sub-bass pulse on boss-level entry; worth real production time here specifically, since sound is half of what sells this theme's identity
- **Background environments**: server-rack silhouettes with slow-moving light streaks; rain-on-glass parallax on the World 4 Level Map specifically
- **Component adaptation**: cards get a thin double-border "readout panel" treatment; progress bars render as segmented LED strips
- **Signature element**: the schema browser's table connectors render as animated light-pulse traces, like signal moving down a circuit trace, instead of static lines

### 6.4 Nature / Organic Data
- **Palette**: Background `#0C1710` (a deep forest near-black with a green cast — not a generic dark background), Surface `#16241A`, Primary text `#E4EDDD`, Accent `#7FB069` (moss/fern), Success `#7FB069`, Error `#D46A54` (muted clay-red), Warning `#D9A441` (honey amber)
- **Typography**: a rounded humanist sans (e.g. `Poppins`) for UI chrome, `JetBrains Mono` for code
- **Iconography**: organic, rounded line icons — tables represented as root systems, rows as leaves branching off
- **Animation character**: gentle grow/bloom transitions — a completed query "sprouts" a small leaf animation; no harsh cuts
- **Sound design**: soft acoustic/ambient palette — wood-chime confirmation, rustle-leaf for navigation, no synthetic beeps
- **Background environments**: bioluminescent flora silhouettes on a dark canopy backdrop, slow parallax drift
- **Component adaptation**: cards get soft rounded corners and a subtle paper-grain texture; schema diagrams render relationships as branching root lines instead of straight ER connectors
- **Signature element**: the schema browser *is* the root system — table nodes are literally laid out as a root/branch graph rather than a boxed ERD, the one theme where the metaphor changes the actual information layout, not just its skin

### 6.5 Space / Cosmic Database
- **Palette**: Background `#050414`, Surface `#0E0C29`, Primary text `#E8E6FF`, Accent `#8B5CF6`, Success `#5CE1E6`, Error `#FF6B6B`, Warning `#FFD166`
- **Typography**: `Space Grotesk` for headers, `JetBrains Mono` for code
- **Iconography**: constellation-style dot-and-line icons
- **Animation character**: parallax starfield background; tables visualized as orbiting nodes in the schema browser
- **Sound design**: sparse, spacious pad tones; a soft "warp" whoosh on world transition
- **Background environments**: deep starfield with slow-drift nebula gradients behind the World 8 Level Map
- **Component adaptation**: progress indicators render as orbital rings rather than linear bars
- **Signature element**: JOIN operations animate as two orbiting nodes locking into a shared orbit — the one moment the theme visualizes what a JOIN is actually doing, not just decoration

### 6.6 Medieval / Archival
- **Palette**: Background `#2B1D12`, Surface `#3C2A18`, Primary text `#F0E4C8`, Accent `#C89B3C` (gold leaf), Success `#7A9B5C`, Error `#9B3C3C`, Warning `#C89B3C` (shares the accent, deliberately, evoking wax-seal ink)
- **Typography**: a serif display face for headers (e.g. `Cormorant`), `JetBrains Mono` for code
- **Iconography**: hand-drawn/etched line icons, wax-seal button accents
- **Animation character**: page-turn transitions, ink-reveal for Concept Cards
- **Sound design**: parchment-rustle and quill-scratch UI sounds, a single bell-toll for boss-level victory
- **Background environments**: illuminated-manuscript borders framing the Level Map
- **Component adaptation**: cards render as "scroll" shapes with torn-edge borders; the schema browser becomes a ledger-list style
- **Signature element**: level completion is rendered as a wax seal stamping down onto the case file, replacing the generic confetti burst other themes might default to

### 6.7 Component Library Specification
| Component | States | Notes |
|---|---|---|
| **Buttons** (Primary / Secondary / Ghost / Danger) | default, hover/press, disabled, loading | Primary = accent-filled; Danger reserved for destructive Sandbox actions (e.g. "Clear my custom schema") |
| **Input fields** (text, dropdown, code editor) | default, focused, error, disabled | Code-editor variant always keeps `JetBrains Mono` regardless of theme (Section 6.0) |
| **Cards** (level card, achievement card, world card) | locked, unlocked, in-progress, completed (starred) | Locked state always shows the unlock condition, never just a padlock with no explanation |
| **Modals** (hint, concept, level-complete) | entering, active, exiting | Level-complete modal is the one place large celebratory motion is allowed, themed per 6.2–6.6 |
| **Progress indicators** (world bar, XP bar, streak flame) | Reskin per theme — segmented LED / vine-fill / orbital ring / ledger tally | Underlying value/logic is theme-independent; only the render layer swaps |
| **Code display blocks** | syntax-highlighted, theme-tinted accent for keywords only | Base code palette stays consistent across themes for muscle memory; only the *accent* keyword color shifts |
| **Data table (results) visualization** | match / extra-row / missing-row / null-value | Color-blind-safe alternative encoding (icon + color, never color alone) toggle in Settings, Section 5.8 |
| **Schema diagram (ERD-lite)** | Reskinned per theme — root system / orbital nodes / ledger list / circuit trace | Underlying graph data structure is identical; only the renderer changes per theme |

---

## 7. Database and Backend Architecture

### 7.1 Local Meta-Database (Game State, Progress, Cache)
A single on-device SQLite database (via `drift`, Section 8) tracks everything about the player that isn't puzzle content:

```sql
CREATE TABLE player_profile (
  id INTEGER PRIMARY KEY,
  display_name TEXT NOT NULL,
  rank_title TEXT NOT NULL DEFAULT 'Junior Analyst',
  total_xp INTEGER NOT NULL DEFAULT 0,
  insight_points INTEGER NOT NULL DEFAULT 0,
  streak_count INTEGER NOT NULL DEFAULT 0,
  streak_freeze_available INTEGER NOT NULL DEFAULT 0,
  active_theme TEXT NOT NULL DEFAULT 'terminal_classic',
  created_at INTEGER NOT NULL,
  cloud_sync_id TEXT
);

CREATE TABLE world_progress (
  world_id TEXT NOT NULL,
  levels_completed INTEGER NOT NULL DEFAULT 0,
  total_levels INTEGER NOT NULL,
  unlocked INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (world_id)
);

CREATE TABLE level_attempts (
  id INTEGER PRIMARY KEY,
  level_id TEXT NOT NULL,
  attempt_number INTEGER NOT NULL,
  submitted_query TEXT NOT NULL,
  passed_syntax INTEGER NOT NULL,
  passed_semantic INTEGER NOT NULL,
  passed_result INTEGER NOT NULL,
  efficiency_score REAL,
  hint_tier_used INTEGER NOT NULL DEFAULT 0,
  duration_ms INTEGER,
  created_at INTEGER NOT NULL
);

CREATE TABLE achievements_earned (
  achievement_id TEXT NOT NULL,
  earned_at INTEGER NOT NULL,
  PRIMARY KEY (achievement_id)
);

CREATE TABLE theme_unlocks (
  theme_id TEXT NOT NULL PRIMARY KEY,
  unlocked_at INTEGER
);

CREATE TABLE settings (
  key TEXT NOT NULL PRIMARY KEY,
  value TEXT NOT NULL
);

CREATE TABLE content_cache_manifest (
  content_pack_id TEXT NOT NULL PRIMARY KEY,
  version INTEGER NOT NULL,
  checksum TEXT NOT NULL,
  downloaded_at INTEGER NOT NULL
);
```

`level_attempts` is intentionally granular (every attempt, not just the best) — it's the raw material for both the Concept Mastery Tracker (Section 2.2) and the Learning Effectiveness metrics (Section 11).

### 7.2 Query Execution Engine (The Sandbox)
- Each puzzle attempt spins up a **fresh, isolated, in-memory SQLite instance**, seeded from that level's JSON-defined schema + seed-data bundle — never the meta-database, never a shared or networked instance.
- A **statement whitelist** is enforced per level: early worlds disable DDL (`CREATE`/`ALTER`/`DROP`) and destructive DML entirely; `PRAGMA` and `ATTACH DATABASE` are disabled everywhere, always.
- `EXPLAIN QUERY PLAN` output is parsed after every successful execution to drive the Section 3.2 performance layer.
- **Resource guards**: an execution timeout (e.g. 3 seconds), a result row cap (e.g. 10,000 rows), and a recursion-depth cap for recursive CTEs (World 8) defend against a pathological or accidental infinite-loop query freezing the app.
- A **result-diff engine** compares the player's result set to the level's canonical expected output; order-sensitivity is a per-level flag, only enforced when the puzzle explicitly requires `ORDER BY`.
- The execution engine sits behind a small internal interface (`SqlDialectAdapter`) rather than being called directly — SQLite is the only implementation at launch, but the same adapter-per-source pattern used elsewhere in your Flutter work keeps a future PostgreSQL/MySQL "dialect pack" (Section 12.1) a matter of adding an implementation, not rewriting the engine.

### 7.3 Content Delivery
- **Bundled at launch**: Worlds 1–3 ship as assets (JSON level definitions + seed SQL) inside the app package, so the game is fully playable offline from first install with zero network dependency.
- **Update mechanism**: a versioned content manifest (hosted remotely) lists available content packs; the app checks the manifest version on launch/foreground, downloads any new/updated packs as a delta, verifies checksum before applying, and caches locally (tracked in `content_cache_manifest` above). This is also the mechanism for shipping new worlds post-launch without an app-store release (Section 12.1).
- **Cloud sync** *(optional account required)*: `player_profile`, `world_progress`, and `achievements_earned` sync to a cloud store for cross-device continuity. Sync is local-first with background push; conflict resolution takes the **max stars per level** across devices rather than blindly overwriting, so a player can never lose progress by switching devices.

### 7.4 Security Considerations for Arbitrary SQL Execution
Because every player query runs against an **ephemeral, isolated, in-memory** sandbox — never a shared or networked database — classic server-side SQL-injection risk doesn't directly apply. The real risks are different and are handled as follows:

- [ ] No filesystem- or network-capable pragmas are ever enabled on a sandbox connection
- [ ] The statement whitelist (7.2) prevents engine-level escapes (`ATTACH DATABASE`, `PRAGMA`, etc.) regardless of level
- [ ] Timeout + row-cap + recursion-depth guards prevent on-device denial-of-service from a pathological query
- [ ] If/when **community-authored puzzles** (Section 12.3) ship custom schemas to *other* players' devices, that content is treated as untrusted input: validated against a strict schema format server-side, sandboxed identically to first-party content, and never executed with elevated permissions just because it originated "inside" the app

---

## 8. Technical Implementation Stack

### 8.1 Core
| Layer | Choice | Why |
|---|---|---|
| **Framework** | Flutter, stable channel (currently the 3.44.x line) | Single codebase across the full platform roadmap (Section 12.2) |
| **Language** | Dart 3.10+, **sound null safety mandatory** | Non-negotiable at this codebase size; no `--no-sound-null-safety` escape hatches |
| **State management** | **Riverpod** (2.x, with `@riverpod` code generation) | Compile-time-safe, no `BuildContext` dependency, and the business logic that matters most here — the validator and scoring engine — can be unit-tested in complete isolation from widgets. It's also the pattern the wider Flutter ecosystem has settled on as the 2026 default for new projects, with BLoC as the alternative mainly where a large multi-developer team wants BLoC's stricter event/state ceremony |
| **Local persistence** | **`drift`** for the meta-database (7.1); raw **`sqlite3`** package for the sandboxed puzzle engine (7.2) | `drift` gives type-safe, reactive, migration-friendly access to progress/settings data and now ships first-class web support via `drift_flutter` + `sqlite3.wasm`. The sandbox has a different job — executing *arbitrary, student-written* SQL against schemas defined at runtime — which is exactly what `drift`'s compile-time query builder isn't built for, so the two packages coexist rather than one being stretched to cover both jobs |

### 8.2 Supporting Packages
| Category | Package(s) | Notes |
|---|---|---|
| **Animation** | `flutter_animate` (micro-interactions), `rive` (Ada / mascot character animation), `lottie` (celebration effects) | Reserve a real `Hero` transition for the level-card → gameplay-screen handoff on level entry — the same continuity technique worth using for the mini-player elsewhere in your work reads just as well here for a level card expanding into its own workspace |
| **Audio** | `just_audio` + `audio_service` for reliable cross-platform playback, session handling, and background-audio behavior | Same audio-package pairing already proven out in your other Flutter work; sound design is a first-class part of each theme's identity here (Section 6), not an afterthought, so it earns the same care |
| **Internationalization** | `flutter_localizations` + `intl`, ARB-based | Architect for RTL from day one even if launch is English/Hindi/Kannada-only, to avoid a costly retrofit |
| **Testing — unit** | `flutter_test`, `mocktail` | The 4-layer query validator (3.2) and scoring engine are pure Dart with no widget dependency and should have a fast, standalone unit-test suite as a first-class deliverable, not an afterthought |
| **Testing — widget** | `flutter_test` widget tests per screen (Section 5) | Cover Block/Code mode-toggle state preservation specifically — it's the highest-risk UI interaction in the app |
| **Testing — integration** | `integration_test` | Full level playthroughs, at minimum one per world, run in CI |
| **Testing — visual regression** | Golden tests, one baseline per theme (Section 6) | Catches a component that "forgot" to reskin correctly when a new theme unlocks |

### 8.3 Non-negotiable Engineering Constraints
- [ ] Every query-validation and scoring function is pure Dart with no Flutter/widget dependency, keeping the unit-test suite fast and making the same logic reusable in a possible future companion web tool (Section 12.2)
- [ ] All theme tokens (color/type/spacing/sound) live in a single design-tokens source (Section 6.7), never hardcoded per-widget, so a 6th theme is a data change, not a code change
- [ ] Content (levels, schemas, seed data) is data, not code — no level's logic should ever require an app-store release to fix (Sections 7.3 / 12.1)

---

## 9. Development Phases and Milestones

> Timelines assume a focused small team (2–3 developers); a parenthetical solo-developer estimate is included since this may start as an individual build.

### Phase 1 — Core Engine & MVP *(8–10 weeks team / 14–16 weeks solo)*
**Goal**: a playable, offline, single-theme game covering Worlds 1–2.
- [ ] Block Mode + Code Mode query workspace (Section 3.1)
- [ ] 4-layer validation pipeline (Section 3.2), sandboxed execution engine (Section 7.2)
- [ ] Worlds 1–2 content (31 levels), Tutorial + Puzzle level types only
- [ ] Local meta-database (`drift` schema, Section 7.1) and basic progress persistence
- [ ] Terminal/Classic theme only (Section 6.2)
- [ ] Core screens: Splash, Onboarding, Main Menu, Level Map, Gameplay, Feedback Overlay
- **Exit criteria**: a new player can install, complete World 1 end-to-end offline, and have progress persist across app restarts

### Phase 2 — Gamification & Progression *(4–6 weeks team / 6–8 weeks solo)*
- [ ] XP, streaks, Insight Points economy, hint-tier system (Section 3.4)
- [ ] Achievement/badge system + Achievement Gallery screen
- [ ] Daily Challenge screen and rotation logic
- [ ] Profile & Statistics screen, Concept Mastery Tracker
- **Exit criteria**: the return-visit loop is functional end-to-end (streaks, daily challenge, visible progress)

### Phase 3 — Advanced SQL & Boss Content *(10–12 weeks team / 16–20 weeks solo)*
- [ ] Worlds 3–10 content (141 remaining levels)
- [ ] Debugging and Optimization Challenge level types
- [ ] Performance layer (`EXPLAIN QUERY PLAN` parsing, Sections 3.2/7.2) fully wired to the efficiency star
- [ ] Boss Level narrative content and "Case Closed" sequences
- **Exit criteria**: the full campaign is completable start-to-finish, all 4 core level types functional

### Phase 4 — Theming, Polish & Additional Modes *(6–8 weeks team / 8–10 weeks solo)*
- [ ] Remaining 4 visual themes (Sections 6.3–6.6) + unlock logic
- [ ] Sandbox / Free-Play mode (custom schema import)
- [ ] Full animation/audio pass per theme
- [ ] Accessibility pass (colorblind-safe result diffs, font scaling, screen-reader labels)
- [ ] Tablet-responsive layouts finalized for every screen (Section 5)
- **Exit criteria**: all 5 themes ship, Sandbox mode is live, the app passes an accessibility audit

### Phase 5 — Social Features & Content Pipeline *(6–8 weeks team / 8–10 weeks solo)*
- [ ] Leaderboards, Friend Challenges, Community Solutions (with moderation queue, Section 12.3)
- [ ] Optional accounts + cloud sync (Section 7.3)
- [ ] Remote content-pack delivery pipeline (ship new worlds without an app-store review)
- [ ] Classroom Mode
- **Exit criteria**: a new world can reach existing installs via a content update alone, with zero app-store release

**Total estimate: roughly 34–44 weeks (about 8–10 months) with a small team, or 52–64 weeks (about 12–15 months) solo.**

---

## 10. Monetization and Business Model

### 10.1 Free-to-Play Structure
- **Free**: Worlds 1–3, Terminal/Classic theme, full core loop — hints stay earnable through play, never gated to zero
- **Full Campaign Unlock** *(one-time IAP)*: all 10 worlds, permanently
- **Query Pro** *(subscription, monthly/annual)*: all worlds + all 5 cosmetic themes + ad-free + a monthly Insight Points stipend + early access to new worlds as they ship
- **Individual theme packs** *(small one-time IAP)*: for players who want one specific cosmetic theme without a full subscription

### 10.2 Design Guardrail: Hints Are Never Pay-to-Win
Insight Points (hint currency) are earnable through normal play at a rate that keeps a free player from ever being *blocked* by cost — paying buys convenience and speed, never help a free player structurally can't reach. Worth holding this line firmly for an education product specifically; it's a trust signal, not just a design nicety.

### 10.3 Ad Integration (Flow-Respecting)
- [ ] **Rewarded video only**, opt-in, for bonus hint tokens or a streak-freeze — never forced
- [ ] **Interstitials** appear only at world-boundary "Case Closed" screens — never mid-puzzle, never inside an active query attempt
- [ ] **Zero ads** in Sandbox mode or during an active timed Speed Trial, protecting the two contexts where flow state matters most
- [ ] Ads removed entirely with Query Pro, or via a small standalone "Remove Ads" IAP for players who don't want a subscription

---

## 11. Success Metrics and Analytics

### 11.1 Learning Effectiveness
- Concept mastery rate: % correct on **first exposure** vs. % correct when a concept **resurfaces** later (validates the spaced-repetition design, Section 1.4)
- Average attempts-to-completion, per concept — flags confusing content for revision
- Hint-reliance rate, per concept — high reliance signals a Concept Card or Tutorial Level needs rework
- Cross-world retention: re-test accuracy on an early concept (e.g. filtering) when it resurfaces inside a much later puzzle (e.g. a World 8 window-function level)

### 11.2 Engagement
- DAU/MAU, average session length, D1/D7/D30 return rate
- Level completion rate and drop-off funnel, per world — identifies the exact level where players churn
- Streak survival curve — how long streaks typically last before breaking, and whether Streak Freeze meaningfully extends it

### 11.3 Business
- Install → free-signup conversion, free → paid conversion rate
- Subscription churn, tracked separately for monthly vs. annual cohorts
- LTV, ARPDAU, and — if ads are active — eCPM/fill rate

### 11.4 Tooling
Recommended: an event-analytics SDK (e.g. Firebase Analytics) paired with a crash-reporting SDK (e.g. Firebase Crashlytics). A minimal starter event schema:

| Event | Trigger | Key params |
|---|---|---|
| `level_started` | player enters the Gameplay Screen | `world_id`, `level_id`, `mode` (block/code) |
| `query_executed` | any Run press | `level_id`, `attempt_number`, `passed_syntax/semantic/result` |
| `level_completed` | result matches expected | `stars_earned`, `hint_tier_used`, `duration_ms` |
| `hint_requested` | any hint tier opened | `level_id`, `tier`, `insight_points_spent` |
| `theme_unlocked` / `theme_applied` | theme unlock or selection | `theme_id` |
| `subscription_started` / `iap_purchased` | purchase completion | `product_id`, `price` |

---

## 12. Risk Mitigation and Future-Proofing

### 12.1 Content Scalability
- Level content is **data (JSON + seed SQL), not code** — new levels or entire new worlds ship as content packs (Section 7.3) with zero app-store dependency
- The level-format schema is itself versioned, so new *level types* beyond the 6 in Section 4.2 can be introduced without breaking older cached content
- The `SqlDialectAdapter` interface introduced in Section 7.2 keeps the door open for PostgreSQL/MySQL "dialect packs" later — v1.0 targets SQLite exclusively, but the abstraction already exists, directly serving World 10's dialect-awareness content today and a possible "Advanced Dialects" expansion afterward

### 12.2 Platform Expansion
| Platform | Path | Key constraint to plan for |
|---|---|---|
| iOS / Android | Native Flutter targets from day one (MVP) | Store-specific IAP plumbing differs and should sit behind a single purchase-service interface |
| Web | `sqlite3.wasm` via `drift_flutter` for the meta-database; the sandbox engine needs its own WASM build | Web sandboxing/performance characteristics need explicit re-validation — don't assume mobile timeout/row-cap constants transfer directly |
| Desktop (Windows/macOS/Linux) | Flutter desktop target, mostly "free" once responsive layouts (Section 5) are solid | Ad SDKs and IAP flows are mobile-store-specific and need a desktop-appropriate monetization path — likely Query Pro-only, no ads, on desktop |

### 12.3 Community Content Creation Tools
- [ ] An in-app or companion web **Level Editor** for community-authored puzzles (schema + expected result + hints)
- [ ] A mandatory **moderation/review queue** before any community puzzle reaches other players — never auto-published
- [ ] Community content sandboxed and validated identically to first-party content (Section 7.4) — "came from inside the app" is never treated as trusted
- [ ] A rating/reporting system and a "Bureau-Verified" badge for staff-reviewed community puzzles, so players can distinguish curated from unreviewed content at a glance

---

## Appendix A: Agent Implementation Quick-Start

Suggested repo structure for an agent starting from an empty Flutter project:
```
query/
|-- lib/
|   |-- core/
|   |   |-- validation/        # 4-layer pipeline (Section 3.2) -- pure Dart, no widgets
|   |   |-- sandbox_engine/    # sqlite3 execution engine (Section 7.2)
|   |   `-- scoring/           # star/efficiency scoring (Section 4.3)
|   |-- data/
|   |   |-- local/             # drift schema + DAOs (Section 7.1)
|   |   `-- content/           # level-pack loading/parsing (Section 7.3)
|   |-- features/
|   |   |-- gameplay/          # Section 5.5-5.7
|   |   |-- level_map/         # Section 5.4
|   |   |-- dashboard/         # Section 5.3
|   |   |-- profile/           # Section 5.9
|   |   `-- ...                # one folder per Section 5 screen
|   `-- theming/                # design tokens + all 5 themes (Section 6)
|-- assets/
|   `-- levels/
|       |-- world_01_archive_vaults/
|       `-- ...
`-- test/
    |-- unit/validation/
    |-- widget/
    `-- integration/
```

**Suggested first-sprint tickets** (maps to Phase 1, Section 9):
1. Scaffold `core/validation` with the 4-layer pipeline as pure Dart classes, plus a unit-test suite built from 5-10 hand-written World 1 queries as fixtures
2. Build `sandbox_engine` around the `sqlite3` package: open an in-memory DB, load a hardcoded World 1 schema, execute a query, return a typed result
3. Build the Gameplay Screen (Section 5.5) in Block Mode only, wired to tickets 1 and 2
4. Author World 1's 15 levels as JSON content (Section 7.3 format) and load them through `data/content`
5. Wire `drift`-backed progress persistence (Section 7.1) so completing a level survives an app restart

---

## Appendix B: Glossary (seed content for Section 5.14)

| Term | Plain-English definition |
|---|---|
| **Query** | A request written in SQL asking a database for specific data |
| **JOIN** | Combining rows from two or more tables based on a related column |
| **Subquery** | A query nested inside another query |
| **CTE** | A named, temporary result set referenced within a larger query (`WITH ... AS`) |
| **Window function** | A calculation across a set of rows related to the current row, without collapsing them into one row the way `GROUP BY` does |
| **Index** | A lookup structure that lets the database find rows without scanning every row |
| **Normalization** | Structuring tables to reduce data duplication |

---

*End of document. This plan is a living spec — update world/level counts, package versions, and timeline estimates as implementation reveals real constraints.*
