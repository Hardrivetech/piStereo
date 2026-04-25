#!/bin/bash
set -e
sudo mkdir -p /opt/pi_headunit
sudo cp -r . /opt/pi_headunit
sudo mkdir -p /etc/pi_headunit
sudo cp config/config.ini /etc/pi_headunit/config.ini
sudo cp systemd/pi_headunit.service /etc/systemd/system/pi_headunit.service
sudo pip3 install -r /opt/pi_headunit/requirements.txt
sudo systemctl daemon-reload
sudo systemctl enable --now pi_headunit.service

echo "Installed to /opt/pi_headunit and started service pi_headunit"