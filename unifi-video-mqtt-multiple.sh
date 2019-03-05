#!/bin/bash

# Unifi Video Vars
UNIFI_MOTION_LOG="${UNIFI_MOTION_LOG:-motion.log}"

# MQTT Vars
MQTT_SERVER="${MQTT_SERVER:-127.0.0.1}"
MQTT_PORT="${MQTT_PORT:-1883}"
MQTT_TOPIC_BASE="${MQTT_TOPIC_BASE:-camera/motion}"

# MQTT User/Pass Vars, only use if needed
MQTT_USER="${MQTT_USER:-}"
MQTT_PASS="${MQTT_PASS:-}"

MQTT_ID="${MQTT_ID:unifi-video}"

# --------------------------------------------------------------------------------
# Script starts here

# Check if a username/password is defined and if so create the vars to pass to the cli
if [[ -n "$MQTT_USER" && -n "$MQTT_PASS" ]]; then
  MQTT_USER_PASS="-u $MQTT_USER -P $MQTT_PASS"
else
  MQTT_USER_PASS=""
fi

# Check if a MQTT_ID has been defined, needed for newer versions of Home Assistant
if [[ -n "$MQTT_ID" ]]; then
  MQTT_ID_OPT="-I $MQTT_ID"
else
  MQTT_ID_OPT=""
fi

echo "Watching $UNIFI_MOTION_LOG"
while inotifywait -e modify $UNIFI_MOTION_LOG; do
	source <(tail -n1 $UNIFI_MOTION_LOG | sed -rn 's/(.*)type:([^\ ]*)(.*)\((.*)\).*/LAST_EVENT=\2\nCAM_NAME="\4"/p; t; s/.*\((.*)\).*/LAST_EVENT=stop CAM_NAME="\1"/p')
	echo "Motion on '$CAM_NAME' $LAST_EVENT"

	MOTION_STATE="OFF"
	if [[ $LAST_EVENT == "start" ]]; then
		MOTION_STATE="ON"
	fi

	mosquitto_pub -h $MQTT_SERVER -p $MQTT_PORT $MQTT_USER_PASS --capath /etc/ssl/certs -r $MQTT_ID_OPT -t "$MQTT_TOPIC_BASE/$CAM_NAME" -m $MOTION_STATE &
done
