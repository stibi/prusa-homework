# Prusa homework

## Requirements

- DigitalOcean account
- Terraform (0.14)
- Ansible (2.10.7)
- Docker
- DockerHub repository
- [do-ansible-inventory](https://github.com/do-community/do-ansible-inventory) To generate inventory with DigitalOcean droplets to be used with Ansible
- [community.docker.docker_compose](https://docs.ansible.com/ansible/latest/collections/community/docker/docker_compose_module.html#ansible-collections-community-docker-docker-compose-module)
- [community.general.htpasswd](https://docs.ansible.com/ansible/latest/collections/community/general/htpasswd_module.html)
- [community.postgresql.postgresql_db](https://docs.ansible.com/ansible/latest/collections/community/postgresql/postgresql_db_module.html)
- [community.postgresql.postgresql_user](https://docs.ansible.com/ansible/latest//collections/community/postgresql/postgresql_user_module.html)

## Solution description

- python app is dockerized, alpine-python used as the base image
- digitalocean is used as the cloud to run it, droplets to host the app, database and redis, load balancer to serve the requests
- each app instance is deployed to its own droplet
- app is running in a docker container and the container is managed by a systemd service
- on each server is also deployed nginx as a reverse proxy in front of the app, mainly to have some control over the traffic and to be able to restrict some requests
- redis and postgresql is installed on a single dedicated server, from system packages, not running in a docker container as there was no need to do so for these stateful applications
- ansible is used for server configuration and application deploy

## How to deploy

### Terraform

The terraform code under `terraform/` build all needed infrastructure on DigitalOcean.

It creates a couple of (configurable, default 2) droplets, virtual servers, to host the application, database and redis.

It also created a load balancer, takes care of a domain and configures firewall for droplets.

You need DigitalOcean account and API token, exported as environment variable `DIGITALOCEAN_ACCESS_TOKEN`, terraform will use it.

You might want to configure some variables in `terraform.tfvars` to suit you:

- `default_ssh_key_fingerprint`: fingerprint of your SSH key on DigitalOcean, so you (and Ansible) can connect to droplets with SSH
- `domain`: domain to be used, A record will be pointed to load balancer, make sure NS servers of your domain are configured to DigitalOcean
- `app_servers_count`: number of app server droplets, up to you, it means how many copies of the app will be running, default is 2
- `ssh_allowed_addresses`: source address allowed for SSH connection to droplets, make sure yours is here

After the configuration is done, run terraform:

```
$ terraform init
$ terraform plan # you can/should review the plan
$ terraform apply
```

After successful `apply`, verify all the created resources under your DigitalOcean account.

### Ansible

Ansible is the automation tool choosen to take care of provisioning the application and all its requirements on servers running on DigitalOcean,
previously created by Terraform.

There is several roles and playbooks to take care of installing and configuring all needed parts or to handle the application lifecycle.

Some initial configuration is needed. You need to make a copy of `ansible.cfg.example`, save it as `ansible.cfg` and configure path to your SSH private key (`private_key_file` property) that allows 
connection to DigitalOcean droplets and path to file with Ansible Vault password (`vault_password_file`), so Ansible is able to encrypt&decrypt secrets 
in playbooks and roles.

Next step is to generate Ansible inventory. List of hosts, DigitalOcean droplets in this case, which Ansible will manage. This is automated using the
[do-ansible-inventory](https://github.com/do-community/do-ansible-inventory) tool, which lookups the Droplets using API, groups them using its tags and
generates the Ansible invetory file for us.

Use the attached `Makefile` to do so:

```
$ make inventory
```

The result should be up to date inventory file in `ansible/inventory/hosts`. Take a look if it is correct and ip addresses match your droplets.

Now with the inventory file, you can check if Ansible is able to connect to each host, which will verify the inventory file and configuration of SSH key:

```
$ cd ansible/
$ ansible all -m ping
prusa-homework-app-server-01 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
prusa-homework-app-server-02 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

If you see similar output, you are good.

Now you can proceed with provisioning the application servers. It's covered with 3 Ansible playbooks you need to run in order.

#### 01_install_server.yml

This playbook does basic configuration and it is applied on all servers:

- `base` role install a couple of packages and configures passwordless `sudo` for the `sudo` user group
- `users` role creates admin and non-admin user and uploads their SSH pubkeys
- `docker` install docker

Run the playbook with:

```
$ ansible-playbook 01_install_server.yml
```

#### 02_install_app.yml

This playbook does two main goals: 

- application setup and deployment to all servers
- database and redis installation and configuration on one selected server

While the application deployment is easy and done on all servers, database and redis is running on a single server, which is determined by the `db_server`
droplet tag. A droplet assigned with the tag acts as the db server.

The `homework-app` role is applied on all servers, it installs and configures a systemd service to run the application, it configures all needed
parameters for database and redis connection, installs and configures nginx reverse proxy running on each server, in front of the application and
behind the DigitalOcean load balancer.

The `postgres` and `redis` role is applied on the `db_server` host group and as a result, postgres and redis is installed and configured.

The `homework-app` expects that the docker image exist and can be pulled, but in case it is not so, then the next playbook can fix that and deploy
the app to a running state.

Run the playbook with:

```
$ ansible-playbook 02_install_app.yml
```

You can check on each servers if the systemd service is running with `systemctl status homeworkapp` or if it actually respodons with `curl 127.0.0.1`.

Tip: Request `/whoami` to verify that each request is really load balanced between all available droplets:

```
$ curl https://devopsakuprusi.cz/whoami 
This is container 8b3763abf948%                                                                     

$ curl https://devopsakuprusi.cz/whoami
This is container f76d3aa046eb
```

#### 03_build_and_deploy.yml

This playbook takes care of application build & deploy.

First step is docker image build. The image tag is always `latest`, which is considered good enough for this use case. For each build, the `BUILD_VERSION_ARG`
build argument is set to current timestamp, which is then available as an environment variable.

After the build, the playbook will deploy the image on each server, sequentially, one by one, always wiating for a new container to start responding before
it moves on to next server.

Tip: Request `/version` to get currently deployed docker image:

```
$ curl https://devopsakuprusi.cz/version
Ansible build 2021-04-08 22:18:09
```

## SSH

SSH is available on droplets public ip (check DigitalOcean administration or the ansibel invetory file).

Use `root` user with your DigitalOcean SSH key, or the `prusa_admin` or `prusa_non_admin` users with respective key.

## Tasks

- [x] run server on DigitalOcean
  - done and managed by Terraform
- [x] create `prusa_admin` user, passwordless sudo, no password, add ssh pubkey
  - passwordless `sudo` configured on all servers using the `base` Ansible role
  - user created on all servers using the `base` role
- [x] create `prusa_non_admin`, no sudo, no password, add ssh pubkey
  - user created on all servers using the `base` role and the `01_install_server.yml` playbook
- [x] install packages: `curl`, `wget`, `vim`, `nano` and `jq`
  - Done using the ansible `base` role
- [x] dockerize the python app
  - `Dockerfile` ready, Dockerhub repo created, alpine-python used as the base image
- [x] prepare postgres db
  - [x] create full access application user
  - [x] create read only dev user
  - postgres is installed and configured using ubuntu package, no container
  - automation done using Ansible, the `postgres` role
- [x] start the python app with two containers
  - 2 servers (DO droplets), each with 1 container running, managed by a systemd service, nginx (not containerized) as a reverse proxy on each server
- [x] start redis and connect with the app
  - done by installing Redis from an ubuntu package, not container, automated using the `redis` Ansible role
- [x] automatic start & restart of the app unless stopped
  - systemd takes care of that
- [x] put load balancer in front of the app containers
  - DigitalOcean load balancer created, forwarding requests to all app servers
  - healthcheck for app availability (`/status` endpoint) configured
- [x] http -> https redirect
  - configured on the DO load balancer
- [x] setup TLS with LetsEncrypt
  - configured on the DO load balancer
- [x] `/admin` with basic auth, `developer` user + random password
  - done on the nginx reverse proxy on each server
  - covered with Ansible code, part of the `homework-app` role
- [x] `/prepare-for-deploy` and `/ready-for-deploy` endpoint are blocked on load balancer
  - done on the nginx reverse proxy on each server
  - covered with Ansible code, part of the `homework-app` role
- [x] prepare (re)deploy ansible playbook
  - done with the `03_build_and_deploy.yml` ansible playbook
  - build and push the image
  - then deploys to each app server, one by one, always waiting until the app is up and responding with `HTTP 200`
- [x] Documentation

## TODO

- configurable image name, pro případ jiného docker hostingu
