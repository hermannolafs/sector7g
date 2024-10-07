iex:
	iex -S mix phx.server
iex-dbg:
	iex --dbg pry -S mix phx.server

docker-build:
	docker build -t sector7g:latest .

# TODO rethink tagging here
docker-build-and-load-minikube: docker-build
	mkdir -p _build/docker
	docker save --output _build/docker/sector7g.latest.tar sector7g:latest
	minikube image rm sector7g
	minikube image load _build/docker/sector7g.latest.tar

docker-build-clean:
	docker image rm sector7g || rm -rf _build/docker/*