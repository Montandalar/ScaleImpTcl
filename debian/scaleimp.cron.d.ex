#
# Regular cron jobs for the scaleimp package
#
0 4	* * *	root	[ -x /usr/bin/scaleimp_maintenance ] && /usr/bin/scaleimp_maintenance
