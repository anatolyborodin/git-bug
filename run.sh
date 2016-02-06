#!/bin/sh

set -e

git branch -q -f --no-track test master

OLD_BLOB='88a0f09b9b2e4ccf2faec89ab37d416fba4ee79d' # aa/bb.dat
NEW_BLOB=`echo "This file was to big, and it has been removed." | git hash-object -w --stdin`

git replace -f $OLD_BLOB $NEW_BLOB

git filter-branch -f --prune-empty --tree-filter true -- test

git replace -d $OLD_BLOB

git log -p --stat test -- aa/bb.dat
