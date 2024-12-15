When installing the Git client, I like to do it with WinGet. I install the client, then I install the GitHub CLI. Using the GitHub CLI I login.

```
winget install --id Git.Git -e --source winget
```
```
winget install --id GitHub.cli
```
Restart the terminal
```
gh auth login
```
```
git config --global user.name "John Doe"
```
```
git config --global user.email johndoe@example.com
```
```
winget install Microsoft.DotNet.SDK.9
```
