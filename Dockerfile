FROM docker.io/library/alpine:3.16 as builder
ENV UPX_VERSION=devel \
    LDFLAGS=-static \
    CXXFLAGS_WERROR=
RUN apk add --no-cache build-base ucl-dev zlib-dev zlib-static git cmake
ARG rev
RUN git clone https://github.com/upx/upx.git /opt/src \
    && cd /opt/src && git checkout ${rev} \
    && git submodule update --init --recursive
RUN cmake -S /opt/src -B /opt/build && cmake --build /opt/build
RUN \
    mkdir -p /opt/staging/bin /opt/staging/share/doc && \
    /opt/build/upx --lzma -o /opt/staging/bin/upx /opt/build/upx && \
    cp /opt/src/COPYING /opt/staging/share/doc/upx-COPYING.txt && \
    cp /opt/src/LICENSE /opt/staging/share/doc/upx-LICENSE.txt

FROM scratch
ENTRYPOINT ["/bin/upx"]
LABEL org.opencontainers.image.source=https://github.com/jcaesar/upx-static-docker
ARG rev
LABEL de.liftm.upx-static-docker.rev=${rev}
COPY --from=builder /opt/staging/ /
