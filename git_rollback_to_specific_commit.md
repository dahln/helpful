# Git Rollback to Specific Commit

I recently had the need to rollback a commit in git to a specific version. Here are the commands I used.

A note of caution, this changes your commit history - use these command judiciously.

(this was in the master branch)

<pre>
<code>
git reset --hard [commit-id-going-back-to]
git push -f
</code>
</pre>
