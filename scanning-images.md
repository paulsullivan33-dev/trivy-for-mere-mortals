# Scanning Images

A filesystem scan judges the parts
you wrote down. An **image scan**
judges the parts as they actually
shipped: Trivy pulls the container
image (or reads one you hand it),
unpacks its layers, and inventories
everything inside — the operating
system's packages from the image's
own package manager, plus any
language libraries baked in. This is
the scan to run on the thing you are
about to deploy, because it cannot
be fooled by a tidy source tree
sitting on a neglected base image.

## A small old image

```bash
trivy image alpine:3.12
```

Alpine Linux 3.12 is a small, old,
end-of-life release — a good patient.
Check the shape of the transcript
(`trivy-lab/transcripts/t06-image-scan.txt`):

```text
2026-10-28T05:17:39Z INFO Detected OS family="alpine" version="3.12.12"
2026-10-28T05:17:39Z INFO [alpine] Detecting vulnerabilities... os_version="3.12" pkg_num=14
2026-10-28T05:17:39Z WARN This OS version is no longer supported by the distribution family="alpine" version="3.12.12"
2026-10-28T05:17:39Z WARN The vulnerability detection may be insufficient because security updates are not provided
```

Three things happened in those four
lines. Trivy identified the operating
system and its exact point release
from the image's own files. It found
**14 OS packages** to check. And it
warned, before printing a single
finding, that this OS is **no longer
supported** — the distribution has
stopped publishing the security
updates the database is built from,
so the report that follows is a
floor, not a ceiling. Treat that
warning as a finding in its own
right; it is often the most
important sentence in the scan.

The report itself is almost a
relief after chapter 4:

```text
alpine:3.12 (alpine 3.12.12)
============================
Total: 1 (UNKNOWN: 0, LOW: 0, MEDIUM: 0, HIGH: 0, CRITICAL: 1)

│ zlib │ CVE-2022-37434 │ CRITICAL │ fixed │ 1.2.12-r0 │ 1.2.12-r2 │ zlib: heap-based buffer over-read and overflow in inflate() │
```

One critical flaw, in `zlib` — the
compression library nearly everything
carries — and a fix exists within the
same release line (`-r2`). Small old
images are not automatically
disasters; neglected *big* ones are.

## An image full of findings nobody will fix

For the opposite extreme, the lab
scanned Debian 9 — "stretch", long
past its own end of life:

```bash
trivy image debian:9-slim
```

Check (transcript
`trivy-lab/transcripts/t07-ignore-unfixed-image.txt`):
**Total: 68** (LOW 34, MEDIUM 4, HIGH
28, CRITICAL 2). And here is the part
chapter 5 promised: of those 68
findings, exactly **two** have a fix.
The statuses behind the scenes were
46 **affected**, 16 **will_not_fix**,
4 **fix_deferred** — a distribution
that has stopped maintaining the
release has, mostly, stopped fixing
it too. No upgrade path exists inside
the image; the fix for a wall like
this is a newer base image, which is
a project decision, not a patch.

This is also the natural home of the
flag chapter 9 uses for build gates:

```bash
trivy image --ignore-unfixed debian:9-slim
```

**Total: 2.** `--ignore-unfixed`
hides every finding whose status is
not *fixed*, leaving only the
actionable. Used honestly, it focuses
a report on what can be done. Used
lazily, it hides 66 real flaws behind
a small number — chapter 9 discusses
telling those two uses apart, and
chapter 13 will not let the point go.

## Practical notes

- **Pulling is part of the scan.**
  Naming an image fetches it from its
  registry, which needs the network
  and the registry's goodwill; big
  images take real time and cache
  space. A scan of an image already
  on the machine costs neither.
- **Private images** work through
  the usual registry credentials —
  Trivy reads the same Docker
  configuration your other tools log
  in with. The lab used only public
  images; private registries are
  documented-only here.
- **Images from files.** An image
  saved with `docker save` (or built
  into an archive by another tool)
  can be scanned with
  `--input image.tar`, the route for
  air-gapped machines and CI
  artifacts — described from the
  documentation; the lab's images all
  arrived by name.
- **Layers explain, findings accuse.**
  JSON output (chapter 10) records
  which layer introduced a package,
  which is how you learn that the
  flaw came in with the base image
  and not with your `COPY`.
