# SQL Server Alias

On my local development machine, I prefer running 'SQL Server Developer Edition' vs 'SQL Express'. But I have worked on projects where the team is using SQL Express, and the connection string that is provided for local development is '.\SQLEXPRESS', and (frustatingly) no option to change it. 

I setup an Alias for my SQL Server so that connections going to '.\SQLEXPRESS' instead went to my local MSSQLSERVER. 

### Steps
- Install SQL Developer Edition 2019 (v2022 seems to handle alias' differenly and I need to find a better solution)
- Open 'SQL Server Configuration Manager'
- Open 'SQL Server Network Configuration'. Enable TCP/IP. Restart your DB Service.
- Open 'SQL Native Client 11.0 Configuration'
  - Right click 'Aliases', create a new one
  -  Enter '.\SQLEXPRESS' as the Alias Name
  -  Enter 'localhost' as the Server
  -  Select 'tcp' as the Protocol.
  -  Repeat this process for the 'SQL Server Client 11.0 Configuration (32bit)'. This might not be necessary, but I did it anyway.
-  Restart the DB Service.
-  Test by using SSMS to connect to '.\SQLEXPRESS'
