# Prusa ukol

## Tasks

- [ ] run server on DigitalOcean
- [ ] create `prusa_admin` user, passwordless sudo, no password, add ssh pubkey
- [ ] create `prusa_non_admin`, no sudo, no password, add ssh pubkey
- [ ] install packages: `curl`, `wget`, `vim`, `nano`and`jq`
- [x] dockerize the python app
- [ ] prepare postgres db
  - [ ] create full access application user
  - [ ] create read only dev user
- [ ] start the python app with two containers
- [ ] start redis and connect with the app
- [ ] automatic start & restart of the app unless stopped
- [ ] put load balancer in front of the app containers
- [ ] http -> https redirect
- [ ] setup TLS with LetsEncrypt
- [ ] `/admin` with basic auth, `developer` user + random password
- [ ] `/prepare-for-deploy` and `/ready-for-deploy` endpoint are blocked on load balancer
- [ ] prepare (re)deploy ansible playbook
  - build a new image
  - stops old containers, starts new ones
  - without downtime

## TODO

- multistaged docker image build (because of the need for gcc)
- verze k python zavislostem
