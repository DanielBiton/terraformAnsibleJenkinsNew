
resource "aws_vpc" "some_custom_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Some Custom VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.some_custom_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "Some Public Subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.some_custom_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "Some Private Subnet"
  }
}

resource "aws_internet_gateway" "some_ig" {
  vpc_id = aws_vpc.some_custom_vpc.id

  tags = {
    Name = "Some Internet Gateway"
  }
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.some_custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.some_ig.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.some_ig.id
  }

  tags = {
    Name = "Public Route Table"
  }
}


resource "aws_route_table_association" "public_1_rt_a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# resource "tls_private_key" "pk" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "aws_key_pair" "deployer" {
#   key_name   = "deployer-key"
#   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC5bvc+RD6tyWQ1E95s0B3RNvI/l8iTLSQAeZxDFP4hRwZbPhAZSFzAKMLNKzsvsZwJ/6x8avOIN+kyelUaYWCZdohI96T2bzmLmu/KyR7N6hZrzPdwHjtMm77QPTUyDJRJnQVOBiYwEZaPFXAyId+vzV3Mb/tD2oHPHnGpH5qMNRjEk3qGASnlQu5jYoOhmBTqgxarJMIy8KCXLX8qPemwORf6HBRLeNe6LbzIGwsaujBk65JJPguKk+MHT495cbILiVztRMRfmjG6mygBO0D5DTSC/xxJTBICbKEmyd4E68ZkPYPVwS4Sxb+WRMzEO/iPtS9xadagKXLR3Z8ZeoIPgG/Uqwt4UJt0BAOnyWUrbY1ByCqPST/NqlhE+MJAZcR3L7RXe24GpZQs2HvgPd6I1zkc02bFQeIDF5QBtktV01ADVQ5Hyxj8GbvrBm0NKlryjtpCbaIWLuDFvT2PyzfP1q+th0NW62iCNtN4p3rdbCqJV0ppYq+bSVko07P7nxaAYtxvWSIZgEtOz0ypZ8WFBhDjCiHsHhZVq8kSJa6L8PIpp16wrpHHGSHXbuZaZiLnFWIAadgBB+i6y2GS4R5/QUnMmz3Zy0nm+8Yah1XVlOwxz2j51p8pPHQWgLPeSIP45/gU6O2EcT6G5gAB2yJdGy5gdtxhRIkLdymZeCbu+Q== daniel.btn77@gmail.com"
#   provisioner "local-exec" { # Create a "myKey.pem" to your computer!!
#     command = "echo '${tls_private_key.pk.private_key_pem}' > ./deployer-key.pem"
#   }
# }

resource "aws_scheduler_schedule" "startInstance" {
  name = "my-schedule-start"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "cron(0 7 * * ? *)"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:startInstances"
    role_arn = aws_iam_role.test_role.arn
    input = jsonencode({
      InstanceIds = [
        aws_instance.instance.id
      ]
    })
  }
}
resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.ec2_status_topic.arn
  protocol  = "email"
  endpoint  = "daniel.btn77@gmail.com"
}

resource "aws_scheduler_schedule" "stopInstance" {
  name = "my-schedule-stop"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "cron(0 19 * * ? *)"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:stopInstances"
    role_arn = aws_iam_role.test_role.arn
    input = jsonencode({
      InstanceIds = [
        aws_instance.instance.id
      ]
    })
  }
}
resource "aws_cloudwatch_event_rule" "ec2_status_change_rule" {
  name          = "EC2_Status_Change_Rule"
  description   = "Trigger SNS notification on EC2 status change"
  event_pattern = <<PATTERN
{
  "source": [
    "aws.ec2"
  ],
  "detail-type": [
    "EC2 Instance State-change Notification"
  ],
  "detail": {
    "instance-id": ["${aws_instance.instance.id}"]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "ec2_status_change_target" {
  rule      = aws_cloudwatch_event_rule.ec2_status_change_rule.name
  target_id = "EC2StatusChangeSNS"
  arn       = aws_sns_topic.ec2_status_topic.arn
}

resource "aws_iam_role" "test_role" {
  name = "test_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_role_policy" "StartStopEc2Instances" {
  name = "StartStopPolicyInstances"
  role = aws_iam_role.test_role.name
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "StartStopEc2",
        "Effect" : "Allow",
        "Action" : [
          "ec2:StopInstance",
          "ec2:StartInstance"
        ],
        "Resource" : "*"
      }
    ]
  })
}
resource "aws_sns_topic" "ec2_status_topic" {
  name = "EC2_Status_Topic"
}

#keypair + instance :

resource "tls_private_key" "demo_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.demo_key.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename        = "${local.key_name}.pem"
  content         = tls_private_key.demo_key.private_key_pem
  file_permission = "0400"
}

resource "aws_instance" "instance" {
  ami                         = "ami-0fb2f0b847d44d4f0"
  subnet_id                   = aws_subnet.public_subnet.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = local.key_name
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  user_data_base64             = filebase64("${path.module}/install_ansible.sh")
}


#   provisioner "remote-exec" {
#     inline = ["SSH"]
#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       private_key = local_file.ssh_key.content
#       host        = self.public_ip
#     }
# #   }
#   provisioner "local-exec" {
#     command = "ansible-playbook -i ${self.public_ip}, --private-key ${local.private_key_path} jenkins.yaml"
#   }
