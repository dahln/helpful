By default, remote signed powershell scripts cannot be ran locally.

Use these commands to adjust the execution policy:

Run powershell terminal as an administrator

```
Get-ExecutionPolicy
```

```
Set-ExecutionPolicy RemoteSigned
```
OR
```
Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope CurrentUser
```