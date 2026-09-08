# Mentor Template

Canonical scaffold for a new domain. The mentor system is a **mentor's notebook** (see `/FIRST_PRINCIPLES.md` P9) — not a wiki. This template ships only markdown pages — no YAML, no JSONL, no CLIs in the loop.

To create a new domain:

```bash
# Copy the template (replace "painting" with the domain name)
cp -r mentors/_template mentors/painting

# Register the domain in mentors/season_current.md (manual)
# Have the painting mentor populate current_focus.md and curriculum.md in conversation.
```

## First conversation (mentor intake)

A freshly created domain starts in **needs-intake** state: `current_focus.md → Position → Phase` still reads *needs intake*. Before the first working session, the mentor runs **INTAKE Part B** (see `PROTOCOLS.md`) — its own first session with the user: why this domain, an honest baseline (which seeds `done_topics.md` so finished work is never reassigned), how they want to be coached *here*, the domain-specific constraints, a mirror, one real win, and a sign-off.

The questions are **yours to choose as the domain expert.** Seed a few below that a real mentor in this field would always ask a new student; the mentor generates the rest live. Replace these examples with ones that fit `<domain>`:

- <e.g. "What have you already tried here, and what made it stick or fall apart?">
- <e.g. a domain-specific constraint question — injuries (fitness), instrument owned (music), risk tolerance (finances)>
- <e.g. "What does a real win here look like 90 days out?">
- <e.g. "How do you best learn this — by doing, theory-first, or by example?">

Once Part B is done, `current_focus.md` leaves needs-intake state (Stance, Season goal and Position are filled in) and normal `DOMAIN_SESSION`s begin.

## Files in this template (all plain markdown)

| File | Purpose | Writer |
|---|---|---|
| `curriculum.md` | Vision, phases, milestones, practice cadence, real-world stakes, cross-domain hooks. Evolves slowly. `## ` headers are the units mentors read (`## Position → Curriculum section` in current_focus.md names one). | mentor (free edits) |
| `done_topics.md` | **The catalog.** One row per completed topic. Read at session start, appended at session end. The P1 fix lives here. | mentor (append / edit by row) |
| `current_focus.md` | Mentor's working memory: Stance, Season goal, Position, In progress, Next planned, Binding F-ids, Calibration flags, Anchor, Dates & ladders — above the fold, ≤ 5 KB. | mentor (replace sections in place) |
| `log.md` | Chronological record. One dated entry (`### YYYY-MM-DD \| …`) per session or weekly review; readers take the last 2 entries. | mentor (append only) |
| `sessions/` | Optional long-form page for a session whose narrative outgrows a log entry. The log entry points to it. | mentor (one page per session, when needed) |
| `archive/` | Boundary-time compressions: `season_<N>_<period>.md`, `year_<YYYY>.md`. Immutable once written. Lets mentors read constant-cost history regardless of how old the system is. | mentor (one file per boundary) |
| `intel.md` | Mentor intelligence — expert roster, frameworks, evergreen resources, external pulse. Read IN FULL by the mentor at every review and every session, never skipped for age; refreshed per MENTOR_REFRESH (~4-weekly). | mentor (free edits, ~4-weekly) |

## How the layers relate (P8: one canonical layer per granularity)

```
log.md                       ← Layer 0: canonical at session/week granularity (dated entries; sessions/<date>.md optional long-form)
     ↓ mentor-summarizes at season end (SEASON_TRANSITION)
archive/season_<N>_<...>.md ← Layer 1: season synthesis + index of the season's entries
     ↓ mentor-summarizes at year end (first WEEKLY_REVIEW of the new year)
archive/year_<YYYY>.md       ← Layer 2: year-in-review + per-season index
```

Aside (state, not history; bounded by construction — the fold does the bounding):

```
done_topics.md     ← topic-granularity catalog (P1 fix lives here)
current_focus.md   ← week-granularity working memory; ≤ 5 KB above the fold
curriculum.md      ← concept layer (phases, milestones); evolves slowly
```

Higher chronological layers are derived from lower by the mentor's deliberate write at season/year boundaries. They are never parallel-written, and once written they are immutable.

## The fold convention

`current_focus.md` (like `MEMORY.md`, `profile.md`, `coordinator_state.md`, `season_current.md`) has one fixed line:

