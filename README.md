# Legacy Data Processor

Deployment of a lightweight Data Processor microservice (Python API behind an
Nginx reverse proxy) on an Ubuntu 22.04 server, deployed with Terraform and
configured with Ansible.

## Architecture

- **Terraform** provisions one Ubuntu 22.04 EC2 instance (us-east-1), a key pair
  and a security group
- **Ansible** configures the host: service account (dataproc), firewall (UFW), Docker, and the stack
- **Docker Compose** (v2 plugin) runs the Python API and Nginx.

## Prerequisites

- Terraform >= 1.6, AWS CLI configured
- Ansible (Linux/WSL2 on Windows) with the community.general collection
- An SSH key pair

## How to run from scratch

1. Provision the server:
```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars   # set ssh_allowed_cidr to your public IP /32
   terraform init
   terraform apply
   terraform output public_ip
```
2. Create the Ansible inventory:
```bash
   cd ../ansible
   cp inventory.ini.example inventory.ini         # replace host with the public IP
   ansible dataproc -m ping
```
3. Configure and deploy:
```bash
   ansible-playbook deploy.yml
```
   A second run should report `changed=0`.
4. Verify (replace `<public_ip>`):
```bash
   curl -I http://<public_ip>:8080                                    # HTTP/1.1 200 OK
   curl -m 5 http://<public_ip>:5000                                  # times out
   ansible dataproc -b -a "docker ps"
   ansible dataproc -b -a "systemctl is-active dataproc"
   ansible dataproc -b -a "docker exec dataproc-api id"               # uid=2048
   ansible dataproc -b -a "tail -3 /var/log/nginx/custom-access.log"
```
5. Dismantle: `cd terraform && terraform destroy`

## Design decisions

- **Default VPC** for simplicity
- **AMI via data source** (Canonical, jammy) instead of a hardcoded AMI ID
- **SSH restricted** to the operator's IP through the security group. The CIDR is
  a variable kept in ignored terraform.tfvars. If your ISP changes your IP (like in my particular case)
  SSH times out, update it and run terraform apply again.
- **EC2 hardening:** encrypted root volume (EBS).
- **Service account:** dataproc user and group with UID/GID 2048, nologin
  shell, no home directory. A fixed UID keeps file ownership consistent between
  host and container, which only share numeric IDs.
- **Firewall (UFW):** enabled, default deny incoming. Port 8080 carries the
  application traffic. Port 22 is also allowed for Ansible/SSH management and is
  additionally restricted to the admin's IP by the AWS security group
- **Docker and UFW:** Only Nginx publishes a port (8080), the Python API is reachable
  only through the internal Compose network.
- **Docker from the official repository:** Ubuntu's docker.io package does not
  ship the docker compose plugin
- **No docker_compose Ansible module:** No docker-compose pip package
  (legacy constraint). The compose file is templated to the host and
  `dataproc.service` (`Type=oneshot`) runs `docker compose up -d --build`.
- **Nginx log:** Ansible creates `/var/log/nginx/custom-access.log` on the host
  before the containers start, otherwise Docker would create a directory with that name.
- **host_key_checking = False** (in ansible.cfg) because the server is ephemeral
  and its host key changes on every recreate.

## Some issues I found in the provided files

Before deploying, I ran the starter files locally with the entrypoint's arguments:

- **app.py** raised a `ValueError`: it reads the port from `sys.argv[2]`, which is
  `--port` when called as `api --port 5000`. It now reads `sys.argv[3]`.
- **entrypoint.sh** uses `#!/bin/sh` with a bash array. Running it with `dash`
  fails with `Syntax error: "(" unexpected`. The shebang is now `#!/bin/bash`.
