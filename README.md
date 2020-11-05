# Auto-deploy Springboot to Jenkins using Docker and Bash

![Alt text](/readme-img/build-image.JPS)

## 1. Install Jenkins
- https://www.server-world.info/en/note?os=CentOS_7&p=jenkins

## 2. Install Docker
```bash
  sudo curl -s https://get.docker.com | sudo sh && sudo systemctl start docker && sudo systemctl enable docker
  sudo groupadd docker
  sudo usermod -aG docker $USER
  sudo systemctl start docker
```

## 3. Jenkins Settings
