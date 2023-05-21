FROM debian:bullseye-slim

ARG VERSION=1.19.0
ARG PREFIX=/w64devkit
ARG BINUTILS_VERSION=2.40
ARG BUSYBOX_VERSION=FRP-5007-g82accfc19
ARG CTAGS_VERSION=6.0.0
ARG EXPAT_VERSION=2.5.0
ARG GCC_VERSION=13.1.0
ARG GDB_VERSION=13.1
ARG GMP_VERSION=6.2.1
ARG LIBICONV_VERSION=1.17
ARG MAKE_VERSION=4.4
ARG MINGW_VERSION=11.0.0
ARG MPC_VERSION=1.2.1
ARG MPFR_VERSION=4.1.0
ARG NASM_VERSION=2.15.05
ARG PDCURSES_VERSION=3.9
ARG CPPCHECK_VERSION=2.10
ARG VIM_VERSION=9.0
ARG GNUPG_VERSION=2.4.1
ARG LIBASSUAN_VERSION=2.5.5
ARG LIBGCRYPT_VERSION=1.10.2
ARG LIBGPGERROR_VERSION=1.47
ARG LIBKSBA_VERSION=1.6.3
ARG NPTH_VERSION=1.6
ARG PINENTRY_VERSION=1.2.1

RUN apt-get update && apt-get install --yes --no-install-recommends \
  build-essential curl gettext libgmp-dev libmpc-dev libmpfr-dev m4 zip

# Download, verify, and unpack

RUN curl --insecure --location --remote-name-all --remote-header-name \
    https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VERSION.tar.xz \
    https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.xz \
    https://ftp.gnu.org/gnu/gdb/gdb-$GDB_VERSION.tar.xz \
    https://fossies.org/linux/www/expat-$EXPAT_VERSION.tar.xz \
    https://ftp.gnu.org/gnu/gmp/gmp-$GMP_VERSION.tar.xz \
    https://ftp.gnu.org/gnu/mpc/mpc-$MPC_VERSION.tar.gz \
    https://ftp.gnu.org/gnu/mpfr/mpfr-$MPFR_VERSION.tar.xz \
    https://ftp.gnu.org/gnu/make/make-$MAKE_VERSION.tar.gz \
    https://ftp.gnu.org/gnu/libiconv/libiconv-$LIBICONV_VERSION.tar.gz \
    https://frippery.org/files/busybox/busybox-w32-$BUSYBOX_VERSION.tgz \
    http://ftp.vim.org/pub/vim/unix/vim-$VIM_VERSION.tar.bz2 \
    https://www.nasm.us/pub/nasm/releasebuilds/$NASM_VERSION/nasm-$NASM_VERSION.tar.xz \
    https://github.com/universal-ctags/ctags/archive/refs/tags/v$CTAGS_VERSION.tar.gz \
    https://downloads.sourceforge.net/project/mingw-w64/mingw-w64/mingw-w64-release/mingw-w64-v$MINGW_VERSION.tar.bz2 \
    https://downloads.sourceforge.net/project/pdcurses/pdcurses/$PDCURSES_VERSION/PDCurses-$PDCURSES_VERSION.tar.gz \
    https://github.com/danmar/cppcheck/archive/$CPPCHECK_VERSION.tar.gz \
    https://gnupg.org/ftp/gcrypt/gnupg/gnupg-$GNUPG_VERSION.tar.bz2 \
    https://gnupg.org/ftp/gcrypt/libassuan/libassuan-$LIBASSUAN_VERSION.tar.bz2 \
    https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-$LIBGCRYPT_VERSION.tar.bz2 \
    https://gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-$LIBGPGERROR_VERSION.tar.bz2 \
    https://gnupg.org/ftp/gcrypt/libksba/libksba-$LIBKSBA_VERSION.tar.bz2 \
    https://gnupg.org/ftp/gcrypt/npth/npth-$NPTH_VERSION.tar.bz2 \
    https://gnupg.org/ftp/gcrypt/pinentry/pinentry-$PINENTRY_VERSION.tar.bz2
