Use this command to start up MSSQL docker conatiner:

```
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=YourStrong@Passw0rd" -p 1433:1433 --name sql1 --hostname sql1 --restart always -d mcr.microsoft.com/mssql/server:2022-latest
```

Default username is:
```
SA
```

Default password is:
```
YourStrong@Passw0rd
```

Change the password to something strong.
