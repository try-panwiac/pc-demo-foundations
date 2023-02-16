#!/bin/bash

# Sets the URL to connect to
url="https://{suspicious_ip}.com"

# Makes the cURL request
curl -s -o /dev/null $url