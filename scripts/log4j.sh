#!/bin/bash

# Install Java
sudo apt-get update
sudo apt-get install -y openjdk-11-jdk

# Clone the vulnerable app repository
git clone https://github.com/alexandre-cezar/log4shell-vulnerable-app.git

# Install Maven
sudo apt-get install -y maven

# Build the vulnerable app
cd log4shell-vulnerable-app
./gradlew appRun &

