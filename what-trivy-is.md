# What Trivy Is

Almost nothing you run is one program.
A small web app stands on a framework,
which stands on libraries, which arrive
in a container image, which contains an
operating system's worth of packages.
Each of those parts was written by
somebody, and some of them contain
mistakes that turned out to be security
holes. When a hole is found, it is
usually given a public identifier — a
**CVE** number, such as CVE-2021-44906 —
a description, a severity, and, with
luck, a fixed version. That public
record is large, growing, and more than
any person can hold in their head.

**Trivy is a scanner that compares the
parts list of something you own against
that public record.** You point it at a
target: a **container image**, a folder
of code (a **filesystem** scan), a git
**repository**, or a pile of
**configuration** files. Trivy works
out what is in the target — which
versions of which libraries, which
operating-system packages — and looks
each one up in its **vulnerability
database**, a local copy of the public
record that it downloads and keeps
current. What it prints is a report:
every known problem found in your
parts, each with its identifier, its
severity, the version you have, and
the version that fixes it, if one
exists.

Trivy is made by Aqua Security, is
free and open source (Apache 2.0), and
is a single self-contained program:
one binary, no agent, no account, no
server of its own for the scans this
guide teaches. The same tool also
carries three more scanners beside the
vulnerability one — for configuration
mistakes, for secrets left in files,
and for software licences — and
chapters 7 and 8 put those to work.

## Why anyone would do this

Four honest reasons account for nearly
every legitimate use:

- **Housekeeping.** Software rots in
  place. The dependency you pinned
  three years ago has had six security
  fixes since. A scanner turns "we
  should really update something" into
  a list: these parts, these holes,
  these fixed versions.
- **Before you ship.** A container
  image is a promise about everything
  inside it. Scanning the image before
  it deploys catches the ancient base
  image and the forgotten library
  while the fix is still cheap.
- **In the build, automatically.**
  Trivy can fail with a chosen exit
  code when findings cross a severity
  line you set (chapter 9), which
  makes it a guardrail in a CI
  pipeline rather than a report
  somebody meant to read.
- **Answering the knock on the door.**
  When a serious flaw is announced in
  the news — a logging library, a
  compression library — the question
  is immediate: *do we run that, and
  where?* A scanner, or the bill of
  materials it can generate (chapter
  10), answers in minutes.

## The rule, stated before everything else

A list of a system's known weaknesses
is a valuable thing — to its owner,
and to anybody who would attack it.
A report from this tool is, in effect,
a map of where a machine can be hurt.
So this guide has one rule, and it is
not fine print:

> **Scan only what is yours — machines,
> images and code you own, or that you
> have explicit permission to scan.**

Scanning your own projects, your own
images, your own servers: yes, that is
the tool's whole purpose. Scanning a
public container image you have pulled
onto your own machine: also fine — the
image is yours to inspect and the
findings are public record. Pointing
scans at other people's running
systems, or enumerating a stranger's
weaknesses for them uninvited, crosses
the line from housekeeping into
reconnaissance, and in many places it
is against the law as well. The lab in
this guide stayed well inside the
rule: every target was a fixture
written for the purpose, or a public
image pulled onto the lab's own
machine, and the one "secret" in
chapter 8 was invented for the
occasion — the scanner's reaction to
it is the interesting part.

If a future idea you have for this
tool does not fit inside the rule, the
idea is the problem. Chapter 13
returns to this with the legal edge
spelled out a little further.

## A first taste

After installing (chapter 3), a scan
is one command. The guide's lab keeps
a folder of deliberately ancient
Python dependencies for the purpose:

```bash
trivy fs trivy-lab/fixtures/oldpy
```

Check: the summary at the top of the
report (transcript
`trivy-lab/transcripts/t02-fs-scan-python.txt`)
reads:

```text
Report Summary

┌──────────────────┬──────┬─────────────────┬─────────┐
│      Target      │ Type │ Vulnerabilities │ Secrets │
├──────────────────┼──────┼─────────────────┼─────────┤
│ requirements.txt │ pip  │       147       │    -    │
└──────────────────┴──────┴─────────────────┴─────────┘
```

Six packages, pinned in 2019 and never
revisited, carry 147 known
vulnerabilities between them — 21 of
them rated critical. Chapter 4 walks
through that scan properly; chapter 5
teaches you to read every column of
what follows the summary.

## Who it is for

The developer whose project has grown
dependencies the way a garden grows
weeds. The home-lab keeper running a
dozen containers whose base images
were young once. The maintainer who
needs to answer "are we affected?"
before lunch. The common thread is one
person, their own systems, and a wish
to replace a vague worry with a list
they can act on.

## What it is not

Trivy is not a **penetration test**:
it never touches a running service,
tries an exploit, or proves a hole is
reachable — it matches versions
against a database, and chapter 13 is
careful about the difference. It is
not an antivirus: it does not hunt
malware or watch behaviour. It is not
a patch tool: it tells you the fixed
version exists; installing it remains
your job, and your judgement (a fixed
version can still break your tests).
And it is not a guarantee: it knows
only what the public record knows, so
a clean scan is a statement about
known problems, never a certificate
of safety.
