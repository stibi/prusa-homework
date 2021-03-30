# Prusa homework

## Requirements

- DigitalOcean account
- Terraform
- Ansible
- Docker & docker-compose (both locally)
- [do-ansible-inventory](https://github.com/do-community/do-ansible-inventory) To generate inventory with DigitalOcean droplets to be used with Ansible
- [community.docker.docker_compose](https://docs.ansible.com/ansible/latest/collections/community/docker/docker_compose_module.html#ansible-collections-community-docker-docker-compose-module)
- [community.general.htpasswd](https://docs.ansible.com/ansible/latest/collections/community/general/htpasswd_module.html)

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



## Tasks

- [x] run server on DigitalOcean
- [ ] create `prusa_admin` user, passwordless sudo, no password, add ssh pubkey
- [ ] create `prusa_non_admin`, no sudo, no password, add ssh pubkey
- [ ] install packages: `curl`, `wget`, `vim`, `nano`and`jq`
- [x] dockerize the python app
- [ ] prepare postgres db
  - [ ] create full access application user
  - [ ] create read only dev user
- [x] start the python app with two containers
- [ ] start redis and connect with the app
- [ ] automatic start & restart of the app unless stopped
- [x] put load balancer in front of the app containers
- [x] http -> https redirect
- [x] setup TLS with LetsEncrypt
- [x] `/admin` with basic auth, `developer` user + random password
- [x] `/prepare-for-deploy` and `/ready-for-deploy` endpoint are blocked on load balancer
- [ ] prepare (re)deploy ansible playbook
  - build a new image
  - stops old containers, starts new ones
  - without downtime

## TODO

- multistaged docker image build (because of the need for gcc)
- verze k python zavislostem
- terraform tfstate remote backend
