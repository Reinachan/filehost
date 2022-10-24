FROM alpine:latest AS alpine

ARG DOMAIN
ARG TUNNEL_UUID

RUN mkdir -p /etc/cloudflared
COPY config/ /etc/cloudflared

RUN sed -i "s/<domain.tld>/${DOMAIN}/g" /etc/cloudflared/config.yml
RUN sed -i "s/<tunnel-uuid>/${TUNNEL_UUID}/g" /etc/cloudflared/config.yml

FROM cloudflare/cloudflared:latest

COPY --from=alpine /etc/cloudflared /etc/cloudflared