# Auto-deploy Springboot to Jenkins using Docker and Bash
**notice**
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
**important!**
+ Download **Dockerfile**
+ run **auto_deploy.sh** using "curl"
```bash
  cd ~/apps
  wget https://raw.githubusercontent.com/sohwaje/autodeploy_docker/main/Dockerfile
  bash <(curl -s https://raw.githubusercontent.com/sohwaje/autodeploy_docker/main/auto_deploy.sh) &
```

### 3-4 Build and Save
![Alt text](readme-img/build-go.JPG)

### 3-5 Build Now
![Alt text](readme-img/Build-now.JPG)

## 4. After deploy
+ The **logs** directory and **heapdump** directory are created in **apps** dir  
![Alt text](readme-img/vm-deploy.JPG)

### 4-1 Docker container
![Alt text](readme-img/container.JPG)
***

## 5. additional explanation
- You can edit docker **CONTAINER_PORT** and **HOST_PORT** in auto_deploy.sh
  > HOST_PORT="19999"  
  > CONTAINER_PORT="19999"

- Also you can edit **APP_HOME, VERSION, SPRING_PROFILE**
