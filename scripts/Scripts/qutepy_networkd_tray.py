#!/usr/bin/env python3

import sys, signal, os, subprocess, random
from types import FrameType
from typing import Any, cast
from PyQt5 import QtCore
from PyQt5.QtWidgets import QSystemTrayIcon, QApplication, QMenu, QAction #, QMessageBox, QSlider, QWidgetAction
from PyQt5.QtGui import QIcon
import dbus #type: ignore
import pyroute2 #type: ignore

# def run_detached_process(cmd: str, args: typing.List[str], pwd: str = ""):
# 	p = QtCore.QProcess()
# 	p.setStandardInputFile(p.nullDevice())
# 	p.setStandardOutputFile(p.nullDevice())
# 	p.setStandardErrorFile(p.nullDevice())
# 	p.startDetached(cmd, args, pwd)

def expand_list_vars(str_list: list[str]):
	return list(map(os.path.expandvars, str_list))

# class CustomTray(QSystemTrayIcon):
# 	scrolled = QtCore.pyqtSignal(int)

# 	def __init__(self, icon, parent=None):
# 		super().__init__(icon, parent)

# 		self.installEventFilter(self)

# 		#Create a signal to emit on scroll, argument is scroll direction (-1 or 1) amd amount

# 	def eventFilter(self, obj, event):
# 		if event.type() == QtCore.QEvent.Wheel:
# 			print("Scrolled!")
# 			#TODO: Should have a timer here to not catch all scrolls
# 			#TODO: Should use an enum
# 			self.scrolled.emit(event.angleDelta())
# 			return True

# 		#Event was not handled here
# 		return False
#
class NetworkStatus():
	def __init__(self, device:str, type:str, operational:str, setup:str, addresses:list[tuple[str,int]] = []):
		self.device:str = device
		self.type:str = type
		self.operational:str = operational
		self.setup:str = setup
		self.addresses:list[tuple[str,int]] = sorted(addresses)

	@staticmethod
	def from_interface(data: dict[str|int, Any]):
		device = data["ifname"] if "ifname" in data else ""
		type = ""
		if device.startswith("e"):
			type = "ether"
		elif device.startswith("w"):
			type = "wlan"

		op = data["operstate"] if "operstate" in data else "DOWN"
		operational = "carrier"
		if op == "UP":
			operational = "routable"
		elif op == "DOWN":
			operational = "no-carrier"

		setup = "unmanaged"
		state = data["state"] if "state" in data else ""
		if state == "up" and operational == "routable":
			setup = "configured"
		elif state == "up" and operational == "no-carrier":
			setup = "configuring"

		addresses:list[tuple[str,int]] = []
		if "ipaddr" in data:
			addresses = [x for x in data["ipaddr"]]

		return NetworkStatus(device, type, operational, setup, addresses)

	def __str__(self) -> str:
		c = [f"{a}/{b}" for a,b in self.addresses]
		return f"Status: [{self.device}, {self.type}, {self.operational}, {self.setup}] -- {c}"

	def __repr__(self) -> str:
		return str(self)

