#!/bin/bash

# Sets the URL to connect to
url="https://{suspicious_ip}.com"

# Install curl
sudo apt-get update
sudo apt-get install -y curl

# Makes the cURL request
curl -s -o /dev/null $url