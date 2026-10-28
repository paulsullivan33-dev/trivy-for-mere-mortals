# Trivy for Mere Mortals

Every program you run is built out of
other people's programs: libraries,
base images, an operating system's
packages. Some of those parts have
known holes — flaws that were found,
given a public number, and fixed in a
later version that you may never have
installed. **Trivy** is a scanner that
reads the list of parts in something
you own — a container image, a project
folder, a configuration file — and
checks each part against that public
record. It answers one question: *of
the known problems, which ones are in
here, and how bad are they?*

This guide explains how Trivy works,
how to scan a project and read the
report it prints, how to scan container
images and cloud configuration, how it
spots secrets and licences as well as
vulnerabilities, and how to make a
build fail loudly when the answer is
bad enough. The limits are stated
plainly, including the big one: a clean
scan means *no known problems found*,
which is not the same sentence as
*safe*.

The rule that governs everything here
is stated in chapter 1 and repeated in
chapter 13: **your machines, your
images, your code, or explicit
permission to scan them.** The lab
obeyed it strictly. Every scan in this
guide ran against fixtures the lab
wrote for the purpose, or against
public container images the lab pulled
onto its own machine.

The lab behind this guide ran the real
thing: **Trivy 0.76.1**, the official
release binary from the project's
GitHub releases, on a small Linux
machine. Trivy downloaded its
vulnerability database (about
130 MB), and against the lab's fixtures
it found 147 known vulnerabilities in
six deliberately ancient Python
packages and 11 more in four old
JavaScript ones — including a critical
prototype pollution flaw with a known
fix. It scanned two real container
images pulled from a public registry,
ran 136 configuration checks against a
Dockerfile, a Terraform file and a
Kubernetes manifest the lab had
booby-trapped (40 checks failed,
including an S3 bucket with a public
access list and a security group with
SSH open to the world), caught an
invented AWS key pair planted in a
config file, inventoried the licences
of installed packages, and produced a
CycloneDX bill of materials. The
severity gates of chapter 9 were run
for real both ways: a scan that failed
with exit code 1 because a critical
finding was present, and the same gate
green again after the finding was
formally accepted in an ignore file.

What the lab could not do, it did not
fake. The database download itself
supplied the lesson: on the lab's
network, Trivy's default database
route stalled for a full half hour and
the failure, and the flag that routed
around it, are documented in chapter 3
and chapter 14 rather than tidied
away. Scanning a live Kubernetes
cluster, the Trivy Operator, hosted CI
services and Aqua's commercial
platform are taught from the
documentation and labelled as such
wherever they appear. `criteria.md`
keeps the full ledger of what was run
and what was only read.

## What this guide covers

- [**What Trivy is**](what-trivy-is.md) —
  the mental model: an inventory of
  parts checked against the public
  record of known flaws, and the rule
  about scanning only what is yours
- [**The moving parts**](the-moving-parts.md) —
  the targets (image, filesystem, repo,
  config), the four scanners
  (vulnerability, config, secret,
  licence), the two databases, and the
  cache that makes repeat scans fast
- [**Installing Trivy**](installing-trivy.md) —
  the release binary and the other
  install routes, the first database
  download, and the stall the lab hit
  on the way
- [**Your first scan**](your-first-scan.md) —
  scanning a project with ancient
  dependency pins, and reading the
  summary of 147 findings without
  panicking
- [**Reading a report**](reading-a-report.md) —
  one report taken apart: CVE numbers,
  severity, status, installed and fixed
  versions, and what to do first
- [**Scanning images**](scanning-images.md) —
  container images scanned layer by
  layer: operating-system packages,
  end-of-life warnings, and the
  findings nobody will ever fix
- [**Scanning for misconfigurations**](scanning-for-misconfigurations.md) —
  Dockerfiles, Terraform and Kubernetes
  YAML checked against 136 rules, with
  the failing lines quoted back at you
- [**Secrets and licences**](secrets-and-licences.md) —
  a planted key pair caught in the
  act, the famous example keys the
  scanner deliberately ignores, and an
  inventory of what your dependencies
  are licensed under
- [**Severity, exit codes and CI**](severity-exit-codes-and-ci.md) —
  making a scan fail a build: severity
  filters, exit codes, ignoring the
  unfixable, and formally accepting a
  finding
- [**Reports and SBOMs**](reports-and-sboms.md) —
  tables for humans, JSON and SARIF for
  machines, and generating a CycloneDX
  bill of materials — plus the format
  that quietly turns scanning off
- [**Recipes**](recipes.md) — check an
  image before you deploy it, audit a
  repository you just cloned, keep a
  dated SBOM for everything you run,
  and re-scan on a schedule
- [**The neighbours**](the-neighbours.md) —
  Grype, OSV-Scanner, Docker Scout,
  Snyk, the update bots, and the
  config-only scanners: who does what
  that Trivy doesn't, and vice versa
- [**Limits**](limits.md) — known
  problems are the only kind it finds,
  a version match is not proof of
  danger, a report is a sensitive
  document, and the legal edge around
  scanning other people's systems
- [**Troubleshooting**](troubleshooting.md) —
  the database download that stalls,
  the scan that finds nothing for the
  wrong reason, the licence scan that
  skips itself, and the traps this
  guide's lab fell into so you don't
  have to
- [**Glossary**](glossary.md) — the
  terms, collected in one place

## What it doesn't cover

Scanning systems you do not own or have
no permission to test — that is
reconnaissance, not housekeeping, and
chapter 13 explains the line. Exploiting
anything Trivy finds is likewise out:
this is a guide to reading the list,
not to using it as a weapon. Running
Trivy as an organisation-wide service —
the Kubernetes operator, admission
policies, a client–server deployment,
Aqua's commercial platform — is pointed
at, not taught; this guide stays with
one person, their own machines, and the
command line, where the tool does its
honest work.

## How to use this guide

Read chapter 1 for the model and the
rules, and chapter 2 before installing
anything — knowing which database feeds
which scanner turns later confusion
into a named problem. Chapter 4 takes
your first scan in the same sitting as
the install, against a fixture folder
that ships with this guide, so the
output you see is the output this guide
describes. Chapter 5 is the one to read
slowly: everything Trivy ever tells you
arrives in that report's shape. Chapter
9 is where the tool becomes a guardrail
rather than a report you feel guilty
about — wire the gate while the fixture
is still fictional. The lab's
transcripts live in
`trivy-lab/transcripts/`; its fixtures
are `trivy-lab/fixtures/`; its notes
are `examples/lab-notes.txt`.

---

## Part of the series

This guide is one of the [For Mere Mortals](https://paulsullivan33-dev.github.io/mere-mortals/) guides: plain-language guides to the tools programmers and makers use.

Related guides:

- [Docker for Mere Mortals](https://paulsullivan33-dev.github.io/docker-for-mere-mortals/)
- [Kubernetes for Mere Mortals](https://paulsullivan33-dev.github.io/kubernetes-for-mere-mortals/)
- [Cybersecurity for Mere Mortals](https://paulsullivan33-dev.github.io/cybersecurity-for-mere-mortals/)

## License

The writing in this guide is licensed under [CC BY 4.0](https://github.com/paulsullivan33-dev/trivy-for-mere-mortals/blob/main/LICENSE). Code examples and lab scripts are licensed under the [MIT License](https://github.com/paulsullivan33-dev/trivy-for-mere-mortals/blob/main/LICENSE-CODE).
