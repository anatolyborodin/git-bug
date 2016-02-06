## Usage

Clone the repository and run `./run.sh`.

## Explanation

This repository is a test case to illustrate a bug related to `git replace`,
`git filter-branch`, and [git index race condition avoidance
mechanism](https://github.com/git/git/blob/master/Documentation/technical/racy-git.txt).

The idea is to replace a huge binary file with a small blob in a repository
containing many files. The original file `aa/bb.dat` is changed (added) only in
the very first commit:


```
# git log master -p --stat -- aa/bb.dat

commit a119016e951d320c08017fe5a4f298f46fcba555
Author: Anatoly Borodin <anatoly.borodin@gmail.com>
Date:   2 hours ago

    Add 2 huge binary files
---
 aa/bb.dat | Bin 0 -> 41943040 bytes
 1 file changed, 0 insertions(+), 0 deletions(-)

diff --git a/aa/bb.dat b/aa/bb.dat
new file mode 100644
index 0000000..88a0f09
Binary files /dev/null and b/aa/bb.dat differ
```

After `git replace` and `git filter-branch` the file `aa/bb.dat` should be
replaced with a short text in all commits. But due to the bug, some original
blobs in some commits could stay untouched:


```
# ./run.sh

Rewrite 5805be0ecc4521dc30d111cb93105b3400b52c2b (5/5) (10 seconds passed, remaining 0 predicted)
Ref 'refs/heads/test' was rewritten
Deleted replace ref '88a0f09b9b2e4ccf2faec89ab37d416fba4ee79d'
commit 9a3507b4a7c9561f7e92ef4396d80cf2ccf94e7e
Author: Anatoly Borodin <anatoly.borodin@gmail.com>
Date:   77 minutes ago

    Add 8000 small files
---
 aa/bb.dat | Bin 47 -> 41943040 bytes
 1 file changed, 0 insertions(+), 0 deletions(-)

diff --git a/aa/bb.dat b/aa/bb.dat
index 16e0939..88a0f09 100644
Binary files a/aa/bb.dat and b/aa/bb.dat differ

commit 95ef828e3a007705162e275f689a9f9bb2f992ae
Author: Anatoly Borodin <anatoly.borodin@gmail.com>
Date:   2 hours ago

    Add 2 huge binary files
---
 aa/bb.dat | 1 +
 1 file changed, 1 insertion(+)

diff --git a/aa/bb.dat b/aa/bb.dat
new file mode 100644
index 0000000..16e0939
--- /dev/null
+++ b/aa/bb.dat
@@ -0,0 +1 @@
+This file was to big, and it has been removed.
```

As we can see, the rewritten commit `5805be0` -> `9a3507b` still contains the
original blob.

PS Because the bug depend on timestamps, `./run.sh` can behave in a
nondeterministic way: it's not always the `Add 8000 small files` commit with
the huge blob after the `git filter-branch` run, and the script can even run
correct sometimes. But most of the time I could reproduce the bug in the 2.7.0
version on an Ubuntu workstation and on a FreeBSD laptop.