```
## ── HISTORY (on demand; agents do not read past this line) ──
```

Above it: the short current picture. Below it: everything retired, verbatim — never deleted. Agents read only above the fold: `sed -n '1,/^## ── HISTORY/p' <file>`. Working memory is updated by replacing the affected `## section` in place; the reason for the change goes in this week's `log.md` entry, never as a dated paragraph above the fold. The header line states the budget (≤ 5 KB above the fold); the WEEKLY_REVIEW budget check measures it and fixes overruns by moving content below the fold. `scripts/validate.sh` checks that every fold file has exactly one fold line and warns when the top half is over its stated budget.

## Archive layer — boundary triggers and templates

### When each archive file is written

| Archive | Trigger | Written by | Source material |
|---|---|---|---|
| `archive/season_<N>_<period>.md` | Inside SEASON_TRANSITION, before designing next season | Domain mentor + coordinator | The season's `log.md` entries (+ any session pages) + season exit-criteria evaluation |
| `archive/year_<YYYY>.md` | First WEEKLY_REVIEW of a new calendar year | Coordinator | All season archives that landed in that year + cross-season patterns |

### Reading discipline

Mentor reads in PREPARE: `current_focus.md` above the fold · `done_topics.md` · the last 2 `log.md` entries · the curriculum section named in Position · `intel.md` IN FULL, every time. On-demand only: deeper `log.md` history and the season/year archives, when a specific historical question arises.

This keeps per-session read cost **O(one week)** regardless of system age.

### Season archive template

```markdown
# Season <N>: <theme>
Domain: <domain> · Period: <start_date> – <end_date> · Weeks: <count>

## Season synthesis

2–4 paragraphs covering the season's arc: what it was meant to do, what it actually did,
the trajectory across the season's weeks (calibration trend, what was harder/easier than
curriculum predicted), and the season's exit-criteria evaluation.

## Index of the season

- W<N> (<dates>) — <one-line compression> — `log.md` entry dated <YYYY-MM-DD>
- ...

## Exit criteria evaluation

From season_current.md exit criteria, marked Met ✅ / Partially Met ⚠️ / Not Met ❌
with one-line reasoning each.

## Open threads carried to season <N+1>

- <thread description>
```

### Year archive template

```markdown
# Year <YYYY> in <domain>

Domain: <domain> · Seasons: <count> · Total sessions: <count>

## Year-in-review

3–5 paragraphs: the year's arc, what stuck, what was dropped, calibration drift across
the year, biggest pattern shifts in {{USER_NAME}}'s behaviour in this domain, biggest
artifacts produced.

## Seasons in this year

- Season N: <theme> — <one-paragraph compression> — `archive/season_<N>_<period>.md`
- ...

## Patterns that crossed seasons

- <pattern observation>
- ...
```

## How the operations work

From `framework/PROTOCOLS.md`. The four operations a human mentor performs:

- **PREPARE** (DOMAIN_SESSION read phase) — read done_topics.md first (P1), then MEMORY.md and profile.md above the fold, current_focus.md above the fold (adopt the Stance), the curriculum section named in Position, the last 2 log.md entries, intel.md in full, wiki pages if the topic may already be there.
- **COACH** (DOMAIN_SESSION conversation) — have the session. Push back when warranted. Calibrate.
- **JOURNAL** (DOMAIN_SESSION write phase) — append the log.md entry (and a session page if warranted); update done_topics.md; replace the changed sections of current_focus.md in place; optionally curriculum.md and a hand-off to the knowledge-store wiki; write back any correction/fact/ask to `mentors/MEMORY.md`; run the budget one-liner; optionally commit.
- **AUDIT** (DRIFT_CHECK, run inside WEEKLY_REVIEW) — reconcile catalog drift, detect repeat topics, flag contradictions and staleness, check fold health.

## The rule that holds everything together

> Markdown prose is the source of truth. The mentor (LLM) is the writer. The user ({{USER_NAME}}) writes by talking. There are no structured writes, no validators, no CLIs in the user-facing loop. Version control is optional (`git commit`, or the `scripts/sync.sh` wrapper) and never blocks a session.

See `/FIRST_PRINCIPLES.md` for the full statement (P1–P9).
