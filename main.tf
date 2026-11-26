# The network and the web server. Finish the TODOs, then write outputs.tf. See README.md.

# TODO: aws_vpc "main" - 10.0.0.0/16, DNS hostnames on, a Name tag

# TODO: aws_subnet "public" - in the VPC, 10.0.1.0/24, public IPs on launch

# TODO: aws_internet_gateway "igw" - in the VPC

# TODO: aws_route_table "public" (route 0.0.0.0/0 to the gateway) and aws_route_table_association "public"

# TODO: aws_security_group "web" - 80 from anywhere, 22 only from var.my_ip, all outbound

# TODO: aws_instance "web" - var.ami_id, var.instance_type, in the subnet with the security group
