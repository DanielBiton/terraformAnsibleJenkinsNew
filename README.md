# Project Title

Devops Work Environment Setup with Terraform and Ansible

## Description

This project aims to create a complete DevOps work environment by integrating various tools into an EC2 instance on AWS using Terraform and Ansible. The infrastructure is provisioned using Terraform, including the creation of a VPC, a public subnet, a security group, a route table, a keypair, an internet gateway, and an EC2 instance. Additionally, an EventBridge rule is configured to automatically turn on the EC2 instance at 7 AM and off at 7 PM, and an alert is set up to notify when the EC2 instance is turned on or off. Ansible is used to install Jenkins, a CI/CD tool, on the EC2 instance and configure it to run on port 8080. The playbook will also install Docker engine on the same EC2 instance.

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [EventBridge Configuration](#eventbridge-configuration)
- [Alert Configuration](#alert-configuration)
- [Ansible Playbook](#ansible-playbook)
- [Accessing Jenkins](#accessing-jenkins)
- [Docker Engine Installation](#docker-engine-installation)
- [Contributing](#contributing)
- [License](#license)

## Requirements

To run this project, you need to have the following tools installed:

- Terraform [version]
- Ansible [version]
- AWS CLI [version]

## Installation

1. Clone this repository to your local machine.

   ```bash
   git clone https://github.com/your/repo.git
   ```

2. Install Terraform by following the instructions provided on the official Terraform website: [Terraform Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli).

3. Install Ansible by following the instructions provided on the official Ansible website: [Ansible Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/index.html).

4. Install the AWS CLI by following the instructions provided on the official AWS CLI User Guide: [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html).

## Usage

1. Configure your AWS credentials by running the following command and providing your AWS access key ID, secret access key, and default region.

   ```bash
   aws configure
   ```

2. Navigate to the project directory.

   ```bash
   cd devops-work-environment
   ```

3. Initialize Terraform in the project directory.

   ```bash
   terraform init
   ```

4. Run Terraform to create the infrastructure.

   ```bash
   terraform apply
   ```

   This command will create the VPC, public subnet, security group, route table, keypair, internet gateway, and EC2 instance on AWS.

## EventBridge Configuration

An EventBridge rule is set up to automatically turn on the EC2 instance at 7 AM and off at 7 PM. The rule is preconfigured in the Terraform code and will be created during the infrastructure provisioning process.

## Alert Configuration

An alert is configured to notify you when the EC2 instance is turned on or off. The alert is preconfigured in the Terraform code and will be created during the infrastructure provisioning process.

## Ansible Playbook

The Ansible playbook `install_jenkins.yml` is responsible for installing Jenkins on the EC2 instance. It will also install Docker engine on the same EC2 instance. You can find the playbook in the `ansible` directory of this project.

## Accessing Jenkins

Once the playbook execution is complete, you can access Jenkins by navigating to the EC2 instance's public IP address followed by port 8080. For example, if the public IP address is `123.456.789.0`, you can access Jenkins by visiting `http://123.456.789.0:8080` in your web browser.

## Docker Engine Installation

The Ansible playbook `install_jenkins.yml` also installs Docker engine on the same EC2 instance. This allows you to utilize Docker for containerization purposes.

## Contributing

Contributions to this project are welcome. If you find any issues or would like to suggest improvements, please create a new issue or submit a pull request.

## License

This project is licensed under the [MIT License](LICENSE).
