#!/bin/ash
#
# Launch the podman service/process if not previously launched. If parameters are not provided
# launch as a process. If parameters provided fork the podman as a service.

echo "$0"
TEST="$(/usr/bin/pgrep gitea)"
if [ $? -eq 1 ] ; then
 echo "---------- [ GIT SERVER(gitea) ] ----------"
 if [ -z "$ENTRYPOINT_PARAMS" ] ; then
  # /usr/bin/gitea --config /opt/gitea/app.ini --work-path /opt/gitea --custom-path /opt/gitea/customv web--port 8080
  /usr/bin/gitea --config /opt/gitea/app.ini --work-path /opt/gitea --custom-path /opt/gitea/custom web
 fi
 
#
#   /usr/bin/sudo /usr/sbin/nginx -g "daemon off;"
#  else
#   /usr/bin/sudo /usr/sbin/nginx
#  fi
fi



