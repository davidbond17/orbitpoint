# OrbitPoint Expansion Plan

> From minimalist arcade to a deep, replayable space survival experience — without losing the elegant simplicity that makes OrbitPoint work.

---

## Current State Summary

OrbitPoint is a single-mode infinite arcade game: a satellite orbits a star, the player taps to reverse direction, debris ramps up over 120 seconds, and coins (1/sec survived) unlock cosmetics. No levels, no story, no varied mechanics. The foundation is solid — SpriteKit rendering, SwiftUI overlays, clean architecture, Game Center leaderboards, and a polished UI.

---

## Phase 1: Campaign Mode & Level System

**Goal:** Give players structured progression and goals beyond high scores.

### 1.1 — Zone-Based Campaign

Introduce a **campaign map** with 5 initial zones, each containing 8-10 levels (40-50 levels total). Each zone is a different star system with unique visual identity and gameplay modifiers.

| Zone | Name | Visual Theme | Gameplay Twist |
|------|------|-------------|----------------|
| 1 | **Sol's Edge** | Classic (current look) | Tutorial + baseline difficulty |
| 2 | **Crimson Nebula** | Red/orange hues, dense particle clouds | Debris comes in waves instead of steady stream |
| 3 | **Frozen Expanse** | Icy blues/whites, crystalline debris | Debris moves slower but orbit speed increases |
| 4 | **Void Rift** | Deep purples, glitch/distortion effects | Gravity wells appear that bend orbit radius |
| 5 | **Supernova Core** | Intense whites/golds, screen shake | Everything at once — the gauntlet |

### 1.2 — Level Structure

Each level has:
- **A target survival time** (e.g., "Survive 30 seconds") — completing the time = level cleared
- **3-star rating system:**
  - 1 star: Survive the target time
  - 2 stars: Survive target time + 50%
  - 3 stars: Survive target time + 100% (or complete a bonus objective)
- **Bonus objectives** (optional, per-level): "Reverse direction 20 times," "Don't reverse for 10 seconds," "Survive a comet event"
- **Coin rewards** scale with star rating (e.g., 10 / 25 / 50 coins)

### 1.3 — Zone Unlock Progression

- Zone 1: Unlocked from the start
- Zones 2-5: Require a minimum star count from previous zones (e.g., Zone 2 needs 15 stars from Zone 1)
- This gives completionists a reason to replay and 3-star earlier levels

### 1.4 — Implementation Approach

- New `CampaignManager` singleton to track zone/level progress, star counts
- New `LevelConfig` model defining per-level parameters (target time, debris config, modifiers, bonus objectives)
- New `CampaignMapView` (SwiftUI) showing zones and levels
- Modify `GameScene` to accept a `LevelConfig` and end the round on success (not just on death)
- Existing endless/arcade mode remains as "Free Play" — accessible from main menu alongside Campaign

---

## Phase 2: New Game Mechanics

**Goal:** Add mechanical depth that keeps the core "tap to reverse" identity but layers on interesting decisions.

### 2.1 — Orbital Hazards & Events

New obstacle types beyond standard debris:

| Hazard | Behavior | Counter-Strategy |
|--------|----------|-----------------|
| **Comet** | Fast-moving, leaves a lingering trail of particles | Time your reversal to dodge both head and tail |
| **Asteroid Belt** | A ring of debris that sweeps across the orbit path | Find the gap and position yourself in it |
| **Solar Flare** | Star emits a radial pulse that covers a section of the orbit | Move to the safe arc before it fires (visual warning) |
| **Gravity Well** | Appears at a point and temporarily warps orbit radius inward/outward | Survive the altered path until it dissipates |
| **Black Hole Fragment** | Slowly drifts across screen, pulls nearby debris toward it (changes debris trajectories) | Unpredictable debris — stay alert |

### 2.2 — Power-Ups

Collectible items that spawn occasionally on the orbit path (player must be in the right position to grab them):

| Power-Up | Effect | Duration |
|----------|--------|----------|
| **Shield** | Absorbs one hit | Until used |
| **Slow Field** | All debris moves at 50% speed | 5 seconds |
| **Magnet** | Attracts nearby coins (for a future coin-spawning mechanic) | 8 seconds |
| **Phase Shift** | Satellite becomes transparent and passes through debris | 3 seconds |
| **Orbit Boost** | Temporarily increases orbit speed for tighter dodging | 6 seconds |

- Power-ups spawn as glowing orbs on the orbital path
- Player must orbit into them to collect (adds positional decision-making)
- In Campaign mode, specific levels can guarantee certain power-up spawns
- In Free Play, they spawn randomly with increasing rarity

