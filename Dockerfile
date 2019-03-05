FROM alpine:latest

MAINTAINER Zachary McGibbon

# Install required packages
RUN apk --update add --no-cache \
        bash                    \
        inotify-tools           \
        mosquitto-clients       \
        ca-certificates

# Get script and move to the right place
COPY ./*.sh /usr/local/bin/

# Make script executable
RUN chmod a+x /usr/local/bin/*.sh

# Start log monitoring
ENTRYPOINT ["/usr/local/bin/unifi-video-mqtt-multiple.sh"]
