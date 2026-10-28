# Reading a Report

Every Trivy report, whatever the
target, is built of the same rows.
This chapter takes the JavaScript
fixture's report — eleven findings,
small enough to hold in view at once
(transcript
`trivy-lab/transcripts/t03-fs-scan-npm.txt`) —
and names every part of it, because
once you can read this one, you can
read the 147-finding report from
chapter 4 and any report of your own.

## One row, taken apart

```text
│ minimist │ CVE-2021-44906 │ CRITICAL │ fixed │ 0.0.8 │ 1.2.6, 0.2.4 │ minimist: prototype pollution │
│          │                │          │       │       │              │ https://avd.aquasec.com/nvd/cve-2021-44906 │
```

- **Library** — the package, as named
  in the lock file. `minimist` is a
  tiny argument-parsing library, the
  kind that arrives as a dependency
  of a dependency.
- **Vulnerability** — the public
  identifier. Most are **CVE** numbers
  (the year, then a serial). Some
  ecosystems use their own: this same
  report carries `NSWG-ECO-516`, an
  identifier from the Node.js
  ecosystem's own database, and Go
  and GitHub advisories use their own
  prefixes too. The identifier is the
  handle for looking the flaw up
  anywhere else.
- **Severity** — UNKNOWN, LOW, MEDIUM,
  HIGH or CRITICAL: how bad the flaw
  is judged to be by the source the
  database took it from. Severity is
  an opinion with a pedigree, not a
  measurement of your danger —
  chapter 13 returns to that.
- **Status** — what upstream has done
  about it. **fixed** means a
  corrected version exists. Other
  values you will meet, mostly among
  operating-system packages: **affected**
  (real, no fix yet), **will_not_fix**
  (the distributor has decided), and
  **fix_deferred**. Chapter 6's image
  scan is full of them.
- **Installed Version** and **Fixed
  Version** — the heart of the row:
  what you have, and the earliest
  versions that close the hole. Two
  fixed versions (`1.2.6, 0.2.4`) mean
  two maintained branches each got
  the fix; you need any one of them
  that fits your branch.
- **Title** — one plain sentence
  naming the kind of flaw, and below
  it the link to Aqua's advisory
  page for the finding, which gathers
  the description, references and the
  scoring behind the severity.

## The shape of the whole table

Read the fixture's eleven as a group
and patterns emerge that generalise:

**Prototype pollution, over and over.**
Four of the four packages here are
flagged for it — `ini` (CVE-2020-7788,
HIGH), `lodash` (CVE-2020-8203, HIGH,
and more), `minimist` (the CRITICAL
above), `y18n` (CVE-2020-7774, HIGH).
A *class* of flaw sweeps an ecosystem
at an era's boundary; a scanner shows
you not just your bugs but your era.

**One package, many rows.** `lodash`
4.17.15 accounts for seven findings on
its own, spanning 2020 to a CVE from
2026 — the database you downloaded in
chapter 3 knows flaws published years
after the package was pinned.
Findings accumulate on frozen code;
the count is a function of time as
much as of negligence.

**Every row here has a fix.** In this
report the Status column reads
"fixed" throughout, and that will not
always be so — it is the exception
the next chapter corrects.

## Where to start, faced with your own

A working order for a real report:

1. **Critical and High, with fixes.**
   These are both urgent and
   actionable — the rare happy
   quadrant. Upgrade those packages
   first.
2. **Notice the unfixable.** Rows
   with no fixed version are not
   tasks; they are decisions —
   accept the risk, replace the
   package, or stop using the thing
   that pulls it in. Chapter 9 shows
   how to record that decision.
3. **Group by package, not by row.**
   Seven lodash rows are one upgrade.
   The real work list is the list of
   packages, and it is always shorter
   than the list of findings.
4. **Check what the package is for.**
   A flaw in a library your code never
   calls into is lower in the queue
   than the same severity in your
   request-handling path — the
   scanner cannot know this; chapter
   13 is honest that it reports
   *presence*, not *reachability*.

## The same report from a repository

A project usually lives in git, and
`trivy repo` scans a repository where
it stands, locally or cloned from a
remote address. The lab built a small
git repository out of the same
JavaScript fixture and scanned it:

```bash
trivy repo trivy-lab/repo-demo
```

Check (transcript
`trivy-lab/transcripts/t13-repo-scan.txt`):
**Total: 11**, the identical findings
— the repository scan and the
filesystem scan read the same lock
file and reach the same verdict, as
they should. (`repo-demo` itself is
not shipped; it is three commands to
rebuild, and `examples/lab-notes.txt`
lists them.)