### 2.3 — Multi-Orbit Mechanic (Zone 4+ / Unlockable Mode)

- A second orbital ring appears at a larger radius
- Double-tap to jump between inner and outer orbit
- Debris targets both rings — player must choose which ring is safer moment-to-moment
- This is the "advanced" mechanic that separates good players from great ones

---

## Phase 3: Lore & Backstory

**Goal:** Give emotional weight to the arcade loop without interrupting the flow.

### 3.1 — The OrbitPoint Universe

**Core Premise:**
> In the far future, humanity's last outpost is a network of orbital satellites maintaining a dying star's stability. You are Probe Unit OP-1 — an autonomous satellite tasked with staying in orbit to keep the star's containment field active. Every second you survive, the star burns a little longer. Every collision is a system failure. The debris isn't random — it's the remnants of a civilization that couldn't hold on.

### 3.2 — Delivery Method: Mission Briefings

- Each Campaign zone opens with a **short text briefing** (3-5 sentences) displayed on a styled overlay before the first level
- Between zones, a **story beat** reveals more about the universe
- These are skippable but add texture for players who care

**Zone Briefings:**

| Zone | Briefing Excerpt |
|------|-----------------|
| Sol's Edge | *"Probe Unit OP-1 online. Primary directive: maintain orbital stability around Star SOL-7. Debris field density: minimal. Begin calibration sequence."* |
| Crimson Nebula | *"SOL-7's emissions are destabilizing the Crimson Nebula. Debris patterns are... organized. Almost as if something is directing them. Maintain orbit. Do not investigate."* |
| Frozen Expanse | *"Thermal readings dropping. SOL-7 is losing energy faster than projected. The ice is not natural — it's crystallized starlight. Something drained this sector long before we arrived."* |
| Void Rift | *"Gravitational anomalies detected. Spacetime is fractured here. The debris... it's moving against physics. OP-1, your readings are being logged but we cannot guarantee retrieval. You are on your own."* |
| Supernova Core | *"Final transmission. SOL-7 is going critical. All remaining probe units have been lost. You are the last. Every second you hold orbit delays the inevitable. Make it count."* |

### 3.3 — Lore Fragments (Collectible)

- Occasionally, a **lore fragment** spawns on the orbit path (distinct visual — glowing data crystal)
- Collecting it unlocks a short text entry in a new **"Codex"** section accessible from the main menu
- Entries reveal backstory about: the civilization that built OP-1, why the star is dying, what the debris really is, other probe units that were lost
- ~30 total fragments across the campaign
- Gives collectors a reason to replay levels

### 3.4 — Implementation Approach

- New `LoreManager` to track collected fragments and story progression
- New `CodexView` (SwiftUI) for reading collected lore
- `MissionBriefingView` overlay shown before zone-first-levels
- Lore fragments as a new `LoreFragmentNode` (SpriteKit) with collection logic in `GameScene`

---

## Phase 4: Soundtrack & Audio Expansion

**Goal:** Transform the single-track audio into an immersive, zone-specific soundscape.

### 4.1 — Zone-Specific Music

Each zone gets its own background track that matches its visual and gameplay identity:

| Zone | Music Style | Mood |
|------|------------|------|
| Sol's Edge | Ambient synth, gentle pulse | Calm, focused |
| Crimson Nebula | Deep bass, rhythmic percussion | Tension, urgency |
| Frozen Expanse | Ethereal pads, crystalline tones | Isolation, beauty |
| Void Rift | Glitchy electronica, dissonant | Unease, disorientation |
| Supernova Core | Orchestral + synth crescendo | Heroic, final stand |
| Free Play | Current theme.mp3 (classic) | Familiar, arcade |

### 4.2 — Dynamic Audio

- **Intensity layers:** Each track has 2-3 layers. As debris density increases, additional layers fade in (e.g., drums kick in at 60s, bass drops at 90s)
- **Event stings:** Short audio cues for power-up collection, solar flare warnings, comet approaches
- **Near-miss audio:** A subtle "whoosh" when debris passes close but doesn't hit — adds tension and feedback

### 4.3 — Implementation Approach

- Extend `MusicManager` to support multiple tracks and crossfading between them
- Add layered audio support (multiple AVAudioPlayers with synced playback)
- New sound effect entries in `AudioManager` for new hazard/power-up events
- Music tracks stored as compressed audio files (~2-3MB each, ~15MB total addition)

---

## Phase 5: New Game Modes

**Goal:** Give players varied ways to play beyond Campaign and Free Play.

### 5.1 — Daily Challenge

