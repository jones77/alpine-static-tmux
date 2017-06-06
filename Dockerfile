from alpine:edge

workdir /tmp
run echo "http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

run apk update && apk upgrade && \
    apk add ghc cabal make gcc musl-dev linux-headers bash file curl \
    bsd-compat-headers autoconf automake protobuf-dev zlib-dev openssl-dev g++ \
    upx

env dest_prefix /usr

# libevent
env libevent_version 2.0.22
env libevent_name libevent-$libevent_version-stable
run curl -L0 https://github.com/libevent/libevent/releases/download/release-$libevent_version-stable/libevent-$libevent_version-stable.tar.gz -o /tmp/$libevent_name.tar.gz
run tar xvzf /tmp/$libevent_name.tar.gz && \
    cd $libevent_name && \
    ./configure --prefix=$dest_prefix --disable-shared && \
    make && \
    make install && \
    rm -fr /tmp/$libevent_name.tar.gz /tmp/$libevent_name

# ncurses
env ncurses_version 6.0
env ncurses_name ncurses-$ncurses_version
run curl -LO http://ftp.gnu.org/gnu/ncurses/$ncurses_name.tar.gz -o /tmp/$ncurses_name.tar.gz && \
    tar xvzf /tmp/$ncurses_name.tar.gz && \
    cd $ncurses_name && \
    ./configure --prefix=$dest_prefix --without-cxx --without-cxx-bindings --enable-static && \
    make && \
    make install && \
    rm -fr /tmp/$ncurses_name.tar.gz /tmp/$ncurses_name

# et tmux
env tmux_version 2.4
env tmux_name tmux-$tmux_version
env tmux_url $tmux_name/$tmux_name
run curl -L0 https://github.com/tmux/tmux/releases/download/$tmux_version/$tmux_name.tar.gz -o /tmp/$tmux_name.tar.gz
run tar xvzf /tmp/$tmux_name.tar.gz && \
    cd $tmux_name && \
    ./configure --prefix=$dest_prefix CFLAGS="-I$dest_prefix/include -I$dest_prefix/include/ncurses" LDFLAGS="-static -L$dest_prefix/lib -L$dest_prefix/include/ncurses -L$dest_prefix/include" && \
    env CPPFLAGS="-I$dest_prefix/include -I$dest_prefix/include/ncurses" LDFLAGS="-static -L$dest_prefix/lib -L$dest_prefix/include/ncurses -L$dest_prefix/include" make && \
    make install && \
    rm -fr /tmp/$tmux_name.tar.gz /tmp/$tmux_name && \
    cp /usr/bin/tmux /usr/bin/tmux.stripped && \
    strip /usr/bin/tmux.stripped && \
    cp /usr/bin/tmux /usr/bin/tmux.upx && \
    cp /usr/bin/tmux.stripped /usr/bin/tmux.stripped.upx && \
    upx --best --ultra-brute /usr/bin/tmux.upx /usr/bin/tmux.stripped.upx

cmd ["bash"]
