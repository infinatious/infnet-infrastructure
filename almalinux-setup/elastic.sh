
# Configuration
TARGET_USER=$(logname)
ELASTIC_SERVER="http://inf-10037.phxaz.infinatio.us:8220"
ENROLLMENT_TOKEN=""


# Install Elastic Agent
echo "Installing Elastic Agent..."
wget https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-7.17.26-linux-x86_64.tar.gz 
tar xzf elastic-agent-7.17.26-linux-x86_64.tar.gz 
elastic-agent-7.17.26-linux-x86_64/elastic-agent install --url=$ELASTIC_SERVER --enrollment-token=$ENROLLMENT_TOKEN --insecure 
systemctl enable elastic-agent --now

# Final message
echo "Setup complete for user $TARGET_USER!"
