# Recipes

Small, complete jobs, each built from
commands this guide has already run
or named. The fixtures stand in for
your own projects; everything here
stays inside chapter 1's rule — your
own images, folders and servers.

## Check an image before it deploys

The last question to ask an image
before it goes anywhere is the one
from chapter 6, with chapter 9's
gate attached:

```bash
trivy image --severity HIGH,CRITICAL --exit-code 1 myimage:1.4.2
```

Exit 1 names the image unshippable
until the findings are fixed or
formally accepted. Run it against
the exact tag you deploy — "latest"
is a moving target, and a scan of
some other build proves nothing
about this one.

## Audit a repository you just cloned

Before building or running code a
stranger wrote, read its lists:

```bash
trivy repo <the clone's address or local path>
```

The lab's run over a local clone is
transcript t13: same lock files,
same findings, one command. Follow
with the secret scanner over the
folder (`--scanners secret`) — a
repository that ships its author's
credentials is telling you something
about its housekeeping in general.
None of this makes the code *safe*;
it makes its known problems known,
which is the correct first five
minutes.

## Keep a dated SBOM for everything you run

For each service you actually run,
generate the inventory of chapter 10
and keep it with the deployment
records:

```bash
trivy image --format cyclonedx --output sbom-2026-10-28.json myimage:1.4.2
```

When the next famous flaw is
announced, the answer to "are we in
this?" is a search across a folder
of small JSON files, not a weekend.
Re-judge an old inventory against
today's database any time with
`trivy sbom sbom-2026-10-28.json`.

## Re-scan on a schedule

Findings change while code stands
still — the database learns new
flaws in old packages daily. A
weekly run against your projects and
running images, with the database
update made explicit, keeps the
picture honest:

```bash
trivy fs --download-db-only ~/projects/myapp
trivy fs --severity HIGH,CRITICAL --exit-code 1 ~/projects/myapp
```

Wire the exit code to whatever
notifies you. A scheduled scan that
nobody hears from is chapter 4's
polite report wearing a cron job.

## A credential was found in a repository

Chapter 8's fire drill, in order:

1. **Revoke and reissue** the
   credential at its provider. Assume
   it is public from the moment it
   was committed; copies of a popular
   repository exist you will never
   hear about.
2. **Then** remove it from the files,
   and rewrite or rotate the
   repository history if the secret
   ever left your machine — deleting
   the line in a new commit leaves
   the old commit holding it.
3. Move the value to wherever your
   project keeps secrets properly,
   and let the scanner keep watch:
   the same scan in CI (chapter 9)
   is what stops the sequel.

## Two scanners disagree

It will happen: one tool flags a
package, another clears it. Before
believing either, check the boring
causes — different database dates
(`trivy version` prints its
database's birthday), different
severity sources, or one tool
reading a lock file the other
skipped. Chapter 12's neighbours
genuinely do cover ground
differently; disagreement about a
specific row is usually bookkeeping,
not philosophy.
