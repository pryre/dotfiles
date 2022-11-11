function humble_ros
	# set -g -x ROS_DOMAIN_ID 42
	# set -g -x ROS_VERSION 2
	# set -g -x ROS_PYTHON_VERSION 3
 #    set -g -x ROS_DISTRO humble

	# XXX: Many GUI systems do not support wayland yet!
	#      Probably something to look into in the future
	set -x QT_QPA_PLATFORM xcb
	set -e GAZEBO_MODEL_PATH
	set -e GAZEBO_PLUGIN_PATH
	set -e GAZEBO_RESOURCE_PATH

	bass source /usr/share/gazebo/setup.bash
	bass source /opt/ros/humble/setup.bash

	set -x GAZEBO_MODEL_PATH $GAZEBO_MODEL_PATH:/usr/local/share/gazebo-11/models
	set -x GAZEBO_PLUGIN_PATH $GAZEBO_PLUGIN_PATH:/usr/local/lib/gazebo-11/plugins
	set -x GAZEBO_RESOURCE_PATH $GAZEBO_RESOURCE_PATH:/usr/local/share/gazebo-11

	echo "Sourced ros2 humble"

	if set -q argv[1]
		set workspace_dir ~/Workspace/ros2_$argv[1]_ws
		if test -e $workspace_dir/install/local_setup.bash
			bass source $workspace_dir/install/local_setup.bash
			echo "Sourced '$argv[1]' workspace"
			if test -e $workspace_dir/venv/bin/activate.fish
				source $workspace_dir/venv/bin/activate.fish
				echo "Enabled virtual environment"
			end

			cd $workspace_dir
		else
			echo "Could not find workspace: $argv[1] ($workspace_dir)"
		end
	end

	# Autocompletion
	# XXX: This could be taken out later after the following pull request
	# https://github.com/ros2/ros2cli/pull/326
	if test -e /opt/ros2/humble/share/ros2cli/environment/ros2-argcomplete.fish
		echo "Looks like fish autocompletion is in! Update the function!"
	end
	# In the mean time, this seems to work
	if type register-python-argcomplete > /dev/null 2>&1
		eval "register-python-argcomplete --shell fish ros2 | source"
	end
end
