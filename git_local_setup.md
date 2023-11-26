When installing the Git client, I like to do it with WinGet. I install the client, then I install the GitHub CLI. Using the GitHub CLI I login.

```
winget install --id Git.Git -e --source winget
```
```
winget install --id GitHub.cli
```
```
gh auth login
```
