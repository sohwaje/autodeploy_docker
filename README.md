# Auto-deploy Springboot to Jenkins using Docker and Bash
*notice*
- This repository contains sample sources.
- This document uses springboot sources for samples.

![Alt text](/readme-img/build-image.JPG)

## 1. Install Jenkins
- https://www.server-world.info/en/note?os=CentOS_7&p=jenkins

## 2. Install Docker
```bash
  sudo curl -s https://get.docker.com | sudo sh && sudo systemctl start docker && sudo systemctl enable docker
  sudo groupadd docker
  sudo usermod -aG docker $USER
  sudo systemctl start docker
```

## 3. Jenkins Settings(brief explanation)
### 3-1 Source Code Management
![Alt text](/readme-img/manage-source-code.jpg)

### 3-2 Build trigger
![Alt text](/readme-img/build-trigger.jpg)

### 3-3 Environment Build
![Alt text](/readme-img/env-build.JPG)
*important*
```bash
  cd ~/apps
  wget https://raw.githubusercontent.com/sohwaje/autodeploy_docker/main/Dockerfile
  bash <(curl -s https://raw.githubusercontent.com/sohwaje/autodeploy_docker/main/auto_deploy.sh) &
```

### 3-4 Build
![Alt text](readme-img/build-go.JPG)
