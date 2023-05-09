All infrastructure orchestration and provisioning code is placed under provisioning folder which subfolders for providers. 

At this stage, it accommodates Terraform, Cloudformation, boto and libcloud scripts. 

CloudFormation and boto are more focused on Amazon Web Services cloud, but Terraform along with libCloud are platform agonist and support majority of providers including Open Stack and VMware.