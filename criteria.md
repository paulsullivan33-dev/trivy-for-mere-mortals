# Writing criteria for this guide

Every "for Mere Mortals" guide is written to the same nine-point
standard, so a reader who trusts one can trust the rest. Here it
is, with the verification notes for this particular guide below.

1. **Fix it first.** Reader outcomes lead, not action items: each
   chapter opens by naming the outcome it delivers, shows a check
   the reader can run to confirm they got it, and a reasonable
   reader finishes able to state what was done, what it means,
   and what to try next.
2. **Plain language.** Short sentences, everyday vocabulary,
   technical terms defined on first use. No slang, and no
   idioms that only make sense in one country — the reader may
   be translating as they go.
3. **No dead ends.** A guide never tells the reader to do
   something it cannot show them how to verify. Every claim a
   reader relies on — an install, a command, an output — is
   something this guide demonstrates or clearly labels
   documented-only below.
4. **Live-verified where it matters.** Procedures are run for
   real in the guide's lab wherever the build machine allows it,
   and the transcripts kept in the repository are the evidence.
   What could not be run is listed honestly below, never
   presented as if it had been.
5. **General audiences.** Nothing in this guide — examples,
   fixtures, names, addresses — is modelled on any particular
   reader or author's real life, network, or organisations.
   The lab's traffic is the lab talking to itself.
6. **Standalone.** A reader needs this guide, its lab, and
   nothing else. Where another guide would genuinely help, it
   is pointed to once, by name, and the chapter still completes
   without it.
7. **Honest about limits.** Chapter 13 names what the tool
   cannot do: flaws nobody has published yet, flaws whose
   reachability a version match cannot prove, whatever was
   never written into a lock file, findings nobody will ever
   fix, the report itself as a sensitive document, and the
   legal edge around scanning anything that is not yours.
8. **The ethics rule is in the text, early.** Chapter 1 and the
   README state the rule plainly — *your machines, your
   images, your code, or explicit permission to scan them* —
   before any procedure depends on it, and later chapters
   point back to it where the tooling would make crossing the
   line easy.
9. **Builds clean.** The site builds with MkDocs in strict mode
   with no warnings, and a fresh reader following the chapters
   in order reaches the stated outcome of each.

## Verification notes for this guide

The build machine is a 2-CPU, 7.7 GB Ubuntu 24.04 sandbox.
Trivy **0.76.1** was fetched as the official release archive
from the project's GitHub releases and run as the bare binary
from a scratch folder on the path. Every fixture lives in
`trivy-lab/fixtures/`; every transcript in
`trivy-lab/transcripts/`.

Run for real, with transcripts as evidence:

- Version and database state (`trivy version`: database
  built 2026-10-28, next build expected the following day)
  (t00).
- The vulnerability database download itself, 130.11 MiB
  from `ghcr.io/aquasecurity/trivy-db:2` in about 15 seconds
  (t01) — after the first attempt, which used the default
  database route and stalled for the full ~31 minutes to a
  `context deadline exceeded` (t90). The lab's network is a
  sandboxed one; the transcripts keep both outcomes and
  chapter 3 presents the explicit-repository flag and the
  timeout flag as the general remedies.
- Filesystem scan of a fixture Python project with six
  2019-era pins: 147 findings (21 CRITICAL, 73 HIGH,
  48 MEDIUM, 5 LOW), exit code 0 by default (t02).
- Filesystem scan of a fixture npm project: 11 findings
  (1 CRITICAL — minimist CVE-2021-44906 — 6 HIGH, 4 MEDIUM),
  including identifiers from the Node ecosystem's own
  database (t03).
- The CI gate both ways: `--severity CRITICAL --exit-code 1`
  fails (exit 1) on the npm fixture's single critical and
  passes (exit 0, count 0) on a fixture pinning one current
  package (t04).
- `--ignore-unfixed` on the Python fixture: no change —
  all 147 findings carry a fixed version, verified in the
  JSON output (t05).
- Image scans of two public images pulled by the lab:
  `alpine:3.12` (14 OS packages, one CRITICAL — zlib
  CVE-2022-37434 — plus the end-of-life OS warning) (t06)
  and `debian:9-slim` (68 findings; 46 affected,
  16 will_not_fix, 4 fix_deferred, 2 fixed), where
  `--ignore-unfixed` takes the total from 68 to 2 (t07).
- Config scan of a planted-bad Dockerfile, Terraform file
  and Kubernetes manifest: 136 checks, 40 failures —
  Dockerfile 5 of 27 (DS001/DS002/DS004/DS026/DS029),
  Kubernetes 21 of 95, Terraform 14 of 14 including
  AVD-AWS-0092 (public ACL) and AVD-AWS-0107 (unrestricted
  ingress), with the checks bundle (165 KiB) downloaded
  from `ghcr.io/aquasecurity/trivy-checks:1` (t08).
- Secret scanning: the AWS documentation's published
  example key pair is **not** flagged (verified twice, in
  two file formats — the scanner allowlists the famous
  examples), while an invented look-alike pair in a config
  file is flagged as 2 CRITICAL findings with masked
  values and exact line numbers (t09).
- Licence scanning after a real `npm install` of the
  fixture's four packages (licence data lives in installed
  packages, not the lock file): ini ISC, lodash MIT,
  y18n ISC, classified "notice", all LOW severity (t10).
- CycloneDX SBOM generation: 7 components; vulnerabilities
  absent by default (the format disables security
  scanning, as Trivy's own INFO line warns) and all 147
  present once `--scanners vuln` is named (t11).
- `.trivyignore` acceptance of the critical finding, with
  a written reason: the chapter 9 gate goes green
  (exit 0). The file's expiry dates were also exercised
  separately in the lab: an entry with an expiry date in
  the past lets the finding back in; one in the future
  keeps it accepted (t12).
- `trivy repo` over a local git repository built from the
  npm fixture: the identical 11 findings (t13).

Documented only — described from the project's documentation,
not run, and the text does not claim otherwise:

- Install routes other than the release archive (OS package
  repositories, Homebrew, the official container image).
- `trivy rootfs`, scans of image archives via `--input`,
  private registries and their credentials.
- Cluster scanning (`trivy kubernetes`), the Trivy
  Operator, and Trivy's client–server mode.
- SARIF and template-based output, including the HTML
  report; JSON was used behind the scenes (status census of
  the Python fixture's findings) but is described, not
  exhibited. The SBOM chapter generates CycloneDX; the
  SPDX variant is named only.
- Hosted CI integrations and Aqua Security's commercial
  platform.
- The comparison tools in chapter 12 are characterised,
  not benchmarked.

Fixtures are this guide's own and deliberately generic: two
small projects pinning real, publicly known old package
versions; a Dockerfile, Terraform file and Kubernetes
manifest written to break rules; a notes file holding AWS's
own published **example** credentials (which exist to be
printed); and one AWS-shaped key pair invented at random for
this lab — it is not, and never was, a real credential. The
two container images are public images pulled from a public
registry onto the lab's machine. No example is modelled on
any real person, network, service or organisation, and
nothing was scanned that the lab did not itself create or
pull.
