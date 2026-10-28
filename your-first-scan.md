# Your First Scan

The outcome of this chapter is a
complete scan of a real — if
deliberately decrepit — project, and
the ability to say what its headline
numbers mean. The target ships with
this guide: `trivy-lab/fixtures/oldpy`,
a fictional Python project whose
`requirements.txt` pins six packages
to versions from 2019 and never looks
back. Nothing in it is installed or
run; a filesystem scan reads the
*list*, which is precisely the point:
Trivy judges the versions you have
written down.

## The scan

```bash
trivy fs trivy-lab/fixtures/oldpy
```

The startup lines first say which
scanners woke up — vulnerability and
secret scanning are enabled by default
for a filesystem scan — and then the
report arrives (transcript
`trivy-lab/transcripts/t02-fs-scan-python.txt`).
It has two storeys. The **Report
Summary** counts findings per target:

```text
Report Summary

┌──────────────────┬──────┬─────────────────┬─────────┐
│      Target      │ Type │ Vulnerabilities │ Secrets │
├──────────────────┼──────┼─────────────────┼─────────┤
│ requirements.txt │ pip  │       147       │    -    │
└──────────────────┴──────┴─────────────────┴─────────┘
Legend:
- '-': Not scanned
- '0': Clean (no security findings detected)
```

Read the legend as carefully as the
numbers: a dash means that scanner
did not look at this target, while a
0 means it looked and found nothing.
The secret scanner found no secrets
column to count here because
`requirements.txt` is a dependency
list, not a place secrets live — the
dash is honest bookkeeping, not a
failure.

Below the summary, one section per
target lists every finding. Its
header is the second number to learn
to read:

```text
requirements.txt (pip)
======================
Total: 147 (UNKNOWN: 0, LOW: 5, MEDIUM: 48, HIGH: 73, CRITICAL: 21)
```

**147 findings** from six packages.
That is what seven years of standing
still does: Django 2.2.0 alone carries
dozens of publicly documented holes,
and the counts pile up because every
year adds newly discovered flaws in
the same frozen code. Chapter 5 takes
this table apart row by row; for now,
stand back and take in the shape —
a summary, a severity breakdown, and
a long table sorted so the worst
comes first.

## The surprise: finding 147 problems is success

The scan's **exit code is 0**. The
shell reports that the command
succeeded, because it did: Trivy's
job was to look and report, and it
looked and reported. "Vulnerabilities
found" is not an error condition
unless you make it one — which is
exactly what `--exit-code` is for,
and chapter 9 is devoted to turning
this polite report into a gate that
fails a build. Until then, remember
the shape of the default: *a scanner
that always exits 0 will be ignored
by every pipeline it joins*, not
because people are careless, but
because green ticks train readers.

## A second fixture, for contrast

The lab's JavaScript fixture is the
same story in miniature — four
packages in a `package-lock.json`,
also pinned years ago:

```bash
trivy fs trivy-lab/fixtures/oldjs
```

Check (transcript
`trivy-lab/transcripts/t03-fs-scan-npm.txt`):
the summary counts **11** findings,
and the header breaks them down as
`Total: 11 (UNKNOWN: 0, LOW: 0,
MEDIUM: 4, HIGH: 6, CRITICAL: 1)`.
Small enough to read entire, this is
the report chapter 5 dissects.

## What the scan actually read

Notice what did not happen: no
virtual environment, no `pip install`,
no code executed. Trivy parsed one
text file — the lock-style list of
names and versions — and matched it
against the database. Two
consequences follow, and both will
matter later:

- **The list must be honest.** Trivy
  can only judge dependencies that
  are written down. A project whose
  versions are unpinned ranges in a
  setup file, or installed by hand
  and recorded nowhere, gives the
  scanner little to hold. Lock files
  — `requirements.txt` with exact
  pins, `package-lock.json`,
  `go.sum`, `Cargo.lock` and their
  kin — are the scanner's diet.
- **Transitives count.** Lock files
  record the dependencies of your
  dependencies, and Trivy reads the
  whole tree. The vulnerable package
  in a report is often one you never
  chose directly — you chose the
  thing that chose it.

With a report in hand and the shape
of it familiar, the next chapter
slows down and reads one properly.
