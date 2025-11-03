#!/bin/bash
# Automated deployment script for Skytek SMS Platform
# This script pulls the latest code on the production server and restarts the service

set -e  # Exit on error

# Production server details
SERVER_USER="ubuntu"
SERVER_HOST="3.149.170.249"
SSH_KEY="Keys/sms-platform-key.pem"
APP_DIR="/home/ubuntu/skytek-sms-platform"
SERVICE_NAME="sms-platform"

# Deploy to production
ssh -i "$SSH_KEY" "${SERVER_USER}@${SERVER_HOST}" <<'ENDSSH'
    cd /home/ubuntu/skytek-sms-platform
    git pull
    sudo systemctl restart sms-platform
ENDSSH

exit $?
