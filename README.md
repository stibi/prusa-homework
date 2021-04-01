# Prusa homework

## Requirements

- DigitalOcean account
- Terraform
- Ansible
- Docker & docker-compose (both locally)
- [do-ansible-inventory](https://github.com/do-community/do-ansible-inventory) To generate inventory with DigitalOcean droplets to be used with Ansible
- [community.docker.docker_compose](https://docs.ansible.com/ansible/latest/collections/community/docker/docker_compose_module.html#ansible-collections-community-docker-docker-compose-module)
- [community.general.htpasswd](https://docs.ansible.com/ansible/latest/collections/community/general/htpasswd_module.html)
- [community.postgresql.postgresql_db](https://docs.ansible.com/ansible/latest/collections/community/postgresql/postgresql_db_module.html)
- [community.postgresql.postgresql_user](https://docs.ansible.com/ansible/latest//collections/community/postgresql/postgresql_user_module.html)

## Docker image

Build the image with `latest` tag:

```
docker build -t stibi/prusa-homework .
```

Push to [Dockerhub](https://hub.docker.com/repository/docker/stibi/prusa-homework/):

```
docker push stibi/prusa-homework
```

Or you can use the `Makefile` and its `build` and `push` targets.

## Deployment steps

```
$ ansible-playbook --private-key ~/.ssh/prusa_ukol -i inventory install_server.yml
```

### Terraform

TODO

### Ansible

Generate ansible inventory from already existing DigitalOcean droplets:

```
cd ansible/
do-ansible-inventory --no-group-by-region --no-group-by-project --out inventory
```

or with the `Makefile` with `make inventory`

```
❯ ansible-vault encrypt_string 'JofHEahIjSGFYRQoydV8yA==' --name 'app_db_user_password'
```



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
  - [ ] create read only dev user
  - postgres is install and configured using ubuntu package, no container
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
- [ ] Documentation
  - how to replicate the setup
  - maybe a picture with schema?

## TODO

- multistaged docker image build (because of the need for gcc)
- verze k python zavislostem
- terraform tfstate remote backend
