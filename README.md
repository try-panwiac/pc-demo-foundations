# pc-demo-foundations

How to:

Each terraform file creates a specific set of the infrastructure, so you can delete the parts that are not interesting to you. Per example, if you already have a VPC and flow logs configured or if you just don't need RDS, just delete the respective files. (If you delete the VPC, you will need to adjust the VPC reference in the remaining files to use whatever VPC you already has).

You will also need to set up the SSH key beforehand (creating one using terraform is possible but creates several other concerns, so just create one in AWS and copy the key to this prokect folder.

There's also a need to fill the variables.tf and main.tf filse with the proper values 

Aftter that, just initialize the terraform using terraform init and run it using terraform apply.

(every line in the code is documented, so if any doubts arise, revert to the code)
