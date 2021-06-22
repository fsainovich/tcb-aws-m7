tcb-aws-m7

BootCamp AWS – Module 7 - Final project

Deploy Adobe Magento Ecomerce with Terraform and Ansible

Requeriments and Instructions:

- Needs a valid registered domain;
- Domain zone registered in Route53;
- Needs a valid TLS certificate (crt and key);
- Set AWS parameters.tf (access_key, secret_key and region) and tfvar.tf (AZ1, PRIVATE_KEY_FILE_NAME, KEY_PUB, FQDN and R53_ZONE) values;
- Set Magento parameters - ansible-magento2/group_vars/all.yml (magento_domain, server_hostname, repo_api_key and repo_secret_key). The repo_api_key and repo_secret_key is register for free in Adobe Magento website;
- Customize other values in ansible-magento2/group_vars/all.ym, like names and passowrds as need;
- Copy your TLS files to ansible-magento2/roles/httpd/templates (with names: server.crt and server.key);
- Run commands in a linux host (needs terraform and zip package);
- Terraform init -> validate -> plan -> apply

Creates:
- Create VPC and Subnet;
- Internet Gateway and Routing Table;
- Create routing table for VPC;
- Assign Public_Subnet to routing table;
- Security Group;
- Create elastic IP;
- Create Route53 Record;
- EC2 Instance;
- Elastic IP association