COPY src/SHA256SUMS $PREFIX/src/
RUN sha256sum -c $PREFIX/src/SHA256SUMS \
 && tar xJf binutils-$BINUTILS_VERSION.tar.xz \
 && tar xzf busybox-w32-$BUSYBOX_VERSION.tgz \
 && tar xzf ctags-$CTAGS_VERSION.tar.gz \
 && tar xJf gcc-$GCC_VERSION.tar.xz \
 && tar xJf gdb-$GDB_VERSION.tar.xz \
 && tar xJf expat-$EXPAT_VERSION.tar.xz \
 && tar xzf libiconv-$LIBICONV_VERSION.tar.gz \
 && tar xJf gmp-$GMP_VERSION.tar.xz \
 && tar xzf mpc-$MPC_VERSION.tar.gz \
 && tar xJf mpfr-$MPFR_VERSION.tar.xz \
 && tar xzf make-$MAKE_VERSION.tar.gz \
 && tar xjf mingw-w64-v$MINGW_VERSION.tar.bz2 \
 && tar xzf PDCurses-$PDCURSES_VERSION.tar.gz \
 && tar xJf nasm-$NASM_VERSION.tar.xz \
 && tar xjf vim-$VIM_VERSION.tar.bz2 \
 && tar xzf cppcheck-$CPPCHECK_VERSION.tar.gz \
 && tar xjf gnupg-$GNUPG_VERSION.tar.bz2 \
 && tar xjf libassuan-$LIBASSUAN_VERSION.tar.bz2 \
 && tar xjf libgcrypt-$LIBGCRYPT_VERSION.tar.bz2 \
 && tar xjf libgpg-error-$LIBGPGERROR_VERSION.tar.bz2 \
 && tar xjf libksba-$LIBKSBA_VERSION.tar.bz2 \
 && tar xjf npth-$NPTH_VERSION.tar.bz2 \
 && tar xjf pinentry-$PINENTRY_VERSION.tar.bz2
COPY src/w64devkit.c src/w64devkit.ico \
     src/alias.c src/debugbreak.c src/pkg-config.c \
     $PREFIX/src/

ARG ARCH=x86_64-w64-mingw32

# Build cross-compiler

WORKDIR /binutils-$BINUTILS_VERSION
COPY src/binutils-*.patch $PREFIX/src/
RUN sed -ri 's/(static bool insert_timestamp = )/\1!/' ld/emultempl/pe*.em \
 && cat $PREFIX/src/binutils-*.patch | patch -p1
WORKDIR /x-binutils
RUN /binutils-$BINUTILS_VERSION/configure \
        --prefix=/bootstrap \
        --with-sysroot=/bootstrap/$ARCH \
        --target=$ARCH \
        --disable-nls \
        --with-static-standard-libraries \
        --disable-multilib \
 && make MAKEINFO=true -j$(nproc) \
 && make MAKEINFO=true install

# Fixes i686 Windows XP regression
# https://sourceforge.net/p/mingw-w64/bugs/821/
RUN sed -i /OpenThreadToken/d /mingw-w64-v$MINGW_VERSION/mingw-w64-crt/lib32/kernel32.def

WORKDIR /x-mingw-headers
RUN /mingw-w64-v$MINGW_VERSION/mingw-w64-headers/configure \
        --prefix=/bootstrap/$ARCH \
        --host=$ARCH \
        --with-default-msvcrt=msvcrt-os \
 && make -j$(nproc) \
 && make install

WORKDIR /bootstrap
RUN ln -s $ARCH mingw

