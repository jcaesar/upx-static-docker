FROM docker.io/library/alpine:3.16 as builder
ENV UPX_VERSION=devel \
    LDFLAGS=-static \
    CXXFLAGS_WERROR=
RUN apk add --no-cache build-base ucl-dev zlib-dev zlib-static git
ARG rev
RUN git clone https://github.com/upx/upx.git /upx \
    && cd /upx && git checkout ${rev} \
    && git submodule update --init --recursive
RUN cd /upx/src && \
    make -j$(nproc) upx.out CHECK_WHITESPACE= && \
    mkdir -p /opt/staging/bin /opt/staging/share/doc && \
    /upx/src/upx.out --lzma -o /opt/staging/bin/upx /upx/src/upx.out && \
    cp /upx/COPYING /opt/staging/share/doc/upx-COPYING.txt && \
    cp /upx/LICENSE /opt/staging/share/doc/upx-LICENSE.txt

FROM scratch
ENTRYPOINT ["/bin/upx"]
LABEL org.opencontainers.image.source=https://github.com/jcaesar/upx-static-docker
ARG rev
LABEL de.liftm.upx-static-docker.rev=${rev}
COPY --from=builder /opt/staging/ /
