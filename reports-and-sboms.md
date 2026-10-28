# Reports and SBOMs

Everything so far has ended at a
terminal table. Tables are for
reading; the moment a second tool, a
dashboard, or next month's you needs
the results, the scan wants a format
meant for keeping. Trivy renders the
same findings several ways, and can
also stop reporting findings at all
and hand you the inventory itself —
the **SBOM**, the software bill of
materials. This chapter runs the
important one and maps the rest.

## The formats

`--format` chooses the shape, and
`--output` writes it to a file
instead of the screen:

- **table** — the default, everything
  in the earlier chapters.
- **json** — the findings as data:
  targets, packages, identifiers,
  severities, the lot. The format
  other programs read, and the one to
  archive when you want to diff this
  month against last.
- **sarif** — the standard format
  code-scanning dashboards ingest;
  this is the shape GitHub's code
  scanning expects, so findings appear
  as alerts on the repository.
- **templates** — `--format template`
  with a template file renders custom
  output; the release archive ships
  several in its `contrib/` folder,
  including an HTML report you can
  open in a browser and formats for
  particular CI systems.

The lab lived in the table and the
JSON behind the scenes; SARIF and
the templates are described from the
documentation, not run.

## Generating a bill of materials

A **SBOM** inverts the usual scan:
instead of "which of these parts are
known-bad", it answers "which parts
are there at all", in a standard
format other tools can consume.
Trivy generates one from any target:

```bash
trivy fs --format cyclonedx --output trivy-lab/oldpy-sbom.json trivy-lab/fixtures/oldpy
```

Check the transcript
(`trivy-lab/transcripts/t11-sbom.txt`).
The file is **CycloneDX** JSON
(spec version 1.7; SPDX is the other
format offered), and its contents
count out as:

```text
bomFormat: CycloneDX | specVersion: 1.7
components: 7
vulnerabilities listed: 0
```

Seven components — the six pinned
packages plus the project itself as
the root component — each with its
name, version, and a **package URL**
identifying it precisely. Kept with
a release, this file is how you
answer, months later and in seconds,
the question chapter 1 posed: a new
critical flaw is announced in some
library — *do we ship it, and
where?* (The generated files
themselves were removed after the
lab counted them; the transcript is
the evidence, and the command above
regenerates them.)

## The trap in the format flag

Read the transcript's first lines
again — Trivy says something there
that is easy to skim past:

```text
INFO "--format cyclonedx" disables security scanning. Specify "--scanners vuln" explicitly if you want to include vulnerabilities in the "cyclonedx" report.
```

By default, asking for an SBOM
switches the security scanners
**off**: the bill of materials is a
pure inventory, and its
`vulnerabilities listed: 0` is a
design decision, not a clean bill
of health. Add the scanners back
explicitly —

```bash
trivy fs --format cyclonedx --scanners vuln --output trivy-lab/oldpy-sbom-vuln.json trivy-lab/fixtures/oldpy
```

— and the same file carries the
findings too: the transcript's
second count reads **vulnerabilities
listed: 147**. Neither file is
wrong. They answer different
questions, and confusing them —
filing the pure inventory as though
it were a security report — is
exactly the species of mistake
chapter 14 exists to catch. An SBOM
can also be fed back in as a target
(`trivy sbom`), which is how a kept
bill of materials gets re-judged
against tomorrow's database without
the original project at hand.
