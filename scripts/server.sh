# JDK 21
sudo apt-get update
sudo apt-get install unzip zip 
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java 21.0.6-zulu

# Add Docker's official GPG key:
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Docker Installation
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Certbot & Nginx
sudo apt-get install nginx certbot python3-certbot-nginx -y
sudo cp ./nginx-config /etc/nginx/sites-available/api.flooding.kr
sudo systemctl restart nginx.service

# Port Allow
sudo ufw allow 443/tcp
sudo ufw allow 80/tcp
sudo ufw allow 8080/tcp

# SSL Certification
sudo certbot certonly --nginx -d api.flooding.kr

# Installation AWS CLI
# AWS Configure
# ECR LOGIN (SUDO)
sudo aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin 495740757494.dkr.ecr.ap-northeast-2.amazonaws.com

# Docker
sudo docker pull {이미지}
sudo docker run -d -p 8080:8080 --name flooding-server --env-file ./.env {이미지}
```


# nginx-config
```nginx
server {
    listen 443 ssl;
    ssl_certificate /etc/letsencrypt/live/api.flooding.kr/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/api.flooding.kr/privkey.pem; # managed by Certbot

    server_name api.flooding.kr;

    location / {
        include /etc/nginx/proxy_params;
        proxy_pass http://43.203.200.108:8080;
    }

}

server {
    if ($host = api.flooding.kr) {
        return 301 https://$host$request_uri;
    } # managed by Certbot

    listen 80;

    server_name api.flooding.kr;
    
    return 404; # managed by Certbot
}