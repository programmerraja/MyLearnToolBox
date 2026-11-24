---
name: problem-driven-learning
description: Builds a learn-by-doing path for any technology (a database, a language, a framework, a tool). Starts from a concept roadmap in learning order, then builds one phase at a time of hands-on lessons, each a realistic problem with context, data, and a way to check the fix. Use when the user wants to learn a tech, asks for a roadmap, or asks for the next phase of lessons.
---

# Problem-driven learning

The user learns by doing. For each concept in their roadmap, you give them a realistic problem. They read the lesson, try it themselves, and check their own fix. **You never write the solution for them, and no solution is kept in the repo.**

## Workflow

1. **Roadmap first.** Look for `<tech>/roadmap.md`. If it exists, use it. If not, ask what the user already knows, then draft a concept roadmap: phases from basics to advanced, 4 to 6 concepts per phase. Show it and get a yes before building lessons.
2. **One phase at a time.** Build every lesson for the next unbuilt phase, in roadmap order. Tooling tips (shell tricks, editor setup) go in `README.md`, not in a lesson.
3. **Plan coverage before building.** List the phase's topics, then map lessons to them so every topic is covered at least once:
   - A big concept can need 2 or 3 problems, each from a different angle (constraints: refusing bad rows, then what happens to related rows on delete).
   - Small topics that show up together in real life can share one problem (ids that never clash, and a total that can't drift, in one merge).
   - Don't pad. One problem per concept is fine when it covers the concept well.
   Write the mapping in `roadmap.md` (each lesson lists the topics it covers). If you leave a topic out on purpose, say so to the user.
3. **Verify every lesson** (see below) before you report.
4. **Report** the lessons in order and how to run one. The user ticks the roadmap boxes, not you.

## Layout

```
<tech>/
  README.md          # setup, and how to run a lesson
  roadmap.md         # phases -> concepts -> links to lessons
  infra/             # only if the tech needs setup (a database, a broker, a container), plus a small helper for checks
  concepts/NN-slug/  # one lesson; NN runs across phases in learning order
```

## A lesson

Files. Extensions follow the tech (`.sql`, `.py`, `.js`, ...):
- `notes.md`: always.
- `data`: only if the problem needs data.
- `naive`: the current code or schema the problem starts from, only if there is some.
- `solution`: an empty template the learner fills in.
- `check.sh`: when "done" can be checked automatically (most lessons). For programming topics, a small test file run by `check.sh` is enough.

Don't add infra, data, timing, or a check unless the concept needs it.

### notes.md

About one page. Write for someone who has never seen this system. In this order:

1. **Concept:** the roadmap concept this lesson practices, named plainly, plus what to know first (link earlier lessons).
2. **The setting:** the company, the app, who uses it, in 2 to 4 sentences. Use one setting for a whole phase so the lessons build on each other.
3. **The data:** every table or structure: what one item means, what each field means, sample items, and counts. Small data can be shown in full. Sample items are read back from the real data, never invented.
4. **The current code:** what it does, step by step, in plain words.
5. **What goes wrong:** a concrete walk-through on the sample data: who did what, what they saw, what it cost. Say when it happens and why it's easy to miss. For races and timing problems, add a timeline table.
6. **Your task:** one or two sentences describing the outcome, not the method. If the check needs fixed names (tables, columns, functions), give them as a contract from a teammate ("the reporting team's query expects...").
7. **Done when:** the list of things `check.sh` confirms.
8. **Run:** the exact commands.
9. **Words used:** jargon, defined.
10. **Hints:** three, each in `Hint N...`. Hint 1: where to look. Hint 2: narrows it down. Hint 3: may name a feature or doc page. Never the final code.
11. **Source** (optional): a link if the scenario comes from a real incident or post.

Keep test mechanics out of the story. If something in the code stands for real work (a pause standing in for a payment call), say what it stands for.

If you restrict what the learner may change, give the real reason ("three apps write bookings, so the rule has to live in the database"). Don't restrict only to force one answer.

### Problems: realistic, not dummy

- Each problem is a situation someone would actually hit: a business reason, realistic data, a visible symptom with a cost.
- A public source is a bonus, not a requirement. Link one when it fits. Never present an invented scenario as a real incident.
- No dummy scenarios ("a users table with random rows").
- If you use a source, reproduce its symptom yourself. Don't repeat its explanation if it doesn't hold.

### Data

- Deterministic (handwritten, or generated with a fixed seed) and realistic: messy where real data is messy, skewed where real data is skewed.
- Use the smallest size that shows the problem. For concept lessons, a few handwritten rows are often best, because the reader can see all of them.
- For performance lessons, scale down from the real-world size to what loads in seconds on a laptop: a few hundred thousand to about 2M rows. Avoid whole-dataset sorts and memory-heavy statements. A 3M-row sort crashed a local database on an 8 GB laptop.

### check.sh

- It's the entry point: reload the data, apply the solution, print `PASS:` or `FAIL:` lines, exit non-zero on any fail. Source the tech's helper from `infra/` if there is one.
- Give each lesson its own sandbox (its own database, schema, or folder), so one lesson's check doesn't wipe another lesson's work.
- Catch plausible wrong fixes, not just the happy path: correctness, edge cases, no data lost.
- For timing checks: warm up first, keep a wide margin (the good fix should be 10 times or more under the limit), and don't compare against boundaries that move with the current time.

## Verify before you report

Do this privately. Leave nothing of it in the repo.

1. Empty solution: the check must FAIL.
2. A reference solution written in `/tmp`, copied in: the check must PASS. Run it twice.
3. One plausible wrong fix: the check must FAIL.
4. Restore the empty template. Delete the reference solution.
5. Make sure the notes and roadmap don't give the fix away beyond hint 3.
6. Make sure every number and sample in the notes comes from your own run.

## Rules

- Don't assume the tech, the user's level, or the roadmap. Ask when unclear.
- Keep files simple and practical. The user's handwritten notes live elsewhere.
