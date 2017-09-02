#!/usr/bin/env bash

VARNISHD_PID=0

exit_handler()
{
    echo "Shutdown signal received"
    if [ $VARNISH_LOG -eq 1 ]; then
        echo "Shutdown varnishncsa"
        killall -SIGTERM varnishncsa
    fi
    if [ $VARNISHD_PID -ne 0 ]; then
        echo "Shutdown varnishd"
        kill -SIGTERM "$VARNISHD_PID"
        wait "$VARNISHD_PID"
    fi
	exit
}

trap 'exit_handler' SIGHUP SIGINT SIGQUIT SIGTERM

if [ $VARNISH_LOG -eq 1 ]; then
    echo "Starting varnishncsa"
    /usr/bin/varnishncsa -D -a -F "$VARNISH_LOG_FORMAT" -w /var/log/varnish/access.log 2>&1 &
fi

/usr/sbin/varnishd -F -a :80 -T :6082 -f /etc/varnish/default.vcl -s malloc,${VARNISH_MALLOC} 2>&1 &

VARNISHD_PID=$!
wait "$VARNISHD_PID"
