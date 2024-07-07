#!/bin/bash
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y 
systemctl start docker
systemctl status docker
systemctl enable docker
usermod -aG docker ec2-user
#after adding user to the docker group,user needs to logout of the server and login back to run the docker commands
#dont run docker commands as a root user