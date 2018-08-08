#!/bin/bash

GITDIR=$(pwd)
APIVERSION=$(php -i | grep 'PHP API' | sed -e 's/PHP API => //')
PHPVERSION=$(php-config --version | cut -d '.' -f1-2)
TEMPDIR=$(mktemp -d)

function die { echo "$*" 1>&2 ; exit 1; }

function compress {
	gzip "$1" || die "cannot gzip $1"
}

## building snuffleupagus
make release

cd "$TEMPDIR"

mkdir -p "$TEMPDIR/package/data/etc/php/$PHPVERSION/mods-available/"
mkdir -p "$TEMPDIR/package/data/usr/lib/php/$APIVERSION/"
mkdir -p "$TEMPDIR/package/data/usr/share/doc/snuffleupagus/examples"

cp "$GITDIR/debian/control.install" "$TEMPDIR/package/control.install"

## /etc/
cp "$GITDIR/config/snuffleupagus.ini" "$TEMPDIR/package/data/etc/php/$PHPVERSION/mods-available/"

## /usr/
cp "$GITDIR/src/modules/snuffleupagus.so" "$TEMPDIR/package/data/usr/lib/php/$APIVERSION/"
cp "$GITDIR/debian/copyright" "$TEMPDIR/package/data/usr/share/doc/snuffleupagus/copyright"
cp "$GITDIR/debian/changelog" "$TEMPDIR/package/data/usr/share/doc/snuffleupagus/changelog"
cp "$GITDIR/README.md" "$TEMPDIR/package/data/usr/share/doc/snuffleupagus/README.md"
cp "$GITDIR/config/default.rules" "$TEMPDIR/package/data/usr/share/doc/snuffleupagus/examples/default.rules"

## gzipping (copyright doesn't require that)
compress "$TEMPDIR/package/data/usr/share/doc/snuffleupagus/changelog"
compress "$TEMPDIR/package/data/usr/share/doc/snuffleupagus/README.md"
compress "$TEMPDIR/package/data/usr/share/doc/snuffleupagus/examples/default.rules"

## downloading deb building system.
git clone https://github.com/wargio/deb-creator

bash deb-creator/deb-creator "$TEMPDIR/package"

cp "$TEMPDIR/package/"*.deb "$GITDIR/"

rm -rf "$TEMPDIR"

echo "DEB file can be found at "$(ls "$GITDIR/"*.deb)
