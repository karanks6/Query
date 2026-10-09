# Query: Audio Implementation Plan

## 1. Aesthetic & Vibe Analysis
**Theme:** "Query" is a detective investigation game where the user solves SQL mysteries.
**Inspiration:** High-value games with similar puzzle/investigation vibes (e.g., *Deus Ex*, *Persona 5*, *Detroit: Become Human*, *Return of the Obra Dinn*).
**Aesthetic:** **"Cyber-Noir / Intense Investigation"**
- **Music:** Deep synthwave, brooding basslines, ticking percussion (to simulate ticking clocks and pressure), and atmospheric pads. The music should feel intense but not distracting, keeping the player in a state of "flow" while writing SQL.
- **SFX:** Crisp, mechanical, tactile sounds. Keyboard clacks, heavy metallic locks unlocking (for successful queries), electric buzzes (for SQL errors), and satisfying synth swells for level completion.

## 2. World-Specific Music (Dynamic BGM)
Every world will have its own unique track to reflect its environment:
1. **World 01 (Archive Vaults):** Dusty, echoing synth pads. Mysterious and slow.
2. **World 02 (Filter District):** Slightly faster, introducing a light electronic drum beat.
3. **World 03 (Aggregation District):** Heavier bass, feeling more "industrial".
4. **World 04 (Join Nexus):** Complex, interlocking arpeggios (representing joining data).
5. **World 06 (Data Forge):** Intense, driving synthwave with heavy percussion.
6. **Dashboard/Menu:** A neutral, brooding "hub" track (think *Mass Effect* Normandy theme).

## 3. Sound Effects (SFX) Dictionary
- **`ui_click.mp3`**: A crisp, digital blip for standard button presses.
- **`query_execute.mp3`**: A low-pitch mechanical "thud" or terminal processing sound.
- **`query_error.mp3`**: A subtle, non-grating static buzz.
- **`level_complete_fanfare.mp3`**: An intense, rewarding orchestral or synth swell that plays immediately upon solving the mystery, pausing the main BGM temporarily.
- **`achievement_unlocked.mp3`**: A bright, crystalline chime.

## 4. Technical Architecture Updates
To achieve this, we will upgrade `lib/core/audio/audio_controller.dart`:
1. **BGM Crossfading:** We will implement crossfading between tracks when switching worlds to prevent jarring cuts. Since `flame_audio`'s BGM player doesn't natively crossfade well out-of-the-box, we may leverage the underlying `audioplayers` or `just_audio` package directly for advanced control.
2. **State-Driven Audio:** 
   - `LevelMapScreen` and `GameplayScreen` will notify `AudioController` of their active `worldId`.
   - `AudioController` will maintain a mapping of `worldId` -> `track.mp3`.
3. **Celebration Logic:** 
   - When a level is completed, `AudioController.playFanfare()` will lower the volume of the current BGM (ducking), play the celebration SFX, and then restore the BGM volume.

## 5. Asset Generation/Acquisition Strategy
As an AI, I cannot natively generate high-fidelity, studio-quality MP3 files out of raw code. My previous attempt used basic Python mathematical sine waves, which resulted in the low-quality "bleeps" you heard.
**To get "high-value game" audio:**
- **Option A (I download them for you):** I can write a script to automatically download high-quality, royalty-free Cyber-Noir / Investigation tracks from public domain libraries (like Incompetech/Kevin MacLeod or FreePD) directly into your `assets/audio` folder.
- **Option B (You provide them):** You can download premium tracks from a service like Envato Elements or Epidemic Sound, place them in `assets/audio`, and I will write the advanced audio engine code to fade and trigger them perfectly.
