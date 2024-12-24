By default, remote signed powershell scripts cannot be ran locally.

Use these commands to adjust the execution policy:

Run powershell terminal as an administrator

```
Get-ExecutionPolicy
```
```
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
```