WORKDIR /x-gcc
RUN /gcc-$GCC_VERSION/configure \
        --prefix=/bootstrap \
        --with-sysroot=/bootstrap \
        --target=$ARCH \
        --enable-static \
        --disable-shared \
        --with-pic \
        --enable-languages=c,c++ \
        --enable-libgomp \
        --enable-threads=posix \
        --enable-version-specific-runtime-libs \
        --disable-dependency-tracking \
        --disable-nls \
        --disable-multilib \
        CFLAGS_FOR_TARGET="-Os" \
        CXXFLAGS_FOR_TARGET="-Os" \
        LDFLAGS_FOR_TARGET="-s" \
        CFLAGS="-Os" \
        CXXFLAGS="-Os" \
        LDFLAGS="-s" \
 && make -j$(nproc) all-gcc \
 && make install-gcc

ENV PATH="/bootstrap/bin:${PATH}"

WORKDIR /x-mingw-crt
RUN /mingw-w64-v$MINGW_VERSION/mingw-w64-crt/configure \
        --prefix=/bootstrap/$ARCH \
        --with-sysroot=/bootstrap/$ARCH \
        --host=$ARCH \
        --with-default-msvcrt=msvcrt-os \
        --disable-dependency-tracking \
        --disable-lib32 \
        --enable-lib64 \
        CFLAGS="-Os" \
        LDFLAGS="-s" \
 && make -j$(nproc) \
 && make install

WORKDIR /x-winpthreads
RUN /mingw-w64-v$MINGW_VERSION/mingw-w64-libraries/winpthreads/configure \
        --prefix=/bootstrap/$ARCH \
        --with-sysroot=/bootstrap/$ARCH \
        --host=$ARCH \
        --enable-static \
        --disable-shared \
        CFLAGS="-Os" \
        LDFLAGS="-s" \
 && make -j$(nproc) \
 && make install

WORKDIR /x-gcc
RUN make -j$(nproc) \
 && make install

# Cross-compile GCC

WORKDIR /binutils
RUN /binutils-$BINUTILS_VERSION/configure \
        --prefix=$PREFIX \
        --with-sysroot=$PREFIX/$ARCH \
        --host=$ARCH \
        --target=$ARCH \
        --disable-nls \
        --with-static-standard-libraries \
        CFLAGS="-Os" \
        LDFLAGS="-s" \
 && make MAKEINFO=true -j$(nproc) \
 && make MAKEINFO=true install \
 && rm $PREFIX/bin/elfedit.exe $PREFIX/bin/gprof.exe $PREFIX/bin/readelf.exe

WORKDIR /gmp
RUN /gmp-$GMP_VERSION/configure \
        --prefix=/deps \
        --host=$ARCH \
        --disable-assembly \
        --enable-static \
        --disable-shared \
        CFLAGS="-Os" \
        CXXFLAGS="-Os" \
        LDFLAGS="-s" \
 && make -j$(nproc) \
 && make install

WORKDIR /mpfr
RUN /mpfr-$MPFR_VERSION/configure \
        --prefix=/deps \
        --host=$ARCH \
        --with-gmp-include=/deps/include \
        --with-gmp-lib=/deps/lib \
        --enable-static \
        --disable-shared \
        CFLAGS="-Os" \
        LDFLAGS="-s" \
 && make -j$(nproc) \
 && make install

WORKDIR /mpc
RUN /mpc-$MPC_VERSION/configure \
        --prefix=/deps \
        --host=$ARCH \
        --with-gmp-include=/deps/include \
        --with-gmp-lib=/deps/lib \
        --with-mpfr-include=/deps/include \
        --with-mpfr-lib=/deps/lib \
        --enable-static \
        --disable-shared \
        CFLAGS="-Os" \
        LDFLAGS="-s" \
 && make -j$(nproc) \
 && make install

WORKDIR /mingw-headers
RUN /mingw-w64-v$MINGW_VERSION/mingw-w64-headers/configure \
        --prefix=$PREFIX/$ARCH \
        --host=$ARCH \
        --with-default-msvcrt=msvcrt-os \
 && make -j$(nproc) \
 && make install

