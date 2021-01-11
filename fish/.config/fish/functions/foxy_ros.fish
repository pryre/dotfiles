function foxy_ros
     # set -g -x ROS_DOMAIN_ID 42
     set -g -x ROS_VERSION 2
     set -g -x ROS_PYTHON_VERSION 3
     set -g -x ROS_DISTRO foxy
     bass source /opt/ros2/foxy/setup.bash
     bass source ~/Workspace/ros2_dev_ws/install/local_setup.bash
end
