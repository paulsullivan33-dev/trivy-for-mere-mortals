# The Neighbours

Trivy is not the only scanner on the
street, and pretending otherwise
would make this guide less useful.
What follows is a character sketch
of the tools you will meet alongside
it — what each is *for*, in the same
plain terms. They are characterised
from their documentation and the
lab's general knowledge, not
benchmarked; nobody raced them, and
a race would mostly measure whose
database updated last.

## The other all-rounders

**Grype** (from Anchore) is the
closest neighbour: a free, open
vulnerability scanner for images and
filesystems, fed by its own
curated database, and often paired
with **Syft**, the same project's
SBOM generator. If Trivy's shape
fits your hands, Grype's will too;
shops pick between them on database
coverage in their ecosystem and on
which output their pipeline already
eats.

**OSV-Scanner** (from Google) scans
lock files and images against the
**OSV** database — an open,
distributed vulnerability record
that many ecosystems now publish to
directly. It is especially strong
on the "which of my exact
dependencies does this advisory
mean" question, and light to run.

**Docker Scout** is Docker's own
offering, built into Docker Desktop
and the Hub: image scanning with
fix suggestions and a dashboard,
trading Trivy's local, scriptable
plainness for integration with the
place your images already live.

**Snyk** is the commercial
heavyweight for organisations: a
hosted platform scanning code,
dependencies, containers and
infrastructure, with prioritisation
and remediation workflows a team
can run a programme on. What you
pay for is the programme around the
scanning, not the scanning alone.

## The specialists

**Clair** (from the Quay project)
scans container images and only
that, as a *service*: an API and a
database you run, which other
systems ask about images. It is
infrastructure for registries and
platforms rather than a command for
a person, and inside its niche it
is the elder statesman.

**tfsec and Checkov** are the
config-only ancestors and cousins of
chapter 7. tfsec scanned Terraform
(its checks and its team came to
Aqua, and the modern Trivy rules
descend from that line); Checkov
covers a wide field of
infrastructure-as-code with a large
policy library. If misconfiguration
is your *whole* problem, a
specialist may cut deeper; Trivy's
argument is that it is rarely the
whole problem.

## The ones that prevent instead

**Dependabot** (GitHub's) and
**Renovate** do not scan and report
so much as *act*: they watch your
dependencies and open update pull
requests when new versions —
including security fixes — appear.
They are the natural partner of
everything in this guide. Trivy
tells you the house is on fire in
these six rooms; an update bot is
the plumber who shows up with the
parts. Many projects run both: the
bot keeps versions drifting forward
so the scanner's list stays short
enough to read.

## How to think about the choice

The scanners agree on far more than
they disagree about — they read the
same public record, after all. What
differs is the diet (which targets
and ecosystems), the database (whose
curation, how fresh), the output
(where the results can go), and the
manners (local and scriptable, or
hosted and dashboarded). Trivy's
claim on a mere mortal's machine is
breadth in one binary with nothing
to sign up for — vulnerabilities,
misconfiguration, secrets and
licences under one set of habits.
Nothing in this guide's method
depends on the brand: read reports
by severity and status, gate on
exit codes, record your acceptances,
and distrust any clean result a
little. Those habits transfer to
whichever neighbour you invite in.