WORKDIR /mingw-crt
RUN /mingw-w64-v$MINGW_VERSION/mingw-w64-crt/configure \
        --prefix=$PREFIX/$ARCH \
        --with-sysroot=$PREFIX/$ARCH \
        --host=$ARCH \
        --with-default-msvcrt=msvcrt-os \
        --disable-dependency-tracking \
        --disable-lib32 \
        --enable-lib64 \
        CFLAGS="-Os" \
        LDFLAGS="-s" \
 && make -j$(nproc) \
 && make install

WORKDIR /winpthreads
RUN /mingw-w64-v$MINGW_VERSION/mingw-w64-libraries/winpthreads/configure \
        --prefix=$PREFIX/$ARCH \
        --with-sysroot=$PREFIX/$ARCH \
        --host=$ARCH \
        --enable-static \
        --disable-shared \
        CFLAGS="-Os" \
        LDFLAGS="-s" \
 && make -j$(nproc) \
 && make install

WORKDIR /gcc
RUN /gcc-$GCC_VERSION/configure \
        --prefix=$PREFIX \
        --with-sysroot=$PREFIX/$ARCH \
        --with-native-system-header-dir=/include \
        --target=$ARCH \
        --host=$ARCH \
        --enable-static \
        --disable-shared \
        --with-pic \
        --with-gmp-include=/deps/include \
        --with-gmp-lib=/deps/lib \
        --with-mpc-include=/deps/include \
        --with-mpc-lib=/deps/lib \
        --with-mpfr-include=/deps/include \
        --with-mpfr-lib=/deps/lib \
        --enable-languages=c,c++ \
        --enable-libgomp \
        --enable-threads=posix \
        --enable-version-specific-runtime-libs \
        --disable-dependency-tracking \
        --disable-multilib \
        --disable-nls \
        --disable-win32-registry \
        --enable-mingw-wildcard \
        CFLAGS_FOR_TARGET="-Os" \
        CXXFLAGS_FOR_TARGET="-Os" \
        LDFLAGS_FOR_TARGET="-s" \
        CFLAGS="-Os" \
        CXXFLAGS="-Os" \
        LDFLAGS="-s" \
 && make -j$(nproc) \
 && make install \
 && rm -rf $PREFIX/$ARCH/bin/ $PREFIX/bin/$ARCH-* \
        $PREFIX/bin/ld.bfd.exe $PREFIX/bin/c++.exe $PREFIX/bin/lto-dump.exe \
 && $ARCH-gcc -DEXE=g++.exe -DCMD=c++ \
        -Os -fno-asynchronous-unwind-tables \
        -Wl,--gc-sections -s -nostdlib \
        -o $PREFIX/bin/c++.exe \
        $PREFIX/src/alias.c -lkernel32

# Create various tool aliases
RUN $ARCH-gcc -DEXE=gcc.exe -DCMD=cc \
        -Os -fno-asynchronous-unwind-tables -Wl,--gc-sections -s -nostdlib \
        -o $PREFIX/bin/cc.exe $PREFIX/src/alias.c -lkernel32 \
 && $ARCH-gcc -DEXE=gcc.exe -DCMD="cc -std=c99" \
        -Os -fno-asynchronous-unwind-tables -Wl,--gc-sections -s -nostdlib \
        -o $PREFIX/bin/c99.exe $PREFIX/src/alias.c -lkernel32 \
 && printf '%s\n' addr2line ar as c++filt cpp dlltool dllwrap elfedit g++ \
      gcc gcc-ar gcc-nm gcc-ranlib gcov gcov-dump gcov-tool ld nm objcopy \
      objdump ranlib readelf size strings strip windmc windres \
    | xargs -I{} -P$(nproc) \
          $ARCH-gcc -DEXE={}.exe -DCMD=$ARCH-{} \
            -Os -fno-asynchronous-unwind-tables \
            -Wl,--gc-sections -s -nostdlib \
            -o $PREFIX/bin/$ARCH-{}.exe $PREFIX/src/alias.c -lkernel32

# Build some extra development tools