- One procedurally-generated level per day with fixed seed (everyone plays the same challenge)
- Separate leaderboard for daily scores
- Bonus coin reward for completing the daily
- Streak tracking: play 7 days in a row for bonus rewards

### 5.2 — Zen Mode

- No debris, no scoring
- Just the satellite orbiting with calming music and visuals
- Unlocked backgrounds/themes from the store work here
- Good for stress relief and showing off cosmetics
- Optional: procedural ambient music generation

### 5.3 — Survival Gauntlet

- Back-to-back levels with escalating difficulty
- No breaks between rounds — debris pattern changes every 30 seconds
- How many rounds can you survive?
- Separate leaderboard

### 5.4 — Time Attack

- Debris patterns are fixed/scripted (not random)
- Goal: survive exactly 60 seconds
- Leaderboard based on closest-to-60s time (going over = fail)
- Tests precision and memorization

### 5.5 — Implementation Approach

- New `GameMode` enum (`.freePlay`, `.campaign`, `.dailyChallenge`, `.zen`, `.gauntlet`, `.timeAttack`)
- `GameScene` reads mode to configure behavior
- `DailyChallengeManager` generates seeded configs from date
- New mode selection UI on main menu or dedicated "Modes" screen
- Additional Game Center leaderboards per mode

---

## Phase 6: Enhanced Progression & Rewards

**Goal:** Deepen the reward loop and give long-term players more to chase.

### 6.1 — Achievement System

In-game achievements (separate from Game Center, but can mirror them):

| Achievement | Requirement |
|-------------|-------------|
| First Orbit | Complete your first level |
| Centurion | Survive 100 seconds in Free Play |
| Star Collector | Earn 50 stars in Campaign |
| Completionist | 3-star every level in a zone |
| Lore Hunter | Collect 15 lore fragments |
| Fashionista | Own 10 cosmetic items |
| Marathon | Play 100 total games |
| Close Call | Have 10 near-misses in a single run |
| Untouchable | Complete a level without reversing direction |

### 6.2 — Player Profile & Stats

- Total games played, total time survived, total coins earned
- Favorite cosmetic loadout
- Achievement showcase
- Per-zone stats and completion percentage

### 6.3 — Seasonal Content

- Rotating limited-time cosmetics (holiday themes, special events)
- Limited-time challenge levels
- Keeps the store fresh without requiring constant new permanent content

### 6.4 — Expanded Store

- **Trail effects:** Different particle trails behind the satellite (fire, ice, rainbow, glitch)
- **Orbit path styles:** Dashed, dotted, glowing, invisible (hard mode flex)
- **Star animations:** Different pulse patterns, particle emissions
- **Background packs:** Unique starfield configurations per zone (unlockable for Free Play)
- **Victory effects:** Custom explosion/particle effects on game over screen

---

## Phase 7: Social & Competitive Features

**Goal:** Leverage Game Center and add lightweight social hooks.

### 7.1 — Friend Challenges

- Challenge a Game Center friend to beat your score on a specific level
- Push notification when they accept/beat your score

### 7.2 — Ghost Runs

- Replay your best run as a "ghost" satellite (translucent, shows your previous path)
- Optionally show a friend's ghost to race against

### 7.3 — Weekly Tournaments

- Week-long events with a specific level/mode
- Tiered rewards based on percentile ranking
- Uses Game Center for matchmaking/leaderboard

---

## Implementation Priority & Phasing

Recommended build order based on impact, feasibility, and dependencies:

### Sprint 1: Foundation (Weeks 1-3)
- [ ] `GameMode` enum and mode-aware `GameScene`
- [ ] `LevelConfig` model and level parameter system
- [ ] `CampaignManager` with zone/level/star tracking
- [ ] Basic Campaign map UI (`CampaignMapView`)
- [ ] Zone 1 levels (8-10 levels with tuned difficulty curves)

### Sprint 2: Mechanics & Content (Weeks 4-6)
- [ ] New hazard types (Comet, Solar Flare, Asteroid Belt)
- [ ] Power-up system (Shield, Slow Field, Phase Shift)
- [ ] Zones 2-3 content (levels, visual themes, difficulty modifiers)
- [ ] Star rating and bonus objectives
- [ ] Zone-specific color palettes and visual effects

### Sprint 3: Story & Audio (Weeks 7-9)
- [ ] Lore system (`LoreManager`, `CodexView`, `LoreFragmentNode`)
- [ ] Mission briefings for each zone
- [ ] 30 lore fragment entries
- [ ] Zone-specific music tracks (compose/source 5 tracks)
- [ ] Dynamic audio layering system
- [ ] New sound effects for hazards and power-ups

