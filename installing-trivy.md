# Installing Trivy

Trivy is a single compiled program, so
installing it means fetching one
binary and putting it somewhere on
your path. There is no runtime to
satisfy, no database server to set
up, nothing to configure before the
first scan. This guide's lab used the
official release archive from the
project's GitHub releases — the route
taught here because it works the same
on any Linux machine. The project
also publishes packages for the usual
package managers (an apt and yum
repository, Homebrew, and others) and
an official container image; those
routes end at the same `trivy`
command and the official installation
documentation walks through each.

## The release binary

You need the archive for your machine
from the releases page of
`github.com/aquasecurity/trivy`. The
names are regular: for a 64-bit Linux
machine and version 0.76.1, the file
is `trivy_0.76.1_Linux-64bit.tar.gz`
(about 53 MB — it carries the binary
plus a folder of report templates).
Unpacked, the program is the single
file `trivy`:

```bash
curl -LO https://github.com/aquasecurity/trivy/releases/download/v0.76.1/trivy_0.76.1_Linux-64bit.tar.gz
tar xzf trivy_0.76.1_Linux-64bit.tar.gz trivy
sudo install -m 0755 trivy /usr/local/bin/
trivy --version
```

(The lab kept its binary in a scratch
folder and put that folder on its
path instead — the same program,
without touching the system.)

Check: once the vulnerability
database has been downloaded (the
next section), `trivy version` prints
both the program and the state of
the database (transcript
`trivy-lab/transcripts/t00-version.txt`):

```text
$ trivy version
Version: 0.76.1
Vulnerability DB:
  Version: 2
  UpdatedAt: 2026-10-28 01:21:08.391884645 +0000 UTC
  NextUpdate: 2026-10-29 01:21:08.391884123 +0000 UTC
  DownloadedAt: 2026-10-28 05:20:55.466077415 +0000 UTC
```

Those three dates are worth learning
to read now. **UpdatedAt** is when
the database's contents were built —
the freshness of everything Trivy
will tell you. **NextUpdate** is when
the next build is expected, about a
day later; the database is rebuilt
roughly daily. **DownloadedAt** is
when your copy arrived. A scan is
only as current as the first of
those, a fact chapter 13 leans on.

## The first database download

Trivy cannot scan until its
vulnerability database is home. The
first scan of any kind triggers the
download; you can also fetch it on
its own, which the lab recommends —
it separates "the database will not
come down" from "the scan did
something odd", two problems that are
much easier apart:

```bash
trivy fs --download-db-only trivy-lab/fixtures/oldpy
```

On a healthy network this is a
~130 MB download and a matter of
seconds to minutes. The database
lands in the cache — `~/.cache/trivy`
unless `--cache-dir` says otherwise —
and occupies roughly 1.6 GB unpacked.
From then on, scans are local and
fast, and Trivy refreshes the
database quietly when it is stale.

The lab's first attempt did none of
that, and the failure is instructive
enough to keep. A plain first scan,
with no repository named, chose
Trivy's default database route — a
mirror of the database hosted on
Google's container infrastructure —
and on the lab's network that route
simply stalled: the download sat for
the full default deadline of about
half an hour and then failed with
`context deadline exceeded`
(transcript
`trivy-lab/transcripts/t90-db-download-timeout.txt`).
Nothing was wrong with the program,
the fixture, or the command. The
road was closed.

Naming the database's other official
home — GitHub's container registry —
routed around it:

```bash
trivy fs --download-db-only \
  --db-repository ghcr.io/aquasecurity/trivy-db:2 \
  --timeout 120m \
  trivy-lab/fixtures/oldpy
```

Check: the whole database arrived in
about fifteen seconds (transcript
`trivy-lab/transcripts/t01-db-download.txt`):

```text
2026-10-28T05:20:37Z INFO [vulndb] Downloading artifact... repo="ghcr.io/aquasecurity/trivy-db:2"
[progress bar: 130.11 MiB downloaded, reaching 100% in about 15 seconds]
2026-10-28T05:20:55Z INFO [vulndb] Artifact successfully downloaded repo="ghcr.io/aquasecurity/trivy-db:2"
```

Two flags from that command are worth
remembering. `--db-repository` chooses
where the database comes from; the
project publishes it to both
registries, and whichever your network
reaches happily is the right one.
`--timeout` raises the deadline the
download (or a slow image pull) is
allowed — Trivy's own error message
suggests it when a deadline is hit.
Most readers on an ordinary home
connection will never need either:
the lab's network is a sandboxed one
with an unusual gatekeeper, and the
stall is recorded here because a
guide that hides its lab's bad
afternoon teaches less than one that
keeps the transcript.

## Keeping the database fresh

Nothing to schedule by hand for
ordinary use: Trivy checks the
database's age when it runs and
downloads a fresher one when the
copy it has is older than the current
build. In an offline or restricted
setting, the same `--download-db-only`
command is the manual refresh, and
`--skip-db-update` tells a scan to
use whatever is cached and not ask
the network at all — the flag
chapter 11's scheduled scans and
chapter 14's troubleshooting both
have reason to mention.
