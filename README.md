# pc-demo-foundations

How to:

Each terraform file creates a specific set of the infrastructure, so you can delete the parts that are not interesting to you. Per example, if you already have a VPC and flow logs configured or if you just don't need RDS, just delete the respective files. (If you delete the VPC, you will need to adjust the VPC reference in the remaining files to use whatever VPC you already has).

There's also two EC2 files (one of them creates the EC2 using Elastic IPs, but this makes impossible to run the file and remote exec providers) and the other one uses Public IPs, which in turn, allows the use of the providers for full automation.

Choose the version that fits your environment better, but if you're using the EIP one, make sure you copy the scripts over to the the demo-vulnerable host some other way in an automated fashion and that the setup.sh script is executed (it takes care of everything else). 

NOTE:Do not run both EC2 files at the same time.

You will also need to set up the SSH key beforehand (creating one using terraform is possible but creates several other concerns, so just create one in AWS and copy the key to this project folder.

There's also a need to fill the variables.tf and main.tf filse with the proper values 

Aftter that, just initialize the terraform using terraform init and run it using terraform apply.

(every line in the code is documented, so if any questions arise, take a look at the code)

Final note: The scripts need some customization based on the VPC configuration and the suspicious IP address