class NetworkdTrayApp():
	def __init__(self, app:QApplication, devices:list[str]|str):
		if isinstance(devices, list):
			self.devices = devices
		else:
			self.devices = [devices]

		# self.timer = QtCore.QTimer()
		# self.timer.timeout.connect(self.update_state)
		# self.timer.start(2000)

		self.dbus_notification_path = "org.freedesktop.Notifications"

		self.notify_title_last = ""
		self.notify_desc_last = ""
		self.notify_icon_name_last = ""
		self.notify_id = random.random()
		self.notify_bus:dbus.Interface|None = None

		self.commands:dict[str,list[str]] = dict()
		# self.commands["raise"] = expand_list_vars(["$HOME/Scripts/control_volume.sh", "raise"])
		# self.commands["lower"] = expand_list_vars(["$HOME/Scripts/control_volume.sh", "lower"])
		# self.commands["toggle-mute"] = expand_list_vars(["$HOME/Scripts/control_volume.sh", "toggle_mute"])

		self.tray_icon_none_name = "network-error-symbolic"
		self.tray_icon_wired_name = "network-wired-symbolic"
		self.tray_icon_wireless_name = "network-wireless-symbolic"
		self.tray_icon_unknown_name = "dialog-question-symbolic"

		self.tray_icon_none = QIcon.fromTheme(self.tray_icon_none_name)
		self.tray_icon_wired = QIcon.fromTheme(self.tray_icon_wired_name)
		self.tray_icon_wireless = QIcon.fromTheme(self.tray_icon_wireless_name)
		self.tray_icon_unknown = QIcon.fromTheme(self.tray_icon_unknown_name)

		self.tray = QSystemTrayIcon(self.tray_icon_none, app)
		# self.tray = CustomTray(self.tray_icon_mute, app)
		# self.tray_icon_is_mute = True

		self.menu = QMenu()
		self.top_menu = self.menu.addSection("Disconnected")
		self.action_restart_services = QAction(self.tray_icon_wired, "Restart Services")
		self.action_restart_services.triggered.connect(self.do_action_restart_services)
		self.menu.addAction(self.action_restart_services)
		self.menu.addSeparator()
		self.action_rescan_wifi = QAction(self.tray_icon_wireless, "Rescan Wi-Fi")
		self.action_rescan_wifi.triggered.connect(self.do_action_rescan_wifi)
		self.menu.addAction(self.action_rescan_wifi)
		self.menu.addSeparator()
		# self.action_volume_lower = self.menu.addAction("Lower Volume")
		# self.action_volume_lower.triggered.connect(self.do_action_volume_lower)
		# self.action_toggle_mute = self.menu.addAction("Toggle Mute")
		# self.action_toggle_mute.triggered.connect(self.do_action_toggle_muted)
		# self.menu.addSeparator()
		self.action_quit = self.menu.addAction("Quit")
		self.action_quit.triggered.connect(self.do_action_quit)
		self.tray.setContextMenu(self.menu)

		self.tray.activated.connect(self.do_action_clicked)
		# self.tray.scrolled.connect(self.do_action_scrolled)

		# Bind monitor
		self.ipdb = pyroute2.IPDB()
		self.ipdb.register_callback(self.network_changed) #type: ignore
		for key, val in cast(dict[Any,Any], self.ipdb.interfaces).items():
			if isinstance(key, str):
				self.network_changed(self.ipdb, val, None)

	def create_notifier(self):
		try:
			session = dbus.SessionBus()
			path_obj = session.get_object( # type: ignore
				self.dbus_notification_path,
				"/" + self.dbus_notification_path.replace(".", "/")
			)

			self.notify_bus = dbus.Interface(path_obj, self.dbus_notification_path)
		except dbus.DBusException:
			self.notify_bus = None

	def network_changed(self, ipdb:pyroute2.IPDB, msg:dict[str,Any], action:Any):
		if 'index' in msg:
			index = msg['index']
			if index in ipdb.interfaces:
				interface = ipdb.interfaces[index]
				# print(interface['ifname'])
				status = NetworkStatus.from_interface(interface)

				if status.device in self.devices:
					self.update_tray_info(status)


	# def update_state(self):
	# 	statuses:list[NetworkStatus] = []
	# 	result = subprocess.run(['networkctl', '--no-pager', '--no-legend', 'list'], stdout=subprocess.PIPE)
	# 	for l in result.stdout.splitlines():
	# 		r = l.split()
	# 		if r[1].decode('ASCII') in self.devices:
	# 			statuses.append(NetworkStatus(r[1].decode('ASCII'), r[2].decode('ASCII'), r[3].decode('ASCII'), r[4].decode('ASCII')))

	# 	self.update_tray_info(statuses)

	def update_tray_info(self, statuses:list[NetworkStatus]|NetworkStatus):
		if not isinstance(statuses, list):
			statuses = [statuses]

		# Get the list of devices in order or priority
		devices_sorted = sorted(statuses, key=lambda x: self.devices.index(x.device))
		notification_icon = self.tray_icon_none_name
		notification_text = ""

		is_connected = False
		op_ok = ['enslaved', 'carrier', 'routable']
		for _, dev in enumerate(devices_sorted):
			# print(dev)
			if (dev.operational in op_ok) and (dev.setup == 'configured'):
				# print("connected!")
				# Detect the device type and show icon
				addresses_list = ""
				for i, s in dev.addresses:
					addresses_list += f"\n\t{i}/{s}"

				if dev.type == 'ether':
					self.tray.setIcon(self.tray_icon_wired)
					notification_icon = self.tray_icon_wired_name
					notification_text = f"Ether ({dev.device}): {dev.type}"
					self.tray.setToolTip(f"{notification_text}\nConnections:{addresses_list}")
				elif dev.type == 'wlan':
					result = subprocess.run(['iw', dev.device, 'info'], stdout=subprocess.PIPE)
					ssid = ""
					channel = ""
					for l in result.stdout.splitlines():
						r = l.split()
						try:
							if r[0].decode() == "ssid":
								ssid = r[1].decode().strip()
							elif r[0].decode() == "channel":
								channel = l.decode().split("channel")[1].split(",")[0].strip()
						except IndexError:
							pass

					self.tray.setIcon(self.tray_icon_wireless)
					notification_icon = self.tray_icon_wireless_name
					notification_text = f"Wireless ({dev.device}): {ssid}"
					self.tray.setToolTip(f"{notification_text}\nChannel: {channel}\nConnections:{addresses_list}")
				else:
					self.tray.setIcon(self.tray_icon_unknown)
					notification_icon = self.tray_icon_unknown_name
					notification_text = "Unknown (%s): %s" % (dev.device, "Connected")
					self.tray.setToolTip(notification_text)

				# We have a good device at least
				is_connected = True
				break

		if not is_connected:
			# No connection was detected at all, so show as disconnected
			# print("disconnected")
			self.tray.setIcon(self.tray_icon_none)
			notification_icon = self.tray_icon_none_name
			self.tray.setToolTip(f"No connection for: {', '.join([d.device for d in devices_sorted])}")

		self.update_top_menu(self.tray.toolTip())
		self.update_notification(
			"Connected" if is_connected else "Disconnected",
			notification_text,
			notification_icon
		)

	def update_top_menu(self, text:str="Disconnected"):
		# self.menu.actions()[0].setText(text)
		self.top_menu.setText(text)

	def update_notification(self, title:str, desc:str, icon_name:str):
		if (self.notify_title_last != title) or (self.notify_desc_last != desc) or (self.notify_icon_name_last != icon_name):
			if self.notify_bus is None:
				self.create_notifier()

			try:
				if self.notify_bus is not None:
					self.notify_bus.Notify( # type: ignore
						"qutepy_networkd_tray",
						int(self.notify_id*0xFFFF),
						icon_name,
						title,
						desc,
						[],
						{"urgency": 1},
						3000
					)
			except:
				self.notify_bus = None

			self.notify_title_last = title
			self.notify_desc_last = desc
			self.notify_icon_name_last = icon_name


	def do_restart_specific_services(self, service_names:list[str]|str):
		if not isinstance(service_names, list):
			service_names = [service_names]

		enabled_services:list[str] = []
		for s in service_names:
			try:
				subprocess.run(['systemctl', 'is-enabled', '--quiet', s], check=True)
				enabled_services.append(s)
			except subprocess.CalledProcessError:
				print(f"Warning: '{s}' is not enabled, skipping")

		if len(enabled_services) > 0:
			try:
				cmd = ['systemctl', 'restart']
				cmd.extend(enabled_services)
				subprocess.run(cmd, check=True)
			except subprocess.CalledProcessError:
				services = ""
				for s in enabled_services:
					services += s
				print("Error: Some or all services could not be restarted: " + services)

		# for es in enabled_services:

		# try:
		# 	subprocess.run(['systemctl', 'is-enabled', '--quiet', service_name], check=True)
		# except subprocess.CalledProcessError as ex:
		# 	print("Error: unable to restart system service '" + service_name + "'")

	def do_action_restart_services(self):
		self.do_restart_specific_services(['systemd-networkd.service', 'systemd-resolved.service', 'iwd.service'])

	def do_action_rescan_wifi(self):
		subprocess.run(['notify-send.sh', 'Scanning WiFi...'])
		result = subprocess.run(['networkctl', '--no-pager', '--no-legend', 'list'], stdout=subprocess.PIPE)
		for l in result.stdout.splitlines():
			r = l.split()
			if r[2].decode('ASCII') == 'wlan':
				dev = r[1].decode('ASCII')
				print("Issuing Wi-Fi scan for '" + dev + "'")
				subprocess.run(['iwctl', 'station', dev, 'scan'])

	# def do_set_muted(self,is_mute):
 #        if is_mute:
 #            self.tray.setIcon(self.tray_icon_mute)
 #        else:
	# 		self.tray.setIcon(self.tray_icon_high)

	def do_action_clicked(self, reason:str):
		self.do_action_rescan_wifi()
	# 	if reason == QSystemTrayIcon.Trigger:
	# 		print("clicked")
	# 	# double clicking doesn't seem to work
	# 	# elif reason == QSystemTrayIcon.DoubleClick:
	# 		# print("double clicked")
	# 	elif reason == QSystemTrayIcon.MiddleClick:
	# 		# print("middle clicked")
	# 		self.do_action_toggle_muted()
	# 	else:
	# 		pass

	# def do_action_scrolled(self,direction):
	# 	if direction > 0:
	# 		self.do_action_volume_raise()
	# 	elif direction < 0:
	# 		self.do_action_volume_lower()
	# 	else:
	# 		print("Weird scroll detected")

	# def do_action_open_mixer(self):
	# 	# os.system("swaymsg exec '" + self.commands["mixer"] + "'")
	# 	self.do_action_run("mixer")

	# def do_action_toggle_muted(self):
	# 	self.tray_icon_is_mute = not self.tray_icon_is_mute
	# 	self.do_set_muted(self.tray_icon_is_mute)

	#	self.do_action_run("toggle-mute")

	# def do_action_volume_raise(self):
	# 	self.do_action_run("raise")

	# def do_action_volume_lower(self):
	# 	self.do_action_run("lower")

	# def do_action_run(self, cmd):
	# 	 run_detached_process(self.commands[cmd][0], self.commands[cmd][1:])

	def show_in_tray_when_available(self):
		"""Show status icon when system tray is available

		If available, show icon, otherwise, set a timer to check back later.
		This is a workaround for https://bugreports.qt.io/browse/QTBUG-61898
		"""
		if QSystemTrayIcon.isSystemTrayAvailable():
			self.tray.show()
		else:
			QtCore.QTimer.singleShot(1000, self.show_in_tray_when_available)

	def do_action_quit(self):
		QApplication.quit()

def sigint_handler(signum:int,stack:FrameType|None):
	"""handler for the SIGINT signal."""
	print("Closing application")
	sys.stderr.write('\n')
	QApplication.quit()

if __name__ == '__main__':
	devices:list[str] = []
	if len(sys.argv) >= 2:
		devices = sys.argv[1:]
	else:
		print("Error: No device specified")
		sys.exit(1)

	# Need to wait a moment in case the rest of the GUI is still starting
	# (waybar seems to not register tray apps in the first few moments)
	try:
		app = QApplication(sys.argv)
	except KeyboardInterrupt:
		exit(0)

	# if not QSystemTrayIcon.isSystemTrayAvailable():
	# 	print("Waiting for system tray")
	# while not QSystemTrayIcon.isSystemTrayAvailable():
	# 	time.sleep(1)

	print("Starting Quetpy Networkd Tray")
	tray = NetworkdTrayApp(app, devices)

	# SIGINT handling for smooth exit
	signal.signal(signal.SIGINT, sigint_handler)
	signal.signal(signal.SIGINT, signal.SIG_DFL)

	# timer = QtCore.QTimer()
	# timer.timeout.connect(lambda: None)
	# timer.start(100)

	tray.show_in_tray_when_available()

	sys.exit(app.exec())
