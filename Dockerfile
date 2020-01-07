FROM alpine:3.11 as builder
ENV UPX_VERSION=devel \
    LDFLAGS=-static
RUN apk add --no-cache build-base ucl-dev zlib-dev zlib-static git
RUN git clone --depth 1 --recursive -b devel https://github.com/upx/upx.git /upx
RUN cd /upx/src && \
    make -j$(nproc) upx.out CHECK_WHITESPACE= && \
    mkdir -p /opt/staging/bin /opt/staging/share/doc && \
    /upx/src/upx.out --lzma -o /opt/staging/bin/upx /upx/src/upx.out && \
    cp /upx/COPYING /opt/staging/share/doc/upx-COPYING.txt && \
    cp /upx/LICENSE /opt/staging/share/doc/upx-LICENSE.txt

FROM scratch
ENTRYPOINT ["/bin/upx"]
COPY --from=builder /opt/staging/ /
