# Scanning for Misconfigurations

Vulnerabilities are flaws in other
people's code. **Misconfigurations**
are flaws in your instructions: the
bucket left public, the container
running as root, the password port
open to the world. Nothing is
"hacked" in such a setup — the
system does exactly what the file
says, and the file says the wrong
thing. Trivy's **config** scanner
checks infrastructure files against
a bundle of rules — the **checks
bundle** from chapter 2 — and
reports every rule a file breaks,
with the offending lines quoted.

The lab's target is
`trivy-lab/fixtures/badconfig`: three
small files, each written to be
wrong on purpose. A Dockerfile that
installs SSH and runs as root. A
Terraform file declaring an S3
bucket and a security group. A
Kubernetes deployment with every
safety switched off.

## The scan

```bash
trivy config trivy-lab/fixtures/badconfig
```

The first run downloads the checks
bundle (about 165 KB; the lab named
its registry explicitly, as in
chapter 3, and the transcript shows
the flag). Then each file is marked
against every rule that applies to
its kind. Check the score lines from
transcript
`trivy-lab/transcripts/t08-config-scan.txt`:

```text
Dockerfile (dockerfile)
Tests: 27 (SUCCESSES: 22, FAILURES: 5)

deployment.yaml (kubernetes)
Tests: 95 (SUCCESSES: 74, FAILURES: 21)

main.tf (terraform)
Tests: 14 (SUCCESSES: 0, FAILURES: 14)
```

136 checks in all; 40 failures. Note
the differences between the files.
The Dockerfile passes most of its
rules — a bad Dockerfile is still a
small target. The Kubernetes
manifest fails 21 of 95: the
Kubernetes rule set is large because
the platform's safety surface is
large. And the Terraform file fails
**everything** — fourteen checks,
fourteen failures. A file that opens
a bucket to the public tends to
break the encryption, logging and
versioning rules standing nearby;
misconfigurations travel in packs.

## Reading a failure

Failures arrive with an identifier,
a severity, a plain-language account
of the rule, and the lines at fault.
Two from the Dockerfile:

```text
DS002 (HIGH): Specify at least 1 USER command in Dockerfile with non-root user as argument
Running containers with 'root' user can lead to a container escape situation. It is a best practice to run containers as non-root users, which can be done by adding a 'USER' statement to the Dockerfile.
See https://avd.aquasec.com/misconfig/ds002

DS004 (MEDIUM): Port 22 should not be exposed in Dockerfile
Exposing port 22 might allow users to SSH into the container.
 Dockerfile:5
   5 [ EXPOSE 22
```

The rule families have their own
prefixes: **DS** for Dockerfile
checks, **KSV** for Kubernetes
security checks, **AVD-AWS** (and
its sibling cloud prefixes) for
Terraform and cloud templates. Each
identifier has a page on Aqua's
advisory site with the reasoning,
the risk, and the fix — the same
AVD library chapter 5 met for
vulnerabilities.

The Kubernetes failures name the
missing safety property rather than
the dangerous line alone: `KSV001`
complains that the container does
not set `allowPrivilegeEscalation`
to false; another asks it to drop
**ALL** capabilities and add back
only what it needs. That is the
shape of most config rules — not
"this is an attack" but "this safety
was never switched on".

## The Terraform file, condemned in full

The fourteen failures in `main.tf`
include the three the file was
written to commit:

- **AVD-AWS-0092 (HIGH)** — "Bucket
  has a public ACL: `public-read`":
  the bucket's access list names the
  public as a reader.
- **AVD-AWS-0107 (HIGH)** — "Security
  group rule allows unrestricted
  ingress from any IP address": SSH
  from `0.0.0.0/0`, the whole
  internet.
- **AVD-AWS-0088 (HIGH)** — "Bucket
  does not have encryption enabled."

And then the neighbours nobody
planted: no logging (AVD-AWS-0089),
no versioning (AVD-AWS-0090), the
instance not requiring a token for
its metadata service (AVD-AWS-0028),
its root disk unencrypted
(AVD-AWS-0131). This is the config
scanner's real value in one exhibit:
you run it for the mistake you
suspect, and it hands back the four
you did not.

## A note on severity here

Config severities are judgements by
the rule's author about a class of
mistake, not measurements of your
setup. An open SSH port on a lab
machine that exists for one
afternoon and a public bucket
holding nothing are both HIGH or
worse in the abstract. The findings
tell you where to look; the looking
— *what is actually in this bucket,
who can actually reach this port* —
remains human work, and chapter 13
says so again. What a config scan
removes is the excuse of not having
looked at all.
