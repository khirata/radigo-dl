FROM golang:1.25-alpine AS builder

# Set timezone
ENV TZ "Asia/Tokyo"

# Install tools required to build the project
RUN apk add --no-cache ca-certificates \
  curl \
  ffmpeg \
  git \
  make \
  rtmpdump \
  tzdata

WORKDIR radigo
ADD https://github.com/yyoshiki41/radigo.git .

# Install deps
RUN make installdeps
# Build the project binary
RUN make build-4-docker

FROM ubuntu:24.04

RUN apt-get update && \
apt-get install -y --no-install-recommends wget apt-transport-https ca-certificates && \
    apt-get install -y --no-install-recommends wget apt-transport-https ca-certificates tzdata ffmpeg && \ 
    wget -qO /etc/apt/trusted.gpg.d/nordvpn_public.asc https://repo.nordvpn.com/gpg/nordvpn_public.asc && \
    echo "deb https://repo.nordvpn.com/deb/nordvpn/debian stable main" > /etc/apt/sources.list.d/nordvpn.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends nordvpn && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN ulimit -n 16384

COPY --from=builder /bin/radigo /usr/local/bin
COPY radigo-dl.sh /usr/local/bin

ENTRYPOINT /etc/init.d/nordvpn start && sleep 5 && /usr/local/bin/radigo-dl.sh "$@"
CMD bash
