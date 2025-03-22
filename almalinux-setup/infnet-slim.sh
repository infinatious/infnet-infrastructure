# This version of the script is for existing systems.

# Configuration
TARGET_USER=$(logname)
SSH_PUBLIC_KEY=""
SSH_DIR="/home/$TARGET_USER/.ssh"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"
PS1_CUSTOM='PS1='\''\[\e[38;5;140m\][\[\e[38;5;206m\]\t\[\e[0m\] \[\e[38;5;76m\]\u@\[\e[38;5;36;1m\]\h\[\e[0m\] \[\e[38;5;39m\]\w\[\e[38;5;141m\]]\[\e[0m\] '\'''


# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or with sudo."
    exit 1
fi

# Create .ssh directory if it doesn't exist
if [ ! -d "$SSH_DIR" ]; then
    echo "Creating SSH directory for $TARGET_USER..."
    mkdir -p $SSH_DIR
    chmod 700 $SSH_DIR
    chown $TARGET_USER:$TARGET_USER $SSH_DIR
fi

# Add the public key to authorized_keys
if [[ ! -f "$AUTHORIZED_KEYS" || $(grep -F "$SSH_PUBLIC_KEY" "$AUTHORIZED_KEYS") == "" ]]; then
    echo "Adding SSH public key for $TARGET_USER..."
    echo "$SSH_PUBLIC_KEY" >> $AUTHORIZED_KEYS
    chmod 600 $AUTHORIZED_KEYS
    chown $TARGET_USER:$TARGET_USER $AUTHORIZED_KEYS
else
    echo "SSH public key already exists in $AUTHORIZED_KEYS."
fi

# Enable passwordless sudo
sed -i 's/^%wheel\s\+ALL=(ALL)\s\+ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers


# Add user to the wheel group
if ! groups $TARGET_USER | grep -q "wheel"; then
    echo "Adding $TARGET_USER to the wheel group..."
    usermod -aG wheel $TARGET_USER
else
    echo "$TARGET_USER is already in the wheel group."
fi

# Disable password SSH login
echo "Configuring SSH daemon..."
SSHD_CONFIG="/etc/ssh/sshd_config"
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' $SSHD_CONFIG
sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' $SSHD_CONFIG
sed -i 's/^#PermitRootLogin yes/PermitRootLogin no/' $SSHD_CONFIG
sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' $SSHD_CONFIG

# Reload SSH service
echo "Reloading SSH service..."
systemctl reload sshd

# Set custom PS1 prompt for the target user
BASHRC="/home/$TARGET_USER/.bashrc"
if ! grep -q "Custom PS1 prompt" "$BASHRC"; then
    echo "Setting custom PS1 prompt for $TARGET_USER..."
    echo "# Custom PS1 prompt" >> $BASHRC
    echo "$PS1_CUSTOM" >> $BASHRC
    chown $TARGET_USER:$TARGET_USER $BASHRC
else
    echo "Custom PS1 prompt already set in $BASHRC."
fi


