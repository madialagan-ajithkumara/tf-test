# AWS VPC and a web server with Terraform (AkOps Labs build project)

Write the network every AWS project starts with, as code: a **VPC**, a **public subnet**, an **internet gateway**
and a **route table**, a **security group** and an **EC2 instance**. You don't need an AWS account: the check runs
`terraform validate` and `terraform plan` with fake credentials. (With your own account, `terraform apply` builds it for real.)

**Level:** Intermediate · **Time:** about 60 minutes · **Tools:** Terraform, AWS

## What to build

In `main.tf`:

| Resource | What it needs |
|---|---|
| `aws_vpc` | `cidr_block = "10.0.0.0/16"`, `enable_dns_hostnames = true`, a `Name` tag |
| `aws_subnet` | in the VPC, `10.0.1.0/24`, `map_public_ip_on_launch = true` |
| `aws_internet_gateway` | in the VPC |
| `aws_route_table` + `aws_route_table_association` | a route `0.0.0.0/0` → the internet gateway, attached to the subnet |
| `aws_security_group` | port **80 from anywhere**, port **22 only from `var.my_ip`**, all outbound |
| `aws_instance` | `ami = var.ami_id`, `instance_type = var.instance_type`, in the subnet with the security group |

In `outputs.tf`: `vpc_id` and `public_ip`.

## Check it

```bash
terraform init
terraform fmt
terraform validate
terraform plan
bash tests/check.sh
```

Push to `main`. The **AkOps check** workflow validates and plans your code on GitHub.
