#!/bin/bash

#!/bin/bash

# Install Java
sudo apt-get update
sudo apt-get install -y openjdk-11-jdk

# Clone the vulnerable app repository
git clone https://github.com/tothi/log4shell-vulnerable-app.git

# Install Maven
sudo apt-get install -y maven

# Build the vulnerable app
cd log4shell-vulnerable-app
mvn clean package

# Run the app on port 8080
nohup java -jar target/log4shell-vulnerable-app-0.0.1-SNAPSHOT.jar --server.port=8080 &

