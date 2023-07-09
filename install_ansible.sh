#!/bin/bash
yum update -y
yum -y install python3
yum -y install pip
cd /home/
yum -y install java 
mkdir install-jenkins
cd install-jenkins


python3 -m pip install ansible 

 echo "---
- hosts: target
  become: yes
  remote_user: ec2-user
  become_user: root
  hosts: localhost
  tasks:
  - name: Download Long Term Jenkins release
    get_url:
      url: https://pkg.jenkins.io/redhat-stable/jenkins.repo
      dest: /etc/yum.repos.d/jenkins.repo

  - name: Import jenkins key from url
    ansible.builtin.rpm_key:
      state: present
      key: https://pkg.jenkins.io/redhat-stable/jenkins.io.key

  - name: yum update
    yum:
      name: '*'
      state: latest

  - name: Install jenkins
    yum:
      name: jenkins
      state: latest

  - name: daemon-reload to pick up config changes
    ansible.builtin.systemd:
      daemon_reload: yes

  - name: Start jenkins
    ansible.builtin.systemd:
      name: jenkins
      state: started" >> install-jenkins.yml
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum install fontconfig java-11-openjdk
yum install jenkins
ansible-playbook install-jenkins.yml