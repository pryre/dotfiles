function foxy_ros
	# set -g -x ROS_DOMAIN_ID 42
	set -g -x ROS_VERSION 2
	set -g -x ROS_PYTHON_VERSION 3
	set -g -x ROS_DISTRO foxy
	bass source /opt/ros2/foxy/setup.bash
	bass source ~/Workspace/ros2_dev_ws/install/local_setup.bash

	# Autocompletion
	# XXX: This could be taken out later after the following pull request
	# https://github.com/ros2/ros2cli/pull/326
	if test -e /opt/ros2/foxy/share/ros2cli/environment/ros2-argcomplete.fish
		echo "Looks like fish autocompletion is in! Update the function!"
	end
	# In the mean time, this seems to work
	if type register-python-argcomplete > /dev/null 2>&1
		eval "register-python-argcomplete --shell fish ros2 | source"
	end
end
