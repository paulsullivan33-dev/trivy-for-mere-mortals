# Severity, Exit Codes and CI

Chapter 4 ended with a warning: by
default Trivy exits 0 even with a
report full of criticals, and a check
that is always green will be ignored.
This chapter builds the gate. Four
controls, each run for real in the
lab, turn the polite report into a
rule a build can live under:
**--severity** to choose what counts,
**--exit-code** to make it count,
**--ignore-unfixed** to set aside
what cannot be acted on, and the
**.trivyignore** file to record a
deliberate acceptance.

## The gate, in one command

Suppose the rule for a project is:
*no critical vulnerabilities in what
we ship.* On the JavaScript fixture,
which carries exactly one:

```bash
trivy fs --severity CRITICAL --exit-code 1 trivy-lab/fixtures/oldjs
```

Check (transcript
`trivy-lab/transcripts/t04-severity-and-exit-code.txt`):
the report shrinks to the single
finding that matters —

```text
package-lock.json (npm)
Total: 1 (CRITICAL: 1)
│ minimist │ CVE-2021-44906 │ CRITICAL │ fixed │ 0.0.8 │ 1.2.6, 0.2.4 │ minimist: prototype pollution │
exit code: 1
```

— and the command **fails**, exit
code 1, which is the only language a
CI system cannot misread. The other
ten findings have not gone anywhere;
the severity filter says they are
below the line this gate enforces.
A gate set at HIGH,CRITICAL is the
more common choice; CRITICAL alone
here just keeps the arithmetic
visible.

The same command on a project with
nothing at that level — the lab's
`cleanpy` fixture, one current
package — prints a summary counting
0 and **exits 0**. A gate that can
only fail is a wall; this one is a
door, and both directions are in the
transcript.

## Setting aside the unfixable

Chapter 6 met the wall of findings
with no fix: 68 in `debian:9-slim`,
of which 66 can never be patched
inside that image.
`--ignore-unfixed` removes exactly
those from the report:

```bash
trivy image --ignore-unfixed debian:9-slim
# Total: 2
```

Use it with your eyes open. Two
honest uses exist: focusing a
worklist on the actionable, and
gating a build on "no *fixable*
serious flaws" while a base-image
migration is planned and dated. The
dishonest use is quieter numbers.
The findings are still in the
image; the flag changes the report,
not the risk. The lab also ran the
flag against chapter 4's Python
fixture, where it changed **nothing
at all** — all 147 findings there
have fixes (transcript
`trivy-lab/transcripts/t05-ignore-unfixed-python.txt`) —
a useful reminder that the flag
filters on *status*, and on
well-maintained packages the status
is almost always "fixed".

## Accepting a finding, on the record

Sometimes the right answer to a
finding is "we know, and here is
why it stands": the vulnerable code
is unreachable, the fixture is a
fixture, the upgrade breaks a
contract that matters more this
quarter. Trivy records such
decisions in a **.trivyignore** file
in the folder being scanned — one
identifier per line, comments
allowed. The lab accepted the
minimist critical in a copy of the
JavaScript fixture, with its
reasoning written down:

```text
# The minimist finding is accepted for this throwaway fixture:
# it is a sample, not production code. Review date: 2026-10-28.
CVE-2021-44906
```

Check (transcript
`trivy-lab/transcripts/t12-trivyignore.txt`):
the chapter's gate, run in that
folder, reports the target clean and
**exits 0**. The finding is not
fixed; it is *answered*, in writing,
next to the code, where the next
person to be frightened by it can
find the reasoning. Three habits
keep this honest: always write the
reason, always name a review date
(the file supports expiry dates on
entries — use them), and re-check at
review time whether the acceptance
is still true. An ignore file with
no reasons and no dates is not a
record of decisions; it is a rug.

## Wiring it into a build

In a pipeline the pattern is a
single step: run the scan with your
severity line and `--exit-code 1`,
and let the step's failure stop the
line. Two refinements earn their
keep:

- **Download the database on its
  own step** (`--download-db-only`,
  chapter 3). Database trouble then
  fails as infrastructure, not as a
  security finding, and the scan
  step stays fast against the cache.
- **Keep the report as an artifact**
  even when the gate passes — the
  JSON or SARIF forms of chapter 10
  upload neatly, and last month's
  clean report is next month's
  evidence when a new CVE lands.

Hosted CI specifics — which runner,
which marketplace action — vary by
provider and age quickly; the
official documentation carries
maintained examples for the common
ones, and this guide leaves them
there, labelled documented-only.
Everything the gate itself needs —
the flags, the exit codes, the
ignore file — is in this chapter and
was run in the lab.