WORKDIR /mingw-tools/gendef
COPY src/gendef-silent.patch $PREFIX/src/
RUN patch -d/mingw-w64-v$MINGW_VERSION -p1 <$PREFIX/src/gendef-silent.patch \
 && /mingw-w64-v$MINGW_VERSION/mingw-w64-tools/gendef/configure \
        --host=$ARCH \
        CFLAGS="-Os" \
        LDFLAGS="-s" \
 && make -j$(nproc) \
 && cp gendef.exe $PREFIX/bin/

WORKDIR /expat
RUN /expat-$EXPAT_VERSION/configure \
        --prefix=/deps \
        --host=$ARCH \
        --disable-shared \
        --without-docbook \
        --without-examples \
        --without-tests \
        CFLAGS="-Os" \
        LDFLAGS="-s" \
 && make -j$(nproc) \
 && make install

WORKDIR /PDCurses-$PDCURSES_VERSION
RUN make -j$(nproc) -C wincon \
        CC=$ARCH-gcc AR=$ARCH-ar CFLAGS="-I.. -Os -DPDC_WIDE" pdcurses.a \
 && cp wincon/pdcurses.a /deps/lib/libcurses.a \
 && cp curses.h /deps/include

WORKDIR /libiconv
RUN /libiconv-$LIBICONV_VERSION/configure \
        --prefix=/deps \
        --host=$ARCH \
        --disable-nls \
        --disable-shared \
        CFLAGS="-Os" \
        LDFLAGS="-s" \
 && make -j$(nproc) \
 && make install

WORKDIR /gdb
COPY src/gdb-*.patch $PREFIX/src/
RUN cat $PREFIX/src/gdb-*.patch | patch -d/gdb-$GDB_VERSION -p1 \
 && sed -i 's/quiet = 0/quiet = 1/' /gdb-$GDB_VERSION/gdb/main.c \
 && /gdb-$GDB_VERSION/configure \
        --host=$ARCH \
        --with-libexpat-prefix=/deps \
        --with-libgmp-prefix=/deps \
        --with-libiconv-prefix=/deps \
        --enable-tui \
        CFLAGS="-Os -DPDC_WIDE" \
        CXXFLAGS="-Os -DPDC_WIDE" \
        LDFLAGS="-s -L/deps/lib" \
 && make MAKEINFO=true -j$(nproc) \
 && cp gdb/.libs/gdb.exe gdbserver/gdbserver.exe $PREFIX/bin/

WORKDIR /make
RUN /make-$MAKE_VERSION/configure \
        --host=$ARCH \
        --disable-nls \
        CFLAGS="-Os" \
        LDFLAGS="-s" \
 && make -j$(nproc) \
 && cp make.exe $PREFIX/bin/ \
 && $ARCH-gcc -DEXE=make.exe -DCMD=make \
        -Os -fno-asynchronous-unwind-tables \
        -Wl,--gc-sections -s -nostdlib \
        -o $PREFIX/bin/mingw32-make.exe $PREFIX/src/alias.c -lkernel32

WORKDIR /busybox-w32
COPY src/busybox-*.patch $PREFIX/src/
RUN cat $PREFIX/src/busybox-*.patch | patch -p1 \
 && make mingw64_defconfig \
 && sed -ri 's/^(CONFIG_AR)=y/\1=n/' .config \
 && sed -ri 's/^(CONFIG_ASCII)=y/\1=n/' .config \
 && sed -ri 's/^(CONFIG_DPKG\w*)=y/\1=n/' .config \
 && sed -ri 's/^(CONFIG_FTP\w*)=y/\1=n/' .config \
 && sed -ri 's/^(CONFIG_LINK)=y/\1=n/' .config \
 && sed -ri 's/^(CONFIG_MAN)=y/\1=n/' .config \
 && sed -ri 's/^(CONFIG_MAKE)=y/\1=n/' .config \
 && sed -ri 's/^(CONFIG_PDPMAKE)=y/\1=n/' .config \
 && sed -ri 's/^(CONFIG_RPM\w*)=y/\1=n/' .config \
 && sed -ri 's/^(CONFIG_STRINGS)=y/\1=n/' .config \
 && sed -ri 's/^(CONFIG_TEST2)=y/\1=n/' .config \
 && sed -ri 's/^(CONFIG_TSORT)=y/\1=n/' .config \
 && sed -ri 's/^(CONFIG_UNLINK)=y/\1=n/' .config \
 && sed -ri 's/^(CONFIG_VI)=y/\1=n/' .config \
 && sed -ri 's/^(CONFIG_XXD)=y/\1=n/' .config \
 && make -j$(nproc) CROSS_COMPILE=$ARCH- \
    CONFIG_EXTRA_CFLAGS="-D_WIN32_WINNT=0x502" \
 && cp busybox.exe $PREFIX/bin/

