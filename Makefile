build:
	docker build -t stibi/prusa-homework .

push:
	docker push stibi/prusa-homework

inventory:
	do-ansible-inventory --no-group-by-region --no-group-by-project --out ansible/inventory/hosts
