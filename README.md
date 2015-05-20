# 2015PuppetCampMaterials
Scripts and whatnot from my 2015 Puppet Camp Chicago presentation

## init.sh

This script takes a fresh clone of a fork of our Puppet repo and gets it ready
to be worked on.  It might be somewhat Backstop-specific, but there might be
something of value in there for you.

## pre-commit.sh

This is a driver to run a directory full of pre-commit checks, collect the
results, then fail if any of them failed.

## precommit/

A bunch of pre-commit checks we use.

Warning!  This currently stashes changes that aren't staged so it can work on
the repository as it will exist in the commit.  There are a couple of edge
cases where this won't work well.  The one to watch out for looks like this:

* Change foo
* `git add foo`
* Change foo again
* `git commit`

That will claim there's a merge conflict when it `stash pop`s.  We've gone back
and forth on what the right answer would be for this and haven't come to a
consensus yet.  Buyer beware.
