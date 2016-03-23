sh-git-prompt
=============

My personnal git-prompt, in pure shellscript.

Currently tested with Bash on Linux and iTerm2 on macOS

To use it, simply `source prompt.sh` in your `.bashrc` or `.bash_profile`.

Show:
- ↑ - needed push
- ↓ - needed pull
- ✔ - nothing to commit
- ● - added files
- ✚ - edited files
- ✖ - deleted files
- ? - no added files
- ≡ - stash
- ⊗ - count merge conflict

Looks like this:
```bash
    [master✔|+2 ?1] user@localhost:~/scripts
    $
```
