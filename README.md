# PHP Driver for Apache Cassandra

[![build](https://github.com/gold-development/cassandra-php-driver/actions/workflows/build.yml/badge.svg)](https://github.com/gold-development/cassandra-php-driver/actions/workflows/build.yml)
[![build-windows](https://github.com/gold-development/cassandra-php-driver/actions/workflows/build-windows.yml/badge.svg)](https://github.com/gold-development/cassandra-php-driver/actions/workflows/build-windows.yml)

This is a fork of [DataStax's PHP driver][upstream] for Apache Cassandra,
maintained here because upstream has been in maintenance mode since 2023 and
does not build against current PHP. This fork adds the changes needed to
build and run on **PHP 8.4 and 8.5**, on both Linux and Windows, and keeps
that working through CI rather than by hand.

A modern, [feature-rich][Features] and highly tunable PHP client library for
[Apache Cassandra] 2.1+ using exclusively Cassandra's binary protocol and
Cassandra Query Language v3.

This is a wrapper around the [DataStax C/C++ Driver for Apache Cassandra].

## Getting the driver

**Windows** — prebuilt DLLs for PHP 8.4 and 8.5 (thread-safe and non-thread-safe,
x64) are attached to each [release][Releases], and to every
[build-windows run][build-windows] as workflow artifacts. Drop the DLL into
your PHP `ext` directory and add `extension=php_cassandra` to `php.ini`.

**Linux** — there is no packaged build yet; compile it yourself:

```bash
cd ext
phpize
./configure --with-cassandra=/usr/local   # path to a built libcassandra
make && sudo make install
```

or build the [Dockerfile](Dockerfile) in this repository, which builds the
DataStax C++ driver, compiles the extension against it, and runs the unit
suite in one step:

```bash
docker build . -t cassandra-php-driver
```

__Note__: the extension wraps the
[DataStax C/C++ Driver for Apache Cassandra], which is a build-time
dependency either way — `ext/README.md` has the details for a from-source
Linux build, and [`ci/windows`](ci/windows) shows exactly how the Windows
build stages OpenSSL, zlib, libuv and the C++ driver via vcpkg.

## Editor support

The extension is a compiled binary, so an editor has nothing to read
signatures or docblocks from. `ext/doc` documents every class the extension
registers as plain (uninstantiable) PHP, generated from the docs in
`ext/src/*.yaml` by reflecting over the loaded extension — see
[`ext/doc/README.md`](ext/doc/README.md).

Composer cannot install this repository directly: its `composer.json` is
`type: php-ext`, which Composer refuses to install (that type belongs to
[PIE]). Describe it as an inline package instead, pinned to a commit:

```json
{
  "repositories": [
    {
      "type": "package",
      "package": {
        "name": "gold-development/cassandra-stubs",
        "version": "1.5.0",
        "type": "library",
        "dist": {
          "type": "zip",
          "url": "https://github.com/gold-development/cassandra-php-driver/archive/<commit-sha>.zip",
          "reference": "<commit-sha>"
        }
      }
    }
  ],
  "require-dev": {
    "gold-development/cassandra-stubs": "1.5.0"
  }
}
```

Editors index `vendor/` on their own, so nothing further to configure.
Two reserved PHP keywords are involved: `Cassandra\Float` and
`Cassandra\Function` are what the extension actually registers, but PHP will
not parse a class or type declared with either name, so the stubs are named
`Float_`/`Function_` and `class_alias()` them back — write the real name in
your code.

Regenerating after a change to `ext/src/*.yaml` needs a build of this image,
since the generator reflects over the loaded extension and needs `ext-yaml`:

```bash
docker build . -t cassandra-php-driver
docker run --rm -v "$PWD/ext/doc:/tmp/cassandra-php-driver/ext/doc" cassandra-php-driver \
  php ext/doc/generate_doc.php ext
```

CI fails the build if `ext/doc` and `ext/src` disagree, so this is not
optional after touching the documentation.

## Compatibility

* Apache Cassandra 2.1, 2.2 and 3.0+
* PHP 8.4 and 8.5
  * Windows: 64-bit (x64), thread safe (TS) and non-thread safe (NTS), built
    with the matching VS17 toolchain
  * Linux: built and unit tested in Docker against `php:8.5`

## Documentation

* [Home] · [API] · [Features] — from upstream; the wire protocol, data types
  and CQL support have not changed, only the PHP build has.

## Getting help

This fork does not carry over upstream's DataStax-specific support channels
(their JIRA and mailing list are for the driver they maintain, not this
build). Use [GitHub Issues][Issues] for anything specific to this fork —
the Windows build, PHP 8.4/8.5 compatibility, or the generated stubs.

## Quick Start

```php
<?php
$cluster   = Cassandra::cluster()                 // connects to localhost by default
                 ->build();
$keyspace  = 'system';
$session   = $cluster->connect($keyspace);        // create session, optionally scoped to a keyspace
$statement = new Cassandra\SimpleStatement(       // also supports prepared and batch statements
    'SELECT keyspace_name, columnfamily_name FROM schema_columnfamilies'
);
$future    = $session->executeAsync($statement);  // fully asynchronous and easy parallel execution
$result    = $future->get();                      // wait for the result, with an optional timeout

foreach ($result as $row) {                       // results and rows implement Iterator, Countable and ArrayAccess
    printf("The keyspace %s has a table called %s\n", $row['keyspace_name'], $row['columnfamily_name']);
}
```

## Contributing

[Read our contribution policy][contribution-policy] for a detailed description
of the process. It is written for upstream; open a pull request against this
fork the same way.

## Code examples

The driver uses the [Behat Framework] for end-to-end, acceptance-style
testing and documentation. All supported features have appropriate
acceptance tests with [easy-to-copy code examples in the `features/`
directory][Features].

## Running tests

```bash
git clone --recursive https://github.com/gold-development/cassandra-php-driver.git
cd cassandra-php-driver
docker build . -t cassandra-php-driver --build-arg CI=1
```

The unit suite (`bin/phpunit --testsuite unit`) runs as part of the image
build and fails it on any failure. The Behat suite needs a live Cassandra
cluster (`ccm`) and is not runnable inside `docker build`; run it in a
container started from the image instead, against a cluster you provide.

## Copyright

&copy; DataStax, Inc. Contains modifications by Gold Development to keep the
driver building on current PHP versions.

Licensed under the Apache License, Version 2.0 (the “License”); you may not use
this file except in compliance with the License. You may obtain a copy of the
License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.

[Apache Cassandra]: http://cassandra.apache.org
[DataStax C/C++ Driver for Apache Cassandra]: http://docs.datastax.com/en/developer/cpp-driver/latest
[upstream]: https://github.com/datastax/php-driver
[Releases]: https://github.com/gold-development/cassandra-php-driver/releases
[build-windows]: https://github.com/gold-development/cassandra-php-driver/actions/workflows/build-windows.yml
[Issues]: https://github.com/gold-development/cassandra-php-driver/issues
[PIE]: https://github.com/php/pie
[Home]: http://docs.datastax.com/en/developer/php-driver/latest
[API]: http://docs.datastax.com/en/developer/php-driver/latest/api
[contribution-policy]: https://github.com/datastax/php-driver/blob/master/CONTRIBUTING.md
[Behat Framework]: http://docs.behat.org
[Features]: /features
