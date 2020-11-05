# Auto-deploy Springboot to Jenkins using Docker and Bash

## 1. Install Jenkins
- https://www.server-world.info/en/note?os=CentOS_7&p=jenkins

## 2. Install Docker
```bash
# install a docker
  sudo curl -s https://get.docker.com | sudo sh && sudo systemctl start docker && sudo systemctl enable docker
  sudo groupadd docker
  sudo usermod -aG docker $USER
```