### Sprint 4: Modes & Polish (Weeks 10-12)
- [ ] Zones 4-5 content (Void Rift, Supernova Core)
- [ ] Gravity Well and Black Hole Fragment hazards
- [ ] Multi-orbit mechanic
- [ ] Daily Challenge mode with seeded generation
- [ ] Zen Mode
- [ ] Survival Gauntlet mode

### Sprint 5: Progression & Social (Weeks 13-15)
- [ ] Achievement system
- [ ] Player profile and stats tracking
- [ ] Expanded store items (trails, orbit paths, backgrounds)
- [ ] Time Attack mode
- [ ] Ghost runs
- [ ] Friend challenges
- [ ] Additional Game Center leaderboards

### Sprint 6: Content & Launch (Weeks 16-18)
- [ ] Seasonal content framework
- [ ] Balance pass on all difficulty curves
- [ ] Full playtest of campaign progression
- [ ] Performance optimization for new particle effects
- [ ] App Store metadata and screenshot updates
- [ ] Staged rollout

---

## Technical Architecture Notes

### New Files Needed

```
OrbitPoint/
├── Managers/
│   ├── CampaignManager.swift          # Zone/level progress, star tracking
│   ├── LoreManager.swift              # Lore fragment collection, codex data
│   ├── DailyChallengeManager.swift    # Seeded daily level generation
│   ├── AchievementManager.swift       # Achievement tracking and display
│   └── PowerUpManager.swift           # Power-up spawn logic and effects
│
├── Models/
│   ├── LevelConfig.swift              # Per-level parameters and modifiers
│   ├── GameMode.swift                 # Game mode enum and configuration
│   ├── Achievement.swift              # Achievement definitions
│   ├── LoreFragment.swift             # Lore entry data model
│   └── ZoneTheme.swift                # Per-zone visual/audio configuration
│
├── Nodes/
│   ├── CometNode.swift                # Comet hazard with trail
│   ├── SolarFlareNode.swift           # Radial flare hazard
│   ├── GravityWellNode.swift          # Gravity distortion hazard
│   ├── PowerUpNode.swift              # Collectible power-up orbs
│   └── LoreFragmentNode.swift         # Collectible lore crystals
│
├── Views/
│   ├── CampaignMapView.swift          # Zone and level selection
│   ├── ModeSelectView.swift           # Game mode selection
│   ├── CodexView.swift                # Lore reading interface
│   ├── MissionBriefingView.swift      # Pre-zone story overlay
│   ├── AchievementsView.swift         # Achievement list and progress
│   ├── PlayerProfileView.swift        # Stats and profile display
│   └── DailyChallengeView.swift       # Daily challenge info and leaderboard
│
├── Audio/
│   ├── zone1_theme.mp3
│   ├── zone2_theme.mp3
│   ├── zone3_theme.mp3
│   ├── zone4_theme.mp3
│   └── zone5_theme.mp3
```

### Key Modifications to Existing Files

- **GameScene.swift:** Accept `GameMode` and `LevelConfig`, handle new hazard/power-up nodes, level completion logic, lore fragment collection
- **ContentView.swift:** Route to new views (Campaign, Modes, Codex), pass mode config to game
- **GameViewModel.swift:** Track active mode, level config, campaign state
- **MainMenuView.swift:** Add Campaign and Modes buttons, daily challenge banner
- **StoreManager.swift:** Support new item categories (trails, orbit paths, backgrounds)
- **StoreView.swift:** New tabs for expanded store categories
- **DebrisSpawner.swift:** Support for new hazard types, wave-based spawning, level-specific patterns
- **MusicManager.swift:** Multi-track support, crossfading, dynamic layering
- **GameOverView.swift:** Show star rating for campaign levels, lore fragment found indicator

### Data Persistence Strategy

- Continue using UserDefaults for simplicity (no server dependency)
- Consider migrating to SwiftData if data model grows too complex
- Daily challenge seeds derived from date string hash (no server needed)
- All progression is local-first, Game Center handles leaderboards

---

## Design Principles

1. **Preserve the core.** The tap-to-reverse mechanic is sacred. Everything builds on top of it, nothing replaces it.
2. **Respect the player's time.** Campaign levels are 30-90 seconds. No filler. No grinding walls.
3. **Earn complexity.** Zone 1 is the current game. New mechanics introduce one-at-a-time per zone.
4. **Story enhances, never blocks.** All lore is optional and skippable. The game plays perfectly without reading a single word.
5. **No pay-to-win.** All progression is skill and time-based. Cosmetics only.
6. **Offline-first.** No internet required for any core feature. Game Center is additive.
