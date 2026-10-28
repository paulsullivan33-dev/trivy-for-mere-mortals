# Troubleshooting

Symptom first, cause second, in the
order the lab and the documentation
suggest you check them.

## The database download stalls, then fails

*The first scan sits at "Downloading
vulnerability DB..." for ages and
dies with `context deadline
exceeded`. The lab's own first half
hour (transcript t90).*

1. **The route to the database's
   registry is the problem.** Trivy's
   default route on the lab's network
   stalled for the full ~30-minute
   deadline while another official
   home of the same database answered
   in seconds. Name the other one
   explicitly:
   `--db-repository ghcr.io/aquasecurity/trivy-db:2`.
2. **The deadline is too short for
   your network.** The error message
   itself suggests the cure:
   `--timeout 120m` (or any generous
   value) on the download.
3. **Separate downloading from
   scanning.** Fetch the database on
   its own —
   `trivy fs --download-db-only <any folder>` —
   so a download failure cannot
   masquerade as a scan result, and
   confirm with `trivy version`,
   which prints whether a database
   exists and how old it is.

## The scan finds nothing, and you do not believe it

*A clean report on something that
should not be clean.*

1. **A format switched the scanners
   off.** Generating an SBOM
   (`--format cyclonedx` or `spdx`)
   disables security scanning unless
   `--scanners vuln` is named
   (chapter 10). The INFO line at
   the start of the output says so —
   read the startup lines before the
   summary.
2. **A severity filter is hiding
   the finding.** `--severity`
   narrows the report as well as the
   gate. Re-run without it before
   declaring a target clean.
3. **The scanner never read the
   target.** In the summary table,
   `-` means *not scanned* and `0`
   means *scanned, nothing found*.
   Unsupported or unpinned dependency
   lists leave nothing to match
   (chapter 4); point Trivy at the
   lock file, not the folder that
   merely wishes it had one.
4. **An ignore file is answering
   for you.** A `.trivyignore` in
   the folder accepts findings
   silently (chapter 9). Check for
   the file — and for entries whose
   expiry date has not arrived yet.
5. **The database predates the
   flaw.** `trivy version` shows the
   build date. Refresh and re-run
   before concluding anything from
   an empty report on the day a big
   vulnerability is in the news.
6. **The secret is a shape the
   scanner ignores on purpose.**
   Published example credentials are
   allowlisted (chapter 8), and
   home-grown token formats have no
   rule. A quiet secret scan is the
   weakest clean result Trivy
   prints.

## Licence scanning reports nothing

*The licences column is dashes, or
the startup lines warn that licence
detection was skipped (both seen in
the lab, transcripts t02 and t10).*

The licence scanner reads licence
data from **installed** packages.
For npm projects, run `npm install`
in the project first — Trivy's own
log line says exactly this. For
Python, the packages must exist in
an installed `site-packages`; a
bare `requirements.txt` carries
versions but not licences. Install
the dependencies (in a scratch copy
if you do not want them live), then
scan.

## Scans are slow

1. **First run pays for the
   database** (~130 MB, plus ~165 KB
   of checks for config scans).
   Later runs read the cache and
   small targets finish in about a
   second. If every run is slow,
   something is discarding the cache
   (`--cache-dir` pointing somewhere
   ephemeral is the usual suspect).
2. **Big images cost pull time.**
   Scan the local copy, or an
   exported tar with `--input`,
   rather than re-pulling.
3. **Secret scanning is the slow
   part of a filesystem scan** on
   large trees. Trivy's startup
   lines say so themselves; when you
   do not need it, `--scanners vuln`
   turns it off.

## An image will not pull

Trivy reads registry credentials
from the standard Docker
configuration, so an image you can
`docker pull` is an image Trivy can
usually scan. Failures divide into
the registry refusing (credentials,
a private repository, a tag that
does not exist) and the network
refusing (the same species of
trouble as the database stall
above). The lab pulled its public
images without incident, so private
registries stand documented-only in
this guide; the project's
troubleshooting pages keep the
current word on registry quirks.

## The build stays green with findings everywhere

The default is doing it: without
`--exit-code`, Trivy reports and
exits 0 (chapter 4). Add
`--exit-code 1` and a `--severity`
line, as chapter 9 does — and check
the step is running the scan you
think it is, against the folder or
image you think it is. A gate
scanning last month's checkout is
green for the worst of reasons.
