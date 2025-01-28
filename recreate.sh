#!/bin/bash

# Define variables
SCRIPT_PATH="/usr/local/bin/maps-updater.sh"
SERVICE_PATH="/etc/systemd/system/maps-updater.service"
USERNAME=$(whoami)
GROUP=$(id -gn)

# Create the script file
echo "Creating the script file..."
cat <<'EOF' | sudo tee $SCRIPT_PATH > /dev/null
#!/bin/sh

while true; do
	echo "Recreating planetiler...";
	docker compose -f /opt/app/compose.yml up -d --build --force-recreate --remove-orphans --pull=always planetiler
	echo "Done! Planetiler recreated.";
	sleep 21600;  # 6 hours
done;
EOF

# Make the script executable
sudo chmod +x $SCRIPT_PATH
echo "Script created and made executable at $SCRIPT_PATH."

# Create the systemd service file
echo "Creating the systemd service file..."
cat <<EOF | sudo tee $SERVICE_PATH > /dev/null
[Unit]
Description=Maps Updater Daemon
After=docker.service
Requires=docker.service

[Service]
ExecStart=$SCRIPT_PATH
Restart=always
RestartSec=10
User=$USERNAME
Group=$GROUP
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable, and start the service
echo "Setting up the systemd service..."
sudo systemctl daemon-reload
sudo systemctl stop maps-updater.service
sudo systemctl disable maps-updater.service
sudo systemctl daemon-reload
sudo systemctl enable maps-updater.service
sudo systemctl start maps-updater.service

# Verify the service status
echo "Verifying the service status..."
sudo systemctl status maps-updater.service

echo "Setup complete! The Maps Updater Daemon is now running."