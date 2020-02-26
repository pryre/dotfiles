function disros
	# Setup for distributed ROS
	set -x ROS_IP (hostname -I)
	echo "Identifying as: $ROS_IP"

	if test (count $argv) -eq 1
		set -x ROS_MASTER_URI="http://$argv[0]:11311"
		echo "Connecting to: $ROS_MASTER_URI"
	end
end
