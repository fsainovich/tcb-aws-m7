# Create a VPC
resource "aws_vpc" "VPC_MAGENTO" {
  cidr_block = "10.1.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "VPC_MAGENTO"
  }
}

# Create internet gateway for public subnet
resource "aws_internet_gateway" "IG" {
  vpc_id = aws_vpc.VPC_MAGENTO.id

  tags = {
    Name = "Internet_Gateway"
  }
}

#Create elastic IP
resource "aws_eip" "EXTERNAL_IP" {
  vpc         = true  
  depends_on  = [aws_internet_gateway.IG]
}

#Create Route53 Record
resource "aws_route53_record" "store" {
  zone_id = var.R53_ZONE
  name    = var.FQDN
  type    = "A"
  ttl     = "60"
  records = [aws_eip.EXTERNAL_IP.public_ip]
  depends_on = [aws_internet_gateway.IG]
}

#Create public subnet 
resource "aws_subnet" "PUBLIC_SUBNET" {
  vpc_id                  = aws_vpc.VPC_MAGENTO.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = var.AZ1
  map_public_ip_on_launch = true  

  depends_on = [aws_internet_gateway.IG]

  tags = {
    Name = "Public_Subnet"
  }
}

#Create routing table for VPC
resource "aws_route_table" "ROUTE_TABLE" {
  vpc_id = aws_vpc.VPC_MAGENTO.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IG.id
  }

  tags = {
    Name = "Routing_Table"
  }
}

#Assign Public_Subnet to routing table
resource "aws_route_table_association" "RT_PUBLIC" {
  subnet_id      = aws_subnet.PUBLIC_SUBNET.id
  route_table_id = aws_route_table.ROUTE_TABLE.id
}

#Create Security Group
resource "aws_security_group" "allow_ssh_http_https" {
  name        = "permitir_acesso_externo"
  description = "Allow SSH, HTTP e HTTPS"
  vpc_id      = aws_vpc.VPC_MAGENTO.id

  ingress {
    description = "SSH to EC2"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP to EC2"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS to EC2"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow public access"
  }
}

#Create EC2 instance Ecomerce
resource "aws_instance" "ecommerce1" {
  ami           = "ami-032930428bf1abbff"
  instance_type = "t3a.medium"
  key_name = var.KEY_PUB
  subnet_id = aws_subnet.PUBLIC_SUBNET.id
  vpc_security_group_ids = [aws_security_group.allow_ssh_http_https.id]  
  private_ip = "10.1.1.10"

  provisioner "local-exec" {
    command = "zip -r ansible-magento2.zip ansible-magento2"
  }

  provisioner "file" {
    source = "ansible-magento2.zip"
    destination = "/tmp/ansible-magento2.zip"
  }  

  provisioner "remote-exec" {
    inline = [
      "cd /tmp/ && sudo unzip ansible-magento2.zip && ls -l /tmp",       
      "sudo yum-config-manager --enable epel", 
      "sudo yum install ansible -y",   
      "cd /tmp/ansible-magento2/ && sudo ansible-playbook -i hosts.yml ansible-magento2.yml -vvv --become"      
    ]
    
  }
  connection {
    host = self.public_ip
    type = "ssh"
    user = "ec2-user"
    private_key = file(var.PRIVATE_KEY_FILE_NAME)
  }

  timeouts {
    create = "15m"    
  }  

  depends_on = [aws_eip.EXTERNAL_IP]

  tags = {
    Name = "ecommerce1"
    Environment = "Test"
  }
}

# Elastic IP association
resource "aws_eip_association" "EIP_ASSOC" {
  instance_id   = aws_instance.ecommerce1.id
  allocation_id = aws_eip.EXTERNAL_IP.id
}