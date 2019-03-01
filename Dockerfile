FROM alpine:latest

MAINTAINER Zachary McGibbon

# Install required packages
RUN apk --update add --no-cache \
        bash                    \
        inotify-tools           \
        mosquitto-clients

# Get script and move to the right place
COPY ./unifi-video-mqtt.sh /usr/local/bin

# Make script executable
RUN chmod a+x /usr/local/bin/unifi-video-mqtt.sh

# Make unifi log directory
RUN mkdir -p /var/log/unifi-video

# Start log monitoring
ENTRYPOINT ["/usr/local/bin/unifi-video-mqtt.sh"]
