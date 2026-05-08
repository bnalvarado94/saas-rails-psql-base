# Development Flow

Standard development process for any project using this structure.
**Order matters.** Skipping steps is the #1 cause of rework.

---

## Full flow

```
╔══════════════════════════════════╗
║  PHASE 1 — BEFORE BUILDING       ║  New projects only
╚══════════════════════════════════╝

  Market research
  (docs/MARKET_RESEARCH.md)
         │
         ▼ Build?
  PRD — What, for whom, flows
  (docs/PRD.md)
         │
         ▼
  Design system
  (docs/DESIGN_SYSTEM.md)

╔══════════════════════════════════╗
║  PHASE 2 — DEVELOPMENT           ║  New projects and features
╚══════════════════════════════════╝

  /plan-small or /plan-large
         │
         ▼ Plan approved
  /implement-plan-audited mode=auto
  (screen by screen)
         │
         ▼
  /code-audit-hardcore   (optional)
         │
         ▼
  /cap
```

---

## Phase 1 — Before building

### 1. Market research
**File:** `docs/MARKET_RESEARCH.md`
**When:** At the start of any new project, before any technical decision.

Answer every section honestly. If you can't answer "how do they solve it today?" or "why would someone choose this?", the product is not ready to be built.

The **Decision** section at the end is mandatory: build, pivot, or discard.

---

### 2. PRD
**File:** `docs/PRD.md`
**When:** After validating market research. New projects only.

The most important parts of the PRD:
- **Main flows** — describe the 3-5 flows the MVP needs, with concrete steps
- **Screens** — the screen table maps directly into plan increments
- **Explicitly out of MVP** — writing what's excluded prevents scope creep during development

A PRD with vague flows ("the user can manage their appointments") is useless. It must state exactly what happens at each step.

---

### 3. Design system
**File:** `docs/DESIGN_SYSTEM.md`
**When:** Before the first screen. Once defined, not changed ad-hoc.

Define in this order:
1. Colors (primary, neutrals, semantic)
2. Typography (font, scale, hierarchy)
3. Spacing (4px base scale)
4. Base components (Button, Input, Card with all states)

**Rule:** If during development you feel the need to add a new color or size, update `DESIGN_SYSTEM.md` first. Never magic values in code.

---

## Phase 2 — Development

### 4. Plan
```
/plan-small    # self-contained feature, single PR
/plan-large    # multi-system feature, multiple PRs
```

The plan starts from the PRD screens. Each screen = one or more increments.
The plan is saved to `.plans/<slug>/plan.md`.
A subagent does a blind review before you approve it.

**Do not implement without an approved plan.**

---

### 5. Implement — screen by screen
```
/implement-plan-audited mode=auto
```

Correct implementation order:
1. Data structures / models first
2. Business logic / services
3. API / endpoints
4. Screen by screen, most critical to least critical

Each screen is implemented completely: structure, real data, loading/empty/error states, responsive. Do not move to the next screen with incomplete states.

---

### 6. Audit (optional but recommended)
```
/code-audit-hardcore scope=<path or HEAD~N>
```

Run after implementing a complete feature or when touching existing dirty code.
5 specialists run in parallel. Large findings → new `/plan-small` for the refactor.

---

### 7. Commit
```
/cap
```

Explicit staging. Message that matches the repo style. No AI attribution.

---

## GitNexus — before touching existing code

```bash
/gitnexus:impact symbol=ClassName      # impact of changing a class
/gitnexus:api_impact                   # pre-change impact on endpoint
/gitnexus:detect_changes               # impact of uncommitted changes
/gitnexus:query "concept"              # flows related to a concept
/gitnexus:route_map                    # full API route map
```

Use `impact` before refactoring any class or public method.
Use `detect_changes` before each commit in long sessions.

---

## For bugs

```
/fix-bug
```

Describe: exact symptom + input that reproduces it + expected vs actual output.
The skill forces hypothesis before reading code — avoids anchoring on the wrong cause.

---

## System maintenance

### Updating standards
When you change a convention or find a better pattern:
```
.agents/standards/<stack>.md   # update the convention
.agents/standards/index.yml    # add topic if it's a new file
```

### Documenting new errors
After resolving a bug you hadn't seen before:
```
.agents/common-mistakes/<stack>.md   # add entry with symptom + cause + fix
.agents/common-mistakes/index.yml    # add topic if it's a new file
```

### Maintaining CLAUDE.md
- Update "Work in progress" at the start of each session
- Update "Last important decision" when you make an architectural decision
- Update "Phase" when the project changes stage

---

## Feature complete checklist

- [ ] Plan executed (all increments in `done`)
- [ ] Every screen has states: loading, empty, error
- [ ] Check command passes (tests + lint)
- [ ] Design system respected (no magic values)
- [ ] `/code-audit-hardcore` ran or consciously skipped
- [ ] Common-mistakes updated if a new bug appeared
- [ ] Clean commits with `/cap`

## New project checklist

- [ ] `docs/MARKET_RESEARCH.md` completed and decision made
- [ ] `docs/PRD.md` with flows and screen table
- [ ] `docs/DESIGN_SYSTEM.md` with tokens and base components defined
- [ ] `CLAUDE.md` filled in (stack, check command, constraints)
- [ ] Stack standards created in `.agents/standards/`
- [ ] GitNexus indexed (`gitnexus analyze .`)
- [ ] First commit: `feat: add dev structure`
