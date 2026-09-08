# <domain> — log

> **Chronological record** — Layer 0, the canonical history of this domain at session/week granularity. One dated entry per DOMAIN_SESSION (written at JOURNAL) and per WEEKLY_REVIEW (the mentor's LOG_ENTRY), always appended at the end. Long-form narrative that outgrows an entry goes in `sessions/<date>.md`; the entry points to it.
>
> **Format.** Readers take the **last 2 dated entries** (that plus `current_focus.md` above the fold is the whole recent picture), so **every entry starts with a dated `###` header**:
>
> ```
> ### YYYY-MM-DD | <session · weekly review> — <topic or one-line headline>
> <3–10 lines: what happened, difficulty (N/10), what changed in current_focus.md and why,
>  calibration flag if any · optional pointer: sessions/YYYY-MM-DD.md>
> ```
>
> Never edit an old entry — append a new one. The *reason* for any change to `current_focus.md` is written here, never as a dated paragraph in `current_focus.md`. This file is never rotated: at season end the season archive (`archive/season_<N>_<period>.md`) indexes its entries.

---

<!-- first dated entry goes here once the domain begins -->
