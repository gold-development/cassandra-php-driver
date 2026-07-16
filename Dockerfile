FROM php:8.4
WORKDIR /tmp/cassandra-php-driver

RUN apt update -y \
 && apt install python3 pip cmake unzip plocate build-essential git libuv1-dev libssl-dev libgmp-dev openssl zlib1g-dev libpcre2-dev -y \
 && pip install --break-system-packages --ignore-installed setuptools git+https://github.com/apache/cassandra-ccm \
 && apt-get install -y wget gnupg ca-certificates \
 && mkdir -p /etc/apt/keyrings \
 && wget -O /etc/apt/keyrings/adoptium.gpg https://packages.adoptium.net/artifactory/api/gpg/key/public \
 && echo "deb [signed-by=/etc/apt/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb bookworm main" > /etc/apt/sources.list.d/adoptium.list \
 && apt-get update \
 && apt-get install -y temurin-11-jdk \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p ~/.ccm && echo '[repositories]\ncassandra = https://dlcdn.apache.org/cassandra' > ~/.ccm/config

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin
RUN docker-php-source extract \
 && install-php-extensions @composer intl zip pcntl gmp ast xdebug yaml

COPY lib lib
RUN cmake -DCMAKE_CXX_FLAGS="-fPIC" -DCASS_BUILD_STATIC=OFF -DCASS_BUILD_SHARED=ON -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_LIBDIR:PATH=lib -DCASS_USE_ZLIB=ON lib/cpp-driver \
 && make -j$(nproc) \
 && make install

RUN docker-php-source extract

COPY ext ext
ENV NO_INTERACTION=true
RUN cd ext \
 && phpize \
 && LDFLAGS="-L/usr/local/lib" LIBS="-lssl -lz -luv -lm -lgmp -lstdc++" ./configure --with-cassandra=/usr/local \
 && make -j$(nproc) \
 && make test \
 && make install \
 && mv cassandra.ini /usr/local/etc/php/conf.d/docker-php-ext-cassandra.ini \
 && cd ..

RUN ext/doc/generate_doc.sh

COPY composer.json .
RUN composer install -n

ARG CI
ENV CI=$CI

COPY support support
COPY tests tests
COPY phpunit.xml .
ENV JAVA_HOME=/usr
RUN bin/phpunit --stop-on-error --stop-on-failure --testsuite unit
# integration + behat suites need a live Cassandra cluster (ccm), which is not
# runnable inside `docker build`. Run them in a separate runtime job instead.

RUN make clean \
 && make clean -C ext

CMD ["bash"]
