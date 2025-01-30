These instructions cover one possible way to deploy this application to a Linux server.

Start by creating a Linux server. I wrote these instructions for an Ubuntu X64 24.04 server. You can run this application on ARM, but you will _probably_ need to adjust the process when installing ASP.NET Core and referencing the dotnet cli.

.NET Linux Install - From Microsoft: https://learn.microsoft.com/en-us/dotnet/core/install/linux-ubuntu-install?pivots=os-linux-ubuntu-2404&tabs=dotnet9

## Install dependencies on the server

Run the following commands:
```
sudo apt update -y
```
```
sudo apt upgrade -y
```
```
sudo add-apt-repository ppa:dotnet/backports
```
```
sudo apt update -y
```
```
sudo apt upgrade -y
```
```
sudo apt install -y aspnetcore-runtime-9.0
```
```
sudo apt install unzip -y
```
```
sudo apt install nginx -y
```
```
sudo apt install ufw -y
```
```
sudo ufw allow 'Nginx Full'
```
```
sudo ufw allow 'OpenSSH'
```
```
sudo ufw --force enable
```
Rebook the server. A reboot is almost never a bad idea.


## Setup Application Directory
Run the following commands:
```
sudo mkdir /var/www/darknote
```
```
sudo chown -R $USER:$USER /var/www/darknote
```

## Setup CI/CD
I recommend forking the darknote repo. In your copy of the repo, setup your own GitHub repo secrets. These secrets will be used to access the server via SSH for the CI/CD process. You will need the following secrets that will be used in the GitHub action:
1. SERVERADDRESS
2. SERVERPORT (The default SSH port is 22. Use 22 unless your server uses another port for SSH)
3. SERVERUSERNAME
4. SERVERPASSWORD

After you have setup these secrets in your GitHub repo, create this file in this directory of the repository:

/.github/workflows/dotnet-build-deploy.yml

Add this content to the file:
```
name: CI/CD

on:
  push:
    branches:
      - master
    paths-ignore:
      - '**/README.md'

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v2

      - name: Setup .NET
        uses: actions/setup-dotnet@v1
        with:
          dotnet-version: '9.0.x'

      - name: Restore dependencies
        run: dotnet restore

      - name: Build, publish, and deploy
        run: |
          sudo apt-get update && sudo apt-get upgrade -y
          sudo apt-get install -y sshpass openssh-client
          dotnet publish Darknote.API -c Release 
          sshpass -p '${{ secrets.SERVERPASSWORD }}' scp -o StrictHostKeyChecking=no -P ${{ secrets.SERVERPORT }} -r ${{ github.workspace }}/Darknote.API/bin/Release/net9.0/publish/* ${{ secrets.SERVERUSERNAME }}@${{ secrets.SERVERADDRESS }}:/var/www/darknote      
          sshpass -p '${{ secrets.SERVERPASSWORD }}' ssh -o StrictHostKeyChecking=no -p ${{ secrets.SERVERPORT }} ${{ secrets.SERVERUSERNAME }}@${{ secrets.SERVERADDRESS }} "sudo systemctl restart kestrel-darknote.service"
          sshpass -p '${{ secrets.SERVERPASSWORD }}' ssh -o StrictHostKeyChecking=no -p ${{ secrets.SERVERPORT }} ${{ secrets.SERVERUSERNAME }}@${{ secrets.SERVERADDRESS }} "sudo systemctl restart nginx"
```

This file uses a Username/Password. If you are using a Private/Public Key-Pair, adjust 'Build, publish, and deploy' section to use a secret 'SECRETKEY' (which you need to create) to build a temporary file that contains your Private Key and then uses that key instead of a password:
```
- name: Build, publish, and deploy
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.SERVERKEY }}" > ~/.ssh/id_rsa
          chmod 600 ~/.ssh/id_rsa
          sudo apt-get update && sudo apt-get upgrade -y
          sudo apt-get install -y sshpass openssh-client
          dotnet publish Darknote.API -c Release 
          scp -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa -P ${{ secrets.SERVERPORT }} -r ${{ github.workspace }}/Darknote.API/bin/Release/net9.0/publish/* ${{ secrets.SERVERUSERNAME }}@${{ secrets.SERVERADDRESS }}:/var/www/darknote      
          ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa -p ${{ secrets.SERVERPORT }} ${{ secrets.SERVERUSERNAME }}@${{ secrets.SERVERADDRESS }} "sudo systemctl restart kestrel-darknote.service"
          ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa -p ${{ secrets.SERVERPORT }} ${{ secrets.SERVERUSERNAME }}@${{ secrets.SERVERADDRESS }} "sudo systemctl restart nginx"
```

The Action should run, build and deploy the code. The restart Kestrel service will fail because we haven't created it yet.


## Create the application kestrel service
Create this file, in this location on the server:
```
sudo nano /etc/systemd/system/kestrel-darknote.service
```

Add this content to the file:

```
[Unit]
Description=darknote Production App

[Service]
WorkingDirectory=/var/www/darknote
ExecStart=/usr/lib/dotnet/dotnet /var/www/darknote/Darknote.API.dll
Restart=always
# Restart service after 10 seconds if the dotnet service crashes:
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=darknote
User=azureuser
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=ASPNETCORE_URLS=http://localhost:8080

[Install]
WantedBy=multi-user.target
```
Note: "User=azureuser", system is the name of the user I created for this deployment process. Adjust this based on your own configuration/preference.


## Enable the new kestrel service
This will start your application
```
sudo systemctl enable kestrel-darknote.service
```
```
sudo systemctl restart kestrel-darknote.service
```
```
sudo systemctl status kestrel-darknote.service
```


## Create Nginx configuration for new app
Create this file, in this location on the server:
This is the bare-bones Nginx configuration. LetsEncrypt will adjust the file when it sets up the SSL cert.
```
sudo nano /etc/nginx/sites-available/darknote
```

Add the following contents:
```
upstream darknote_server {
    server localhost:5000;
}
server {
    server_name demo.darknote.org;
    location / {
        proxy_pass         http://darknote_server;
        proxy_redirect     off;
        proxy_set_header   Host $host;
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
        proxy_set_header   X-Forwarded-Host $server_name;
    }
}
```

## Enable the new Nginx configuration
Run the following commands:
```
sudo ln -s /etc/nginx/sites-available/darknote /etc/nginx/sites-enabled/
```
```
sudo nginx -t
```
```
sudo systemctl restart nginx
```

## Setup your DNS
Create an 'A Record' where 'Host' equals 'demo' and the 'Value' equals the IP address of the Server. Change 'demo' to @ or some other subdomain.


## Setup Lets Encrypt for SSL Cert
This will adjust the nginx config

Run the following commands:

```
sudo apt install -y certbot python3-certbot-nginx
```
```
sudo certbot --nginx -d demo.darknote.org
```
Choose 'Redirect'. This will update the nginx configuration
```
sudo systemctl status certbot.timer
```
```
sudo certbot renew --dry-run
```

Done. Go to 'demo.darknote.org' to see the active site. Adjust this final URL for your domain.




If you have problems, these two command might be helpful:
```
sudo systemctl daemon-reload
```
```
sudo journalctl -u kestrel-darknote.service
```