# Create BusyBox command aliases (like "busybox --install")
RUN printf '%s\n' arch ash awk base32 base64 basename bash bc bunzip2 bzcat \
      bzip2 cal cat chattr chmod cksum clear cmp comm cp cpio crc32 cut date \
      dc dd df diff dirname dos2unix du echo ed egrep env expand expr factor \
      false fgrep find fold free fsync getopt grep groups gunzip gzip hd \
      head hexdump httpd iconv id inotifyd install ipcalc jn kill killall \
      less ln logname ls lsattr lzcat lzma lzop lzopcat md5sum mkdir \
      mktemp mv nc nl nproc od paste patch pgrep pidof pipe_progress pkill \
      printenv printf ps pwd readlink realpath reset rev rm rmdir sed seq sh \
      sha1sum sha256sum sha3sum sha512sum shred shuf sleep sort split \
      ssl_client stat su sum sync tac tail tar tee test time timeout touch \
      tr true truncate ts ttysize uname uncompress unexpand uniq unix2dos \
      unlzma unlzop unxz unzip uptime usleep uudecode uuencode watch \
      wc wget which whoami whois xargs xz xzcat yes zcat \
    | xargs -I{} -P$(nproc) \
          $ARCH-gcc -DEXE=busybox.exe -DCMD={} \
            -Os -fno-asynchronous-unwind-tables \
            -Wl,--gc-sections -s -nostdlib \
            -o $PREFIX/bin/{}.exe $PREFIX/src/alias.c -lkernel32

# TODO: Either somehow use $VIM_VERSION or normalize the workdir
WORKDIR /vim90/src
RUN ARCH= make -j$(nproc) -f Make_ming.mak \
        OPTIMIZE=SIZE STATIC_STDCPLUS=yes HAS_GCC_EH=no \
        UNDER_CYGWIN=yes CROSS=yes CROSS_COMPILE=$ARCH- \
        FEATURES=HUGE VIMDLL=yes NETBEANS=no WINVER=0x0501 \
 && $ARCH-strip vimrun.exe \
 && rm -rf ../runtime/tutor/tutor.* \
 && cp -r ../runtime $PREFIX/share/vim \
 && cp vimrun.exe gvim.exe vim.exe *.dll $PREFIX/share/vim/ \
 && cp xxd/xxd.exe $PREFIX/bin \
 && printf '@set SHELL=\r\n@start "" "%%~dp0/../share/vim/gvim.exe" %%*\r\n' \
        >$PREFIX/bin/gvim.bat \
 && printf '@set SHELL=\r\n@"%%~dp0/../share/vim/vim.exe" %%*\r\n' \
        >$PREFIX/bin/vim.bat \
 && printf '@set SHELL=\r\n@"%%~dp0/../share/vim/vim.exe" %%*\r\n' \
        >$PREFIX/bin/vi.bat \
 && printf '@vim -N -u NONE "+read %s" "+write" "%s"\r\n' \
        '$VIMRUNTIME/tutor/tutor' '%TMP%/tutor%RANDOM%' \
        >$PREFIX/bin/vimtutor.bat

# NOTE: nasm's configure script is broken, so no out-of-source build
WORKDIR /nasm-$NASM_VERSION
RUN ./configure \
        --host=$ARCH \
        CFLAGS="-Os" \
        LDFLAGS="-s" \
 && make -j$(nproc) \
 && cp nasm.exe ndisasm.exe $PREFIX/bin

