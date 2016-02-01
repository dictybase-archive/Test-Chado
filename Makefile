
default: build test
build:
	docker build --rm -t dictybase/test-chado:devel .
test:
	docker run --rm -v $(PWD):/usr/src/test-chado dictybase/test-chado:devel
testpg: build
	docker run -d --name tcpostgres -e ADMIN_DB=tcdb -e ADMIN_USER=tcuser -e ADMIN_PASS=tcpass dictybase/postgres:9.4 \
		&& sleep 10 \
		&& docker run --rm -v $(PWD):/usr/src/test-chado --link tcpostgres:tcp -e TC_DSN="dbi:Pg:dbname=tcdb;host=tcp" -e TC_USER=tcuser \
			-e TC_PASS=tcpass dictybase/test-chado:devel \
			&& docker stop tcpostgres \
			&& docker rm tcpostgres

