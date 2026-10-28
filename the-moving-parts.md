# The Moving Parts

Trivy looks like one command because
it is one program, but five ideas do
the work. Keep them separate in your
head and every later chapter becomes a
matter of pointing the right idea at
the right thing.

## Targets: the subcommands

The first word after `trivy` chooses
what is being examined:

| Command | Target | Used in |
|---|---|---|
| `trivy image` | A container image, named from a registry or loaded from a tar file | Chapter 6 |
| `trivy fs` | A folder on disk: source code, lock files, a whole checked-out project | Chapters 4–5, 8 |
| `trivy repo` | A git repository, local or cloned from a remote address | Chapter 5 |
| `trivy config` | Configuration files: Dockerfiles, Terraform, Kubernetes YAML and friends | Chapter 7 |
| `trivy rootfs` | An unpacked root filesystem, such as a mounted machine image | Not run in the lab |
| `trivy sbom` | A bill of materials in SBOM form, scanned as a target in its own right | Chapter 10 |
| `trivy kubernetes` | A whole cluster, inventoried and scanned | Documented only |

The lab ran the first four for real.
`rootfs`, `kubernetes` and cluster
scanning in general need machines and
clusters the lab did not have, and are
described from the documentation only.

## Scanners: the questions asked

Orthogonal to the target is the
**scanner** — which question to ask of
it. There are four, chosen with
`--scanners`:

- **vuln** — known vulnerabilities in
  operating-system packages and
  language libraries. The default, and
  the scanner behind most of this
  guide.
- **config** — misconfigurations in
  infrastructure-as-code files: the
  open bucket, the root container, the
  missing encryption (chapter 7).
- **secret** — credentials and keys
  left in files: access keys, tokens,
  private keys (chapter 8).
- **license** — which licences your
  dependencies carry, classified by
  how restrictive they are (chapter 8).

If you do not choose, a filesystem
scan runs **vuln** and **secret** —
watch for the startup lines in the
transcripts, which say exactly that.
One warning to carry forward to
chapter 10: choosing a report *format*
can quietly change which scanners run.
Generating a bill of materials turns
the security scanners **off** unless
you name them, a behaviour the lab
verified and chapter 10 demonstrates.

## The two databases

Trivy knows what it knows from two
downloaded bundles, both cached on
your machine and refreshed as needed:

- **The vulnerability database** —
  the public record itself, gathered
  from the National Vulnerability
  Database, the security advisories of
  the Linux distributions, and the
  advisory databases of the language
  ecosystems. About 130 MB to
  download, considerably more unpacked
  in the cache. This is the database
  `trivy version` reports on, with the
  date it was built and the date the
  next build is expected.
- **The checks bundle** — the rules
  the **config** scanner applies:
  some 165 KB of policies for
  Dockerfiles, Terraform plans and
  manifests, Kubernetes, cloud
  templates and more. Chapter 7's scan
  pulled it down on first use.

Both live in the **cache**
(`~/.cache/trivy` by default, moved
with `--cache-dir`). Repeat scans are
fast precisely because the knowledge
is already home: the lab's scans of a
small folder finished in well under a
second once the database had landed.
Chapter 3 is about getting the first
download home; chapter 14 is about
what to do when it will not come.

## The report

Everything converges on one output
shape. A scan ends in a **report**: a
summary table first (targets, counts
of findings), then one section per
target with a row per finding. For
vulnerabilities, each row carries the
library, the vulnerability's
identifier, its severity, its
**status** (whether upstream has
fixed it, will not fix it, or has not
yet), the version you have, the
version that fixes it, and a title
with a link to the advisory —
Aqua keeps a public page per finding
at `avd.aquasec.com`. Chapter 5 takes
a real report apart column by column.

## The shapes it can leave in

The same findings can be rendered as
a **table** for a human at a terminal
(the default), as **JSON** for a
program, as **SARIF** for code-scanning
dashboards such as GitHub's, or
through **templates** (an HTML report
template ships with the release). And
instead of a report on findings, a
scan can emit a **SBOM** — a software
bill of materials in CycloneDX or
SPDX form: the inventory itself, for
keeping, diffing, or feeding to other
tools (chapter 10 does this for real).

## The parts this guide does not run

Three documented pieces deserve a
mention so their absence later is not
a surprise. Trivy has a **client–
server mode**, where a central
`trivy server` holds the database and
light clients ask it questions —
useful to a fleet, unnecessary to one
person. The **Trivy Operator** runs
inside a Kubernetes cluster and scans
what the cluster runs, continuously.
And Aqua sells a commercial platform
built around the same engine, with
dashboards, policies and asset
inventories. All three are real, all
three are beyond the lab, and the
guide labels them documented-only
wherever they would otherwise appear.
