#! /bin/bash

# copy service file to systemd service directory
sudo cp ./filehost.service /etc/systemd/system

# reload the daemon
sudo systemctl daemon-reload

# enable starting when the computer boots
sudo systemctl enable filehost

# start the service immediately
sudo systemctl start filehost