all: build
build:
	docker build . -t cassandra-php-driver --build-arg CI=$(CI)
run:
	docker run -v $$PWD/ext/doc:/tmp/cassandra-php-driver/ext/doc -it cassandra-php-driver
