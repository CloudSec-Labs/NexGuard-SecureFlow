#!/bin/bash

exec > /var/log/user-data.log 2>&1

set +e
export DEBIAN_FRONTEND=noninteractive

echo "======================================="
echo "DEVSECOPS AUTO SETUP START"
echo "======================================="

# ---------------------------------------
# UPDATE SYSTEM
# ---------------------------------------
apt update -y
apt upgrade -y

# ---------------------------------------
# REQUIRED PACKAGES
# ---------------------------------------
apt install -y \
curl \
wget \
unzip \
gnupg \
ca-certificates \
software-properties-common \
apt-transport-https \
lsb-release \
fontconfig \
openjdk-17-jdk

# ---------------------------------------
# DOCKER INSTALL
# ---------------------------------------
echo "Installing Docker..."

apt install -y docker.io

systemctl enable docker
systemctl start docker

usermod -aG docker ubuntu || true

docker --version

echo "Docker Installed Successfully"

# ---------------------------------------
# JENKINS CONTAINER
# ---------------------------------------
echo "Starting Jenkins..."

docker volume create jenkins_home

docker run -d \
--name jenkins \
--restart unless-stopped \
-p 8080:8080 \
-p 50000:50000 \
-v jenkins_home:/var/jenkins_home \
jenkins/jenkins:lts

echo "Jenkins Container Started"

# ---------------------------------------
# SONARQUBE CONTAINER
# ---------------------------------------
echo "Starting SonarQube..."

docker run -d \
--name sonar \
--restart unless-stopped \
-p 9000:9000 \
sonarqube:lts-community

echo "SonarQube Started"

# ---------------------------------------
# TRIVY
# ---------------------------------------
echo "Installing Trivy..."

curl -fsSL https://aquasecurity.github.io/trivy-repo/deb/public.key | \
gpg --dearmor -o /usr/share/keyrings/trivy.gpg

echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" \
> /etc/apt/sources.list.d/trivy.list

apt update -y
apt install -y trivy

trivy --version

echo "Trivy Installed"

# ---------------------------------------
# AWS CLI v2
# ---------------------------------------
echo "Installing AWS CLI..."

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip

unzip -o awscliv2.zip

./aws/install --update

aws --version

echo "AWS CLI Installed"

# ---------------------------------------
# KUBECTL
# ---------------------------------------
echo "Installing kubectl..."

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

chmod +x kubectl
mv kubectl /usr/local/bin/

kubectl version --client

echo "kubectl Installed"

# ---------------------------------------
# EKSCTL
# ---------------------------------------
echo "Installing eksctl..."

curl -sSL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" \
| tar -xz -C /tmp

mv /tmp/eksctl /usr/local/bin/
chmod +x /usr/local/bin/eksctl

eksctl version

echo "eksctl Installed"

# ---------------------------------------
# HELM
# ---------------------------------------
echo "Installing Helm..."

curl -fsSL -o get_helm.sh \
https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3

chmod 700 get_helm.sh
./get_helm.sh

helm version

echo "Helm Installed"

# ---------------------------------------
# FINAL STATUS
# ---------------------------------------
echo "======================================="
echo "VERIFYING INSTALLATIONS"
echo "======================================="

docker --version
java -version
aws --version
kubectl version --client
eksctl version
helm version
trivy --version

echo "======================================="
echo "DEVSECOPS SETUP COMPLETED"
echo "======================================="
