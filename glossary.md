# Glossary

**Advisory** — the published account
of a flaw: what it is, what it
affects, how bad it is judged to be,
and what fixes it. Trivy's database
is built from advisories (chapter 2).

**AVD** — Aqua's vulnerability and
misconfiguration library
(`avd.aquasec.com`): one public page
per finding, linked from every
report row (chapters 5 and 7).

**Base image** — the image a
container build starts `FROM`; it
contributes the operating system and
its packages to everything built on
it (chapter 6).

**Cache** — where Trivy keeps its
downloaded databases between runs
(`~/.cache/trivy` by default), and
why repeat scans are fast
(chapter 3).

**Checks bundle** — the downloadable
rule set the config scanner applies
to Dockerfiles, Terraform,
Kubernetes manifests and other
infrastructure files (chapter 7).

**CVE** — Common Vulnerabilities and
Exposures: the public identifier
scheme for known flaws, a year plus
a serial number (CVE-2021-44906).
Some ecosystems keep their own
identifiers alongside (chapter 5).

**CycloneDX / SPDX** — the two
standard SBOM formats Trivy can
generate; CycloneDX is the one the
lab produced (chapter 10).

**Exit code** — the number a command
leaves for the shell. Trivy's
default is 0 even with findings;
`--exit-code 1` turns a scan into a
gate a build can fail (chapter 9).

**Layer** — one stratum of a
container image, from one build
step. Findings can be traced to the
layer that introduced the package
(chapter 6).

**Lock file** — the file that pins a
project's exact dependency versions:
`requirements.txt` with pins,
`package-lock.json`, `go.sum`,
`Cargo.lock`. The filesystem
scanner's diet (chapter 4).

**Misconfiguration** — a flaw in
instructions rather than code: the
public bucket, the root container,
the open port (chapter 7).

**Package URL (purl)** — a standard
string identifying a package
precisely (ecosystem, name,
version). SBOM components carry one
(chapter 10).

**Prototype pollution** — a class of
JavaScript flaw where an attacker
modifies the prototype every object
inherits from; the fixture report in
chapter 5 is full of it.

**Reachability** — whether flawed
code can actually be reached and
triggered in a running system.
Trivy reports presence, not
reachability (chapter 13).

**Registry** — where container
images and Trivy's own databases
are published and pulled from:
Docker Hub, GHCR and others
(chapters 3 and 6).

**SARIF** — a standard format for
scan results, ingested by
code-scanning dashboards such as
GitHub's (chapter 10).

**SBOM** — a software bill of
materials: the inventory of a
target's components in a standard
format, for keeping and re-judging
later (chapter 10).

**Scanner** — one of Trivy's four
questions about a target: **vuln**
(vulnerabilities), **config**
(misconfigurations), **secret**
(credentials in files), **license**
(dependency licences). Chosen with
`--scanners` (chapter 2).

**Severity** — how bad a flaw is
judged to be by the advisory that
scored it: UNKNOWN, LOW, MEDIUM,
HIGH or CRITICAL (chapter 5).

**Status** — what upstream has done
about a flaw: **fixed** (a corrected
version exists), **affected** (real,
unfixed), **will_not_fix** (the
distributor has decided),
**fix_deferred** (chapter 5).

**Target** — what a scan examines:
an image, a filesystem, a
repository, a set of config files,
an SBOM (chapter 2).

**`.trivyignore`** — a file listing
finding identifiers a scan should
accept, with room for the reason and
an expiry date; the written record
of a deliberate decision
(chapter 9).

**Vulnerability database** — Trivy's
local copy of the public record of
known flaws, downloaded on first
use and refreshed roughly daily
(chapter 3).
