# 🔍 Query — Learn SQL Through Detective Investigation

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.4+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![SQLite](https://img.shields.io/badge/SQLite-Powered-003B57?style=for-the-badge&logo=sqlite&logoColor=white)
![License](https://img.shields.io/badge/License-Private-red?style=for-the-badge)

**A narrative-driven, gamified SQL learning experience built with Flutter.**
*Write real SQL. Solve real cases. Become a Data Detective.*

</div>

---

## 📖 Table of Contents

1. [Overview](#-overview)
2. [Core Concept & Narrative](#-core-concept--narrative)
3. [Key Features](#-key-features)
4. [Tech Stack](#-tech-stack)
5. [Project Architecture](#-project-architecture)
6. [Feature Modules](#-feature-modules)
7. [World & Level Structure](#-world--level-structure)
8. [The 4-Layer Validation Pipeline](#-the-4-layer-validation-pipeline)
9. [Scoring & Progression System](#-scoring--progression-system)
10. [Database Schema](#-database-schema)
11. [Theming System](#-theming-system)
12. [State Management](#-state-management)
13. [Firebase Integration](#-firebase-integration)
14. [Getting Started](#-getting-started)
15. [Project Structure](#-project-structure)
16. [Level JSON Format](#-level-json-format)
17. [Contributing](#-contributing)

---

## 🌟 Overview

**Query** is a full-featured, production-quality mobile/desktop game built with Flutter that teaches SQL through immersive detective storytelling. Players take on the role of a **Data Detective** at the "Algorithmic Bureau of Investigation" (ABI), solving corruption cases by interrogating databases with real SQL queries.

Unlike flashcard apps or syntax tutorials, Query puts players inside a narrative — each world is a case file, each level is a crime scene clue, and the SQL they write is their only tool to uncover the truth.

> *"The Corruptor has struck again. The database is scrambled. Only a skilled analyst can restore order. That is you."*

---

## 🕵️ Core Concept & Narrative

### The Premise

A shadowy entity known as **The Corruptor** systematically corrupts databases belonging to businesses, institutions, and organizations across the city. The player, a newly recruited **Junior Analyst** at the ABI, must investigate each case by querying the corrupted database to extract evidence, restore records, and identify anomalies.

### Progression

Each **World** represents a unique case file with a distinct client, narrative arc, and SQL concept domain. As players complete worlds, they unlock harder cases, new UI themes, and rise through the ABI analyst ranks.

### Detective Mode

A **Detective Mode** challenge variant strips away all hints, displays a timer, and applies a 25% XP penalty — rewarding mastery with exclusive rank titles and visual flair.

---

## ✨ Key Features

### 🎮 Core Gameplay
- **Real SQL Execution** — All queries run inside a fully isolated SQLite sandbox engine. No simulation, no approximation — actual SQLite.
- **4-Layer Validation** — Every submission passes through Syntax → Semantic → Result → Performance validation layers.
- **3-Star Rating System** — Stars for completion, query optimality, and first-attempt success.
- **Time Medal System** — Bronze / Silver / Gold medals on timed runs.
- **Hint System (3 Tiers)** — Nudge (5 IP), Partial Reveal (15 IP), Full Solution (30 IP). Full Solution caps the level at 1 star.
- **Block Mode Editor** — Drag-and-drop SQL clause blocks for beginners and guided tutorial levels.
- **Guided Tutorial Mode** — First levels scaffold the query step-by-step.

### 📚 Learning System
- **Concept Cards** — In-level popups explaining the SQL concept before the player attempts the puzzle.
- **SQL Error Codex** — Searchable in-app reference of common SQL errors with bad/good examples.
- **SQL Reference Library** — Full browsable SQL syntax reference organized by category.
- **Concept Mastery Tracking** — Per-concept progress derived from world completion.
- **Bookmarkable Concepts** — Players can save concept cards for later review.
- **Level Notes** — Players can attach personal notes to any level.

### 🏆 Progression & Rewards
- **XP & Rank System** — 12+ analyst ranks from "Rookie" to "Grand Master Analyst", each gated by XP thresholds.
- **Streak System** — Daily login streak tracking with streak freeze protection.
- **Insight Points (IP)** — Secondary currency earned by playing, spent on hints.
- **Achievement System** — Persistent unlock badges stored in a local database.
- **Theme Unlocks** — Completing worlds unlocks cosmetic UI themes.
- **Leaderboard** — Firebase-backed global leaderboard with offline fallback.

### 🗺️ Content
- **10 Worlds** — 172+ hand-crafted levels across 10 thematic worlds.
- **Daily Challenges** — New SQL puzzle every day with a 2× XP multiplier.
- **Weekly Case Files** — Extended multi-part challenges with +500 XP reward.
- **Sandbox Terminal** — Free-play SQL environment with preset schemas and a custom schema builder.

### 🎨 Polish & UX
- **Parallax Background** — Gyroscope-responsive layered background with circuit trace art.
- **Slanted Panel UI** — Custom `SlantedPanel` component for all card surfaces with an angular aesthetic.
- **Full Animation System** — `flutter_animate` entrance animations, hover states, and transition effects throughout.
- **JetBrains Mono Font** — Monospace font for all SQL code and the terminal aesthetic.
- **Adaptive Layout** — All screens responsive to mobile and desktop breakpoints.
- **Audio Engine** — `just_audio`-powered in-game audio with per-theme sound packs.

---

## 🛠️ Tech Stack

| Category | Technology | Version | Purpose |
|---|---|---|---|
| **UI Framework** | Flutter | 3.x | Cross-platform UI |
| **Language** | Dart | >= 3.4.0 | App logic |
| **State Management** | Riverpod | ^2.6.1 | Reactive state, dependency injection |
| **Code Generation** | riverpod_generator | ^2.6.1 | Provider boilerplate generation |
| **Local DB (meta)** | Drift | ^2.20.0 | Typed SQLite ORM for player data |
| **Local DB (sandbox)** | sqlite3 | ^2.4.6 | Isolated query execution engine |
| **Animations** | flutter_animate | ^4.5.0 | Entrance animations, transitions |
| **Fonts** | google_fonts | ^6.3.2 | Montserrat, Inter, Exo2 |
| **Lottie** | lottie | ^3.1.2 | JSON-based animations |
| **Audio** | just_audio | ^0.9.41 | In-game sound effects |
| **Firebase Auth** | firebase_auth | ^6.6.1 | Account login |
| **Firestore** | cloud_firestore | ^6.9.0 | Leaderboard, cloud sync |
| **Firebase Storage** | firebase_storage | ^13.5.0 | OTA content packs |
| **App Check** | firebase_app_check | ^0.4.7 | API security |
| **Markdown** | flutter_markdown | ^0.7.7 | In-app reference rendering |
| **Sensors** | sensors_plus | ^7.1.0 | Gyroscope for parallax |
| **Sharing** | share_plus | ^12.0.2 | Share achievements/scores |
| **Preferences** | shared_preferences | ^2.5.3 | Settings persistence |
| **HTTP** | http | ^1.6.0 | Remote API calls |
| **Archive** | archive | ^4.2.0 | Content pack decompression |
| **Testing** | mocktail | ^1.0.4 | Unit test mocking |

---

## 🏗️ Project Architecture

Query follows a **layered feature-first architecture** with clean separation between UI, business logic, and data access.

```
lib/
├── main.dart                   # App entry point, route registration
├── firebase_options.dart       # Firebase platform configuration
│
├── core/                       # Platform-agnostic business logic
│   ├── providers.dart          # Riverpod provider definitions
│   ├── audio/                  # AudioController (just_audio)
│   ├── sandbox_engine/         # Isolated SQLite execution engine
│   │   ├── sandbox_engine.dart
│   │   ├── statement_whitelist.dart
│   │   └── level_schema.dart
│   ├── scoring/                # LevelScorer, star/XP computation
│   ├── settings/               # SettingsService, SharedPreferences
│   ├── sync/                   # SyncService, FirebaseSyncService
│   └── validation/             # 4-layer validation pipeline
│       ├── query_validator.dart
│       ├── syntax_validator.dart
│       ├── semantic_validator.dart
│       ├── result_validator.dart
│       └── performance_validator.dart
│
├── data/                       # Data layer
│   ├── content/                # Level loading & parsing
│   │   ├── level_loader.dart
│   │   └── models/             # LevelModel, WorldModel, RankSystem
│   ├── local/                  # Drift database + DAOs
│   │   ├── app_database.dart
│   │   └── daos/               # PlayerDao, ProgressDao, AttemptsDao...
│   └── remote/                 # LeaderboardService (Firestore)
│
├── features/                   # One folder per screen
│   ├── splash/
│   ├── onboarding/
│   ├── dashboard/
│   ├── world_select/
│   ├── level_map/
│   ├── gameplay/
│   ├── feedback_overlay/
│   ├── hints/
│   ├── daily_challenge/
│   ├── sandbox/
│   ├── achievements/
│   ├── leaderboard/
│   ├── profile/
│   ├── reference/
│   └── settings/
│
├── shared/
│   └── widgets/                # GameAppBar, ActionButton, SlantedPanel...
│
└── theming/
    ├── tokens/                 # GameTokens design system
    ├── components/             # SlantedPanel, ActionButton
    └── themes/                 # Per-theme token files
```

### Key Design Principles

1. **Separation of Concerns** — The sandbox SQL engine, validation pipeline, and scoring system are pure Dart with zero Flutter/widget dependencies. They are fully unit-testable in isolation.
2. **Riverpod Everywhere** — All state (player profile, world progress, settings, active theme) flows through Riverpod providers. No raw `setState` for business data.
3. **Single Database Provider** — All UI observes data through `appDatabaseProvider`. No direct database instantiation outside providers.
4. **Content as Data** — All 172 levels and 10 worlds are JSON files in `assets/`. No level data is hardcoded in Dart.

---

## 📦 Feature Modules

### Splash Screen
Handles first-launch detection. Checks for an existing player profile; if absent, routes to Onboarding. Otherwise routes to the Dashboard.

### Onboarding
Name entry, role selection, and profile creation. Writes the `PlayerProfile` row to the Drift database and seeds initial world progress.

### Dashboard
The main hub. Displays:
- **Continue Banner** — Current world with progress bar and a "Continue" CTA
- **Stats Row** — Streak counter, total XP with rank progress bar, current rank title
- **Daily Challenge Card** — Links to today's puzzle (2× XP multiplier)
- **Weekly Case Card** — Featured extended investigation (+500 XP)
- **Bureau Tools** — Quick navigation to World Map, Achievements, SQL Reference, and Sandbox

### World Select
Grid of all 10 worlds showing unlock status and completion progress for each.

### Level Map
Scrollable map of all levels in a world. Displays star ratings for completed levels and locks inaccessible levels.

### Gameplay
The core experience:
- **Schema Browser** — Collapsible sidebar showing table structures for the current level
- **SQL Editor** — Multi-line editor with syntax keyword highlighting, line numbers, and auto-formatting
- **Block Mode** — Drag-and-drop clause builder for tutorial levels
- **Result Table** — Query output with diff highlighting (match / extra / missing rows)
- **Hint Panel** — Tiered hint display consuming Insight Points
- **Concept Lesson Dialog** — Shown before the first attempt on a new concept level
- **Timer** — Optional countdown for Detective Mode challenges
- **Submit Button** — Triggers the 4-layer validation pipeline

### Feedback Overlay
Full-screen result screen after a level completes:
- Stars earned (animated reveal)
- XP gained with breakdown (base + bonuses)
- Time medal (if applicable)
- Hint cap warning (if Full Solution used)
- Buttons to Retry, Next Level, or return to the Map

### Sandbox
Free-form SQL playground:
- **Query Terminal tab** — Write and execute any SELECT/DML query
- **Schema Builder tab** — Write custom DDL to create and populate tables
- Two preset schemas: HR/E-Commerce and Space Fleet (Sci-Fi)
- Snippet save/load via SharedPreferences

### Daily Challenge
Loads from `assets/levels/daily_challenges/` based on the current date. Displays a countdown to the next challenge and a 2× XP badge.

### Achievements
Grid of all defined achievements. Earned ones glow; locked ones show progress.

### Leaderboard
Firebase Firestore-backed global rankings. Degrades gracefully to mock data when offline.

### Profile
Player stats overview: display name, rank, XP, streak count, Insight Points, and a **Concept Mastery Tracker** with per-domain progress bars.

### SQL Reference
Browsable markdown-rendered syntax reference organized by category. Deep-links to the SQL Error Codex.

### SQL Error Codex
Searchable index of common SQL errors loaded from `assets/reference/error_codex.json`. Each entry: title, description, bad example, corrected example.

### Settings
Display name editing, theme selector, audio toggle, haptic feedback, language selection, account sync controls.

---

## 🗺️ World & Level Structure

Query contains **10 worlds** with **172 levels total**, each themed around a different SQL domain:

| World | Name | SQL Concepts | Levels | Client |
|---|---|---|---|---|
| 01 | **The Archive Vaults** | SELECT, FROM, LIMIT, DISTINCT, aliasing | 15 | Groove & Vinyl Records |
| 02 | **Filter District** | WHERE, AND/OR, NOT, LIKE, BETWEEN, IN, NULL | 16 | City Council |
| 03 | **Aggregation District** | GROUP BY, HAVING, COUNT, SUM, AVG, MIN, MAX | 18 | Municipal Finance Dept |
| 04 | **The JOIN Nexus** | INNER JOIN, LEFT/RIGHT/SELF/CROSS JOIN | 22 | Logistics Corp |
| 05 | **Nested Depths** | Subqueries, EXISTS, IN subqueries, correlated queries | 20 | Intelligence Agency |
| 06 | **Data Forge** | INSERT, UPDATE, DELETE, transactions | 16 | Manufacturing Plant |
| 07 | **Blueprint Bureau** | CREATE TABLE, ALTER TABLE, constraints, indexes | 15 | City Planning Office |
| 08 | **Function Foundry** | String functions, date/time, CAST, COALESCE | 20 | Data Processing Hub |
| 09 | **Optimization Observatory** | EXPLAIN QUERY PLAN, indexes, query efficiency | 15 | Performance Lab |
| 10 | **The Grand Archive** | Window functions, CTEs, advanced patterns | 15 | The ABI HQ |

---

## 🔍 The 4-Layer Validation Pipeline

Every query submission passes through four sequential validation layers. Failure at any layer produces an actionable, specific error message.

```
Player submits SQL
        │
        ▼
┌─────────────────────┐
│  Layer 1: SYNTAX    │  Parse-only check. No execution.
│                     │  Balanced parentheses, valid keywords,
│                     │  correct clause order.
└──────────┬──────────┘
           │ PASS
           ▼
┌─────────────────────┐
│  Layer 2: SEMANTIC  │  Static analysis against the level schema.
│                     │  Table exists, columns exist, type compat,
│                     │  ambiguous references.
└──────────┬──────────┘
           │ PASS
           ▼
┌─────────────────────┐
│  Layer 3: RESULT    │  Executes in isolated in-memory SQLite sandbox.
│                     │  Diffs actual rows vs. expected_result.
│                     │  Respects order_sensitive flag.
│                     │  10,000 row cap. 3-second timeout guard.
└──────────┬──────────┘
           │ PASS
           ▼
┌─────────────────────┐
│  Layer 4: PERF      │  Runs EXPLAIN QUERY PLAN. Scores efficiency 0-1.
│  (optional)         │  Active for World 3+ levels.
│                     │  Hard requirement for optimizationChallenge type.
└─────────────────────┘
```

### Sandbox Security

| Guard | Detail |
|---|---|
| **In-memory only** | Each run creates a fresh `sqlite3.openInMemory()` — never touches the meta-database |
| **Statement whitelist** | Per-world whitelist: Worlds 1-5 allow SELECT only; Worlds 6+ progressively unlock DML |
| **Forbidden patterns** | PRAGMA, ATTACH DATABASE, DROP TABLE (outside DML worlds) always blocked |
| **Result cap** | Maximum 10,000 rows returned |
| **Execution timeout** | 3-second timer guard |

---

## ⭐ Scoring & Progression System

### Stars (per level)

| Star | Name | Condition |
|---|---|---|
| 1 star | **Completion** | Result matches expected output |
| 2 stars | **Optimal Query** | Passed performance layer AND no Full Solution hint used |
| 3 stars | **First Attempt** | Correct on the first submission AND no Full Solution hint used |

> **Full Solution hint cap**: Using a Full Solution hint locks the level at 1 star maximum.

### XP Formula

```
XP = base_xp_reward
   + 25% of base  (if Optimal star earned)
   + 25% of base  (if First Attempt star earned)
   + time_medal_bonus (Bronze +10, Silver +25, Gold +50)
   × daily_multiplier (2.0 for Daily Challenge)
   × 0.75 (if Detective Mode — 25% penalty for no hints)
```

### Rank System (12 Tiers)

| Rank | Title | XP Required |
|---|---|---|
| 1 | Rookie | 0 |
| 2 | Junior Analyst | 500 |
| 3 | Analyst | 1,500 |
| 4 | Senior Analyst | 3,500 |
| 5 | Lead Analyst | 7,000 |
| 6 | Data Detective | 13,000 |
| 7 | Senior Detective | 22,000 |
| 8 | Chief Investigator | 35,000 |
| 9 | Bureau Commander | 55,000 |
| 10 | Grand Inquisitor | 85,000 |
| 11 | Archivist Prime | 130,000 |
| 12 | Grand Master Analyst | 200,000 |

### Hint System (Insight Points)

| Tier | IP Cost | Effect |
|---|---|---|
| **Nudge** | 5 IP | Conceptual hint; no code shown |
| **Partial Reveal** | 15 IP | Shows partial query structure |
| **Full Solution** | 30 IP | Shows the full answer; caps at 1 star |
| *Grace hint* | 0 IP | Free Nudge automatically after 3 failed attempts |

---

## 🗄️ Database Schema

Query uses **Drift** (an SQLite ORM for Dart) with schema version 3. Database file: `<AppSupportDir>/query_app_db.sqlite`.

### Tables

| Table | Purpose |
|---|---|
| `PlayerProfiles` | Display name, rank, XP, Insight Points, streak, active theme |
| `WorldProgress` | Per-world completion tracking (levels completed, unlocked flag) |
| `LevelAttempts` | Full audit trail of every submission (query, pass/fail per layer, duration) |
| `LevelCompletions` | Best star rating and best time per level |
| `AchievementsEarned` | IDs of earned achievement badges |
| `ThemeUnlocks` | Which cosmetic themes the player has unlocked |
| `Settings` | Key-value store for user preferences |
| `ContentCacheManifest` | Tracks downloaded OTA content packs (version, checksum) |
| `BookmarkedConcepts` | Concept card IDs the player has bookmarked |
| `LevelNotes` | Player's personal notes attached to individual levels |
| `WeeklyCaseCompletion` | Tracks completed weekly case files |
| `RaceHistory` | (Reserved) Historical race results for future features |

### DAOs

| DAO | Responsibilities |
|---|---|
| `PlayerDao` | Profile CRUD, daily streak check, XP updates, rank title resolution |
| `ProgressDao` | World progress reads/updates, level completion recording |
| `AttemptsDao` | Insert/query level attempts for analytics |
| `AchievementsDao` | Unlock and query earned achievements |
| `ConceptDao` | Bookmark/unbookmark concept cards, watch bookmarks stream |
| `LevelNotesDao` | Read/write personal level notes |
| `ThemesDao` | Unlock themes, query unlocked theme list |

---

## 🎨 Theming System

Query supports multiple visual themes unlocked by completing worlds. Each theme overrides the base `GameTokens` palette and provides a matching audio sound pack.

### Base Palette (terminal_classic — always unlocked)

| Token | Hex | Usage |
|---|---|---|
| `background` | `#15171E` | App background |
| `surface` | `#22252F` | Card / panel surfaces |
| `accent` | `#FFCC00` | Primary highlight, CTAs |
| `success` | `#00FF9D` | Correct result, stars |
| `error` | `#FF3344` | Wrong answer, errors |
| `warning` | `#FF9900` | Hints, streak, weekly case |
| `info` | `#00CCFF` | Info badges |
| `rare` | `#D944FF` | Special achievements |

### Theme Architecture

```
theming/
├── tokens/
│   └── game_tokens.dart         # Base design token class
└── themes/
    ├── terminal_classic_tokens.dart
    ├── arctic_blue_tokens.dart
    ├── crimson_lab_tokens.dart
    └── ...                      # One file per unlockable theme
```

The `activeThemeDataProvider` is watched by the root `MaterialApp`. Changing the theme triggers immediate full-app re-theming via Riverpod.

---

## 🔄 State Management

Query uses **Riverpod** for all state management. Key providers:

```dart
// Singleton database
final appDatabaseProvider = Provider<AppDatabase>((ref) { ... });

// DAO providers
final playerDaoProvider   = Provider((ref) => ref.watch(appDatabaseProvider).playerDao);
final progressDaoProvider = Provider((ref) => ref.watch(appDatabaseProvider).progressDao);

// Reactive streams
final playerProfileProvider        = StreamProvider(...);
final allWorldProgressProvider     = StreamProvider(...);
final worldProgressProvider        = StreamProvider.family<..., String>(...);
final allAchievementsProvider      = StreamProvider(...);
final bookmarkedConceptsProvider   = StreamProvider<List<String>>(...);

// Computed
final masteryProgressProvider = FutureProvider(...);

// Gameplay
final gameplayProvider = StateNotifierProvider<GameplayNotifier, GameplayState>(...);
```

`GameplayState` contains: current query text, attempt count, elapsed time, hint tier, submission result, and loading state. `GameplayNotifier` orchestrates the full validation pipeline and writes to the database on completion.

---

## 🔥 Firebase Integration

| Service | Usage |
|---|---|
| **Firebase Auth** | Account creation and sign-in (email/password) |
| **Cloud Firestore** | Global leaderboard (`top_players` collection) |
| **Firebase Storage** | OTA content packs for new worlds/levels |
| **App Check** | API security to prevent abuse |
| **Firebase Sync** | Uploads XP and progress on level completion |

> Firebase is **optional**. The app works fully offline — all critical data is stored locally in the Drift SQLite database. Firebase features gracefully degrade with mock data or silent failure when offline.

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** >= 3.x ([Install Flutter](https://docs.flutter.dev/get-started/install))
- **Dart SDK** >= 3.4.0
- Android Studio or VS Code with Flutter extension

### 1. Clone the Repository

```bash
git clone https://github.com/karanks6/Query.git
cd Query
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Code (Drift + Riverpod)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Firebase Setup (Optional)

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add Android/iOS apps and download config files
3. Place `google-services.json` in `android/app/` and `GoogleService-Info.plist` in `ios/Runner/`
4. Run `flutterfire configure` to regenerate `lib/firebase_options.dart`

### 5. Run the App

```bash
# Debug
flutter run

# Release build (Android)
flutter build apk --release

# Release build (Windows)
flutter build windows --release
```

### 6. Run Tests

```bash
flutter test
flutter test integration_test/
```

---

## 📁 Project Structure

```
Query/
├── lib/                         # Dart source code
├── assets/
│   ├── levels/
│   │   ├── world_01_archive_vaults/        (15 levels)
│   │   ├── world_02_filter_district/       (16 levels)
│   │   ├── world_03_aggregation_district/  (18 levels)
│   │   ├── world_04_join_nexus/            (22 levels)
│   │   ├── world_05_nested_depths/         (20 levels)
│   │   ├── world_06_data_forge/            (16 levels)
│   │   ├── world_07_blueprint_bureau/      (15 levels)
│   │   ├── world_08_function_foundry/      (20 levels)
│   │   ├── world_09_optimization_observatory/ (15 levels)
│   │   ├── world_10_grand_archive/         (15 levels)
│   │   └── daily_challenges/              (rotating puzzles)
│   ├── concept_cards/           # SQL concept card JSON files
│   ├── reference/               # error_codex.json, SQL reference markdown
│   ├── audio/                   # Sound packs per theme
│   ├── fonts/                   # JetBrains Mono (Regular, Bold, Italic)
│   ├── images/                  # Decorative assets
│   └── icon/                    # App launcher icon
├── android/                     # Android platform files
├── ios/                         # iOS platform files
├── windows/                     # Windows platform files
├── web/                         # Web platform files
├── test/                        # Unit tests
├── integration_test/            # Integration tests
├── pubspec.yaml                 # Dependencies and asset declarations
└── analysis_options.yaml        # Linting configuration
```

---

## 📝 Level JSON Format

Complete field reference for level JSON files:

| Field | Type | Required | Description |
|---|---|---|---|
| `id` | string | YES | Unique level ID (`world_XX_level_YY`) |
| `world_id` | string | YES | Parent world ID (`world_01`–`world_10`) |
| `level_number` | int | YES | Sequence number within the world |
| `title` | string | YES | Level display name |
| `narrative` | string | YES | Story context shown before the editor |
| `type` | string | YES | `tutorial`, `puzzle`, `optimizationChallenge`, `dmlChallenge` |
| `schema` | object | YES | Table and column definitions (for Semantic Validator) |
| `schema_sql` | string | YES | CREATE TABLE statements for sandbox seeding |
| `seed_sql` | string | YES | INSERT statements to populate sandbox data |
| `expected_result` | array | YES | Canonical correct output rows |
| `order_sensitive` | bool | YES | Whether row order must match exactly |
| `performance_active` | bool | YES | Enables Layer 4 performance validation |
| `efficiency_threshold` | float | YES | 0.0–1.0 minimum efficiency for optimal star |
| `xp_reward` | int | YES | Base XP awarded on completion |
| `allowed_world_number` | int | YES | Used by statement whitelist for DML permissions |
| `concept_card_id` | string | NO | Links to a concept card shown before first attempt |
| `guided_answer` | string | NO | Pre-fills Block Mode; enables tutorial scaffolding |
| `hints` | array | NO | Up to 3 hint objects (nudge/partial_reveal/full_solution) |
| `timing_thresholds` | object | NO | `gold_ms`, `silver_ms`, `bronze_ms` for time medals |

---

## 🤝 Contributing

### Code Style

- All Dart code must pass `dart analyze lib/` with **zero issues** before committing.
- Use `GameTokens` for all colors, spacing, and typography. No hardcoded hex values in widget code.
- All database access must go through DAO providers via `appDatabaseProvider`.
- New screens must use `SlantedPanel` and `ActionButton` from the theming components.
- Every git commit should target a single file with a unique, descriptive commit message.

### Adding a New Level

1. Create `assets/levels/<world_folder>/level_NN.json` following the format above.
2. Ensure `schema_sql` + `seed_sql` execute cleanly in SQLite.
3. Verify `expected_result` matches the output of running the correct query against the seeded data.
4. Declare the asset path in `pubspec.yaml` if creating a new world directory.
5. Run the app and complete the level manually to verify all 3 stars are achievable.

### Adding a New Theme

1. Create `lib/theming/themes/<theme_name>_tokens.dart` extending the base palette.
2. Register the theme in the settings theme selector.
3. Add a matching audio pack in `assets/audio/<theme_name>/`.
4. Add the unlock condition to the world that should reward this theme.

---

## 📄 License

This project is private and proprietary. All rights reserved.

---

<div align="center">

**Query** — *Because the data never lies. You just have to know how to ask.*

Built with Flutter and Dart

</div>
