# Limits

What Trivy cannot do, and what it
must not be asked to do — the
chapter the rest of the guide has
been promising.

## It finds known problems. Only known problems.

Every finding in every chapter came
out of a database of *published*
flaws. A vulnerability nobody has
disclosed yet — the zero-day, the
quiet bug in the library everyone
trusts — is invisible to Trivy by
construction, as is a flaw in your
own code, which has no public record
to match against. So the sentence a
clean scan licenses is narrow and
must be kept narrow: **no known
problems were found in the parts
that were scanned.** Not "secure",
not "safe", not "audited". The
distance between those sentences is
where breaches live.

## A match is presence, not proof

The scanner matches *versions*
against *records*. It does not know
whether your program ever calls the
vulnerable function, whether the
flaw is reachable from outside, or
whether the package is dead code
riding along in the image. Severity,
likewise, is inherited from the
source that scored the flaw — a
general judgement about the bug, not
a measurement of your deployment,
and sources sometimes disagree
about the same CVE. Treat the
report as a list of things to look
at, ordered sensibly. The looking
is still yours.

The mirror-image limit exists too:
**what is not written down is not
scanned.** Dependencies installed
outside a lock file, binaries copied
into an image by hand, a config file
in a format the checks do not cover
— the report's 0 means "nothing
found in what was read", and the
legend in chapter 4 (`-` versus `0`)
is the honest print of that
boundary. Chapter 8 added a subtler
one: the secret scanner recognises
the shapes it knows, and
deliberately lets the world's most
famous example credentials pass.

## The database is a snapshot with a birthday

Chapter 3's three dates are a
limit, printed on the tool itself.
Findings are as fresh as the
database build — about a day behind
the newest disclosures on a good
day, older whenever a machine has
been offline or skipping updates. A
scan the morning a famous flaw
breaks may be honestly,
dangerously empty. Conversely, a
package does not become safer as
the database ages; the report just
knows less about it. For anything
that matters, check `trivy version`
before quoting a result, and prefer
a fresh database to a fast one.

## Some findings have no fix, and some fixes are not yours

Chapter 6's wall stands here as a
standing condition: end-of-life
systems accumulate **will_not_fix**
and **affected** findings that no
flag can patch — only migration
answers them, and migration is a
project, not a scan. And even where
a fixed version exists, the scanner
cannot judge what the upgrade
breaks. It will cheerfully point at
the version that closes the hole
and drops the feature you depend
on. Updating remains engineering;
Trivy only writes the shopping
list.

## The report is a sensitive document

A full report on a real system —
every unpatched flaw, every open
rule, versions exact — is the
document an attacker would most
like to read about that system.
Handle reports the way chapter 8
says to handle the secrets in them:
keep them where you keep sensitive
files, think before attaching one
to a public issue, and let old
reports age out of shared drives.
The lab's reports describe fictional
fixtures; yours will not be
fictional.

## The legal and ethical edge

Chapter 1's rule — *your machines,
your images, your code, or explicit
permission* — has a legal shadow.
Enumerating the weaknesses of
systems you do not own is, in many
jurisdictions, unauthorised access
territory even when nothing is
exploited, and "I was only scanning"
is not the defence people hope.
Workplace scanning follows the
employer's authorisation, not your
curiosity. Inside the line, the
tool is housekeeping and needs no
apology; outside it, the same
commands are reconnaissance, and
this guide does not teach them.