WORKDIR /ctags-$CTAGS_VERSION
RUN sed -i /RT_MANIFEST/d win32/ctags.rc \
 && make -j$(nproc) -f mk_mingw.mak CC=gcc packcc.exe \
 && make -j$(nproc) -f mk_mingw.mak \
        CC=$ARCH-gcc WINDRES=$ARCH-windres \
        OPT= CFLAGS=-Os LDFLAGS=-s \
 && cp ctags.exe $PREFIX/bin/

WORKDIR /cppcheck-$CPPCHECK_VERSION
COPY src/cppcheck.mak src/cppcheck-*.patch $PREFIX/src/
RUN cat $PREFIX/src/cppcheck-*.patch | patch -p1 \
 && make -f $PREFIX/src/cppcheck.mak -j$(nproc) CXX=$ARCH-g++ \
 && mkdir $PREFIX/share/cppcheck/ \
 && cp -r cppcheck.exe cfg/ $PREFIX/share/cppcheck \
 && $ARCH-gcc -DEXE=../share/cppcheck/cppcheck.exe -DCMD=cppcheck \
        -Os -fno-asynchronous-unwind-tables -Wl,--gc-sections -s -nostdlib \
        -o $PREFIX/bin/cppcheck.exe \
        $PREFIX/src/alias.c -lkernel32

WORKDIR /pth
RUN /npth-$NPTH_VERSION/configure \
        --host=$ARCH \
        --prefix="/deps" \
        --enable-shared=no \
        --enable-static=yes \
        CFLAGS="-Os" \
 && make -j$(nproc) \
 && make install

WORKDIR /libgpg-error
RUN /libgpg-error-$LIBGPGERROR_VERSION/configure \
        --host=$ARCH \
        --prefix="/deps" \
        --enable-shared=no \
        --enable-static=yes \
        --disable-nls \
        --disable-doc \
        --disable-languages \
        CFLAGS="-Os" \
 && make -j$(nproc) \
 && make install \
 && cp src/gpg-error-config /deps/bin/

WORKDIR /libassuan
RUN /libassuan-$LIBASSUAN_VERSION/configure \
        --host=$ARCH \
        --prefix="/deps" \
        --enable-shared=no \
        --enable-static=yes \
        --with-libgpg-error-prefix="/deps" \
        CFLAGS="-Os" \
 && make -j$(nproc) \
 && make install

WORKDIR /libgcrypt
RUN /libgcrypt-$LIBGCRYPT_VERSION/configure \
        --host=$ARCH \
        --prefix="/deps" \
        --enable-shared=no \
        --enable-static=yes \
        --disable-doc \
        --with-libgpg-error-prefix="/deps" \
        CFLAGS="-Os" \
 && make -j$(nproc) \
 && make install

WORKDIR /libksba
RUN /libksba-$LIBKSBA_VERSION/configure \
        --host=$ARCH \
        --prefix="/deps" \
        --enable-shared=no \
        --enable-static=yes \
        --with-libgpg-error-prefix="/deps" \
 && make -j$(nproc) \
 && make install

WORKDIR /gnupg
RUN /gnupg-$GNUPG_VERSION/configure \
        --host=$ARCH \
        --prefix="$PREFIX" \
        --with-npth-prefix="/deps" \
        --with-libgpg-error-prefix="/deps" \
        --with-libgcrypt-prefix="/deps" \
        --with-libassuan-prefix="/deps" \
        --with-ksba-prefix="/deps" \
        --disable-bzip2 \
        --disable-card-support \
        --disable-ccid-driver \
        --disable-dirmngr \
        --disable-doc \
        --disable-gnutls \
        --disable-gpg-blowfish \
        --disable-gpg-cast5 \
        --disable-gpg-idea \
        --disable-gpg-md5 \
        --disable-gpg-rmd160 \
        --disable-gpgtar \
        --disable-ldap \
        --disable-libdns \
        --disable-nls \
        --disable-ntbtls \
        --disable-photo-viewers \
        --disable-regex \
        --disable-scdaemon \
        --disable-sqlite \
        --disable-wks-tools \
        --disable-zip \
        CFLAGS="-Os -fcommon" \
        LDFLAGS="-static -s" \
        LIBS="-lws2_32" \
 && make -j$(nproc) \
 && make install

