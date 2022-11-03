#!/usr/bin/env bash
# SOURCE: https://gist.github.com/magnetikonline/58eb344e724d878345adc8622f72be13

set -e

INSTALL_BASE="/usr/local"

AUTOCONF_ARCHIVE="autoconf-2.71"
AUTOCONF_URL="http://ftpmirror.gnu.org/autoconf/$AUTOCONF_ARCHIVE.tar.gz"

AUTOMAKE_ARCHIVE="automake-1.16.5"
AUTOMAKE_URL="http://ftpmirror.gnu.org/automake/$AUTOMAKE_ARCHIVE.tar.gz"

LIBTOOL_ARCHIVE="libtool-2.4.7"
LIBTOOL_URL="http://ftpmirror.gnu.org/libtool/$LIBTOOL_ARCHIVE.tar.gz"

JQ_ARCHIVE="jq-1.6"
JQ_URL="https://github.com/stedolan/jq/releases/download/$JQ_ARCHIVE/$JQ_ARCHIVE.tar.gz"


# build and install autoconf
curl --location --remote-name --silent "$AUTOCONF_URL"
tar --extract --file "$AUTOCONF_ARCHIVE.tar.gz"

pushd "$AUTOCONF_ARCHIVE"
./configure --prefix="$INSTALL_BASE"
make
sudo make install
popd


# build and install automake
curl --location --remote-name --silent "$AUTOMAKE_URL"
tar --extract --file "$AUTOMAKE_ARCHIVE.tar.gz"

pushd "$AUTOMAKE_ARCHIVE"
./configure --prefix="$INSTALL_BASE"
make
sudo make install
popd


# build and install libtool
curl --location --remote-name --silent "$LIBTOOL_URL"
tar --extract --file "$LIBTOOL_ARCHIVE.tar.gz"

pushd "$LIBTOOL_ARCHIVE"
./configure --prefix="$INSTALL_BASE" --disable-dependency-tracking --enable-ltdl-install
make
sudo make install
popd


# build and install jq
curl --location --remote-name --silent "$JQ_URL"
tar --extract --file "$JQ_ARCHIVE.tar.gz"
pushd "$JQ_ARCHIVE"

# fixup packaging bug with oniguruma
pushd "modules/oniguruma"
autoreconf -fi
popd

# note: https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/jq.rb
curl \
	--output "flat_namespace.patch" \
	--silent \
		https://raw.githubusercontent.com/Homebrew/formula-patches/03cf8088210822aa2c1ab544ed58ea04c897d9c4/libtool/configure-big_sur.diff

patch <flat_namespace.patch

# note: https://github.com/stedolan/jq/issues/1936
patch -p0 <<'EOF'
--- src/builtin.c.orig	2022-07-09 22:34:02.000000000 +1000
+++ src/builtin.c	2022-07-09 22:34:07.000000000 +1000
@@ -43,6 +43,7 @@
 #include "jv_unicode.h"
 #include "jv_alloc.h"

+char lgamma_r ();

 static jv type_error(jv bad, const char* msg) {
   char errbuf[15];
EOF

./configure --prefix="$INSTALL_BASE" --disable-maintainer-mode --with-oniguruma=builtin
make
sudo make install

popd
jq --version

# done!
