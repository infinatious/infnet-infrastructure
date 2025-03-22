
# Configuration
TARGET_USER=$(logname) # Gets the user who initiated the script, not root

  echo "Installing Docker..."
  sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo 
  sudo dnf update -y 
  sudo dnf install -y docker-ce docker-ce-cli containerd.io -y 
  sudo systemctl enable docker 
  sudo systemctl start docker 
  sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose 
  sudo chmod +x /usr/local/bin/docker-compose 
  sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose 
  sudo usermod -aG docker $USER


echo "Docker install complete!"