WORKDIR /pinentry
RUN /pinentry-$PINENTRY_VERSION/configure \
        --host=$ARCH \
        --prefix="$PREFIX" \
        --with-libgpg-error-prefix="/deps" \
        --with-libassuan-prefix="/deps" \
        --with-libiconv-prefix="/deps" \
        --disable-ncurses \
        --disable-libsecret \
        --disable-pinentry-tty \
        --disable-pinentry-curses \
        --disable-pinentry-emacs \
        --disable-inside-emacs \
        --disable-pinentry-gtk2 \
        --disable-pinentry-gnome3 \
        --disable-pinentry-qt \
        --disable-pinentry-tqt \
        --disable-pinentry-fltk \
        LDFLAGS="-static -s" \
        LIBS="-lws2_32" \
 && make -j$(nproc) \
 && cp w32/pinentry-w32.exe $PREFIX/bin/pinentry.exe

# Pack up a release

WORKDIR /
RUN rm -rf $PREFIX/share/man/ $PREFIX/share/info/ $PREFIX/share/gcc-* \
 && rm -rf $PREFIX/lib/*.a $PREFIX/lib/*.la $PREFIX/include/*.h
COPY README.md Dockerfile src/w64devkit.ini $PREFIX/
RUN printf "id ICON \"$PREFIX/src/w64devkit.ico\"" >w64devkit.rc \
 && $ARCH-windres -o w64devkit.o w64devkit.rc \
 && $ARCH-gcc -DVERSION=$VERSION \
        -mno-stack-arg-probe -Xlinker --stack=0x10000,0x10000 \
        -Os -fno-asynchronous-unwind-tables \
        -Wl,--gc-sections -s -nostdlib \
        -o $PREFIX/w64devkit.exe $PREFIX/src/w64devkit.c w64devkit.o \
        -lkernel32 \
 && $ARCH-gcc \
        -Os -fno-asynchronous-unwind-tables \
        -Wl,--gc-sections -s -nostdlib \
        -o $PREFIX/bin/debugbreak.exe $PREFIX/src/debugbreak.c \
        -lkernel32 \
 && $ARCH-gcc \
        -Os -fwhole-program -fno-asynchronous-unwind-tables \
        -Wl,--gc-sections -s -nostdlib -DPKG_CONFIG_PREFIX="\"/$ARCH\"" \
        -o $PREFIX/bin/pkg-config.exe $PREFIX/src/pkg-config.c \
        -lkernel32 \
 && $ARCH-gcc -DEXE=pkg-config.exe -DCMD=pkg-config \
        -Os -fno-asynchronous-unwind-tables -Wl,--gc-sections -s -nostdlib \
        -o $PREFIX/bin/$ARCH-pkg-config.exe $PREFIX/src/alias.c -lkernel32 \
 && mkdir -p $PREFIX/$ARCH/lib/pkgconfig \
 && cp /mingw-w64-v$MINGW_VERSION/COPYING.MinGW-w64-runtime/COPYING.MinGW-w64-runtime.txt \
        $PREFIX/ \
 && printf "\n===========\nwinpthreads\n===========\n\n" \
        >>$PREFIX/COPYING.MinGW-w64-runtime.txt . \
 && cat /mingw-w64-v$MINGW_VERSION/mingw-w64-libraries/winpthreads/COPYING \
        >>$PREFIX/COPYING.MinGW-w64-runtime.txt \
 && echo $VERSION >$PREFIX/VERSION.txt
ENV PREFIX=${PREFIX}
CMD zip -q9Xr - $PREFIX
