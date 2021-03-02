#!/usr/bin/env python3

import sys, signal, os, typing, subprocess, time
from PyQt5 import QtGui, QtCore
from PyQt5.QtWidgets import QSystemTrayIcon, QApplication, QMenu, QAction #, QMessageBox, QSlider, QWidgetAction
from PyQt5.QtGui import QIcon

# def run_detached_process(cmd: str, args: typing.List[str], pwd: str = ""):
# 	p = QtCore.QProcess()
# 	p.setStandardInputFile(p.nullDevice())
# 	p.setStandardOutputFile(p.nullDevice())
# 	p.setStandardErrorFile(p.nullDevice())
# 	p.startDetached(cmd, args, pwd)

def expand_list_vars(str_list: typing.List[str]):
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
	def __init__(self, device, type, operational, setup):
		self.device = device
		self.type = type
		self.operational = operational
		self.setup = setup

class NetworkdTrayApp():
	def __init__(self, app, devices):
		if isinstance(devices, list):
			self.devices = devices
		else:
			self.devices = [devices]

		self.timer = QtCore.QTimer()
		self.timer.timeout.connect(self.update_state)
		self.timer.start(2000)

		self.commands = dict()
		# self.commands["mixer"] = expand_list_vars(["pavucontrol-qt"])
		# self.commands["raise"] = expand_list_vars(["$HOME/Scripts/control_volume.sh", "raise"])
		# self.commands["lower"] = expand_list_vars(["$HOME/Scripts/control_volume.sh", "lower"])
		# self.commands["toggle-mute"] = expand_list_vars(["$HOME/Scripts/control_volume.sh", "toggle_mute"])

		self.tray_icon_none = QIcon.fromTheme("network-error-symbolic")
		self.tray_icon_wired = QIcon.fromTheme("network-wired-symbolic")
		self.tray_icon_wireless = QIcon.fromTheme("network-wireless-symbolic")
		self.tray_icon_unknown = QIcon.fromTheme("dialog-question-symbolic")

		self.tray = QSystemTrayIcon(self.tray_icon_none, app)
		# self.tray = CustomTray(self.tray_icon_mute, app)
		# self.tray_icon_is_mute = True

		self.menu = QMenu()
		self.action_restart_services = QAction(self.tray_icon_wired, "Restart Services")
		self.action_restart_services.triggered.connect(self.do_action_restart_servies)
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

		# self.tray.activated.connect(self.do_action_clicked)
		# self.tray.scrolled.connect(self.do_action_scrolled)

		# Perform one update imidiately
		self.update_state()

	def update_state(self):
		statuses = []
		result = subprocess.run(['networkctl', '--no-pager', '--no-legend', 'list'], stdout=subprocess.PIPE)
		for l in result.stdout.splitlines():
			r = l.split()
			if r[1].decode('ASCII') in self.devices:
				statuses.append(NetworkStatus(r[1].decode('ASCII'), r[2].decode('ASCII'), r[3].decode('ASCII'), r[4].decode('ASCII')))

		self.update_tray_info(statuses)

	def update_tray_info(self, statuses):
		if not isinstance(statuses, list):
			status = [statuses]

		# Get the list of devices in order or priority
		devices_sorted = sorted(statuses, key=lambda x: self.devices.index(x.device))

		last_index = len(devices_sorted) - 1

		for i, dev in enumerate(devices_sorted):
			op_ok = ['enslaved', 'carrier', 'routable']
			if (dev.operational in op_ok) and (dev.setup == 'configured'):
				# print("connected!")
				# Detect the device type and show icon
				if dev.type == 'ether':
					self.tray.setIcon(self.tray_icon_wired)
					self.tray.setToolTip("Ether (%s): %s" % (dev.device, ""))
				elif dev.type == 'wlan':
					result = subprocess.run(['iw', dev.device, 'info'], stdout=subprocess.PIPE)
					ssid = ""
					channel = ""
					for l in result.stdout.splitlines():
						r = l.split()
						try:
							if r[0] == "ssid":
								ssid = r[1]
							elif r[0] == "channel":
								channel = l.split("channel")[1].split(',')[0]
						except IndexError:
							pass

					self.tray.setIcon(self.tray_icon_wireless)
					self.tray.setToolTip("Wireless (%s): %s - %s" % (dev.device, ssid, channel))
				else:
					self.tray.setIcon(self.tray_icon_unknown)
					self.tray.setToolTip("Unknown (%s): %s" % (dev.device, "Connected"))
			break

			if i == last_index:
				# No connection was detected at all, so show as disconnected
				# print("disconnected")
				self.tray.setIcon(self.tray_icon_none)
				self.tray.setToolTip("Disconnected")

	# def do_get_info_string(self, status):
	# 	if dev.type == 'ether':
	# 		pass
	# 		# self.tray.setIcon(self.tray_icon_wired)
	# 	elif dev.type == 'wlan':
	# 		pass
	# 		# self.tray.setIcon(self.tray_icon_wireless)
	# 	else:
	# 		pass
	# 		# self.tray.setIcon(self.tray_icon_unknown)

	def do_restart_specific_services(self, service_names):
		if not isinstance(service_names, list):
			service_names = [service_names]

		enabled_services = []
		for s in service_names:
			try:
				subprocess.run(['systemctl', 'is-enabled', '--quiet', s], check=True)
				enabled_services.append(s)
			except subprocess.CalledProcessError as ex:
				print("Warning: '" + service_name + "' is not enabled, skipping")

		if len(enabled_services) > 0:
			try:
				cmd = ['systemctl', 'restart']
				cmd.extend(enabled_services)
				subprocess.run(cmd, check=True)
			except subprocess.CalledProcessError as ex:
				services = ""
				for s in enabled_services:
					services += s
				print("Error: Some or all services could not be restarted: " + services)

		# for es in enabled_services:

		# try:
		# 	subprocess.run(['systemctl', 'is-enabled', '--quiet', service_name], check=True)
		# except subprocess.CalledProcessError as ex:
		# 	print("Error: unable to restart system service '" + service_name + "'")

	def do_action_restart_servies(self):
		self.do_restart_specific_services(['systemd-networkd.service', 'systemd-resolved.service', 'iwd.service'])

	def do_action_rescan_wifi(self):
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

	# def do_action_clicked(self,reason):
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

def sigint_handler(signum,stack):
	"""handler for the SIGINT signal."""
	sys.stderr.write('\r')
	QApplication.quit()

if __name__ == '__main__':
	devices = []
	if len(sys.argv) >= 2:
		devices = sys.argv[1:]
	else:
		print("Error: No device specified")
		sys.exit(1)

	# Need to wait a moment in case the rest of the GUI is still starting
	# (waybar seems to not register tray apps in the first few moments)
	time.sleep(1)

	app = QApplication(sys.argv)

	# if not QSystemTrayIcon.isSystemTrayAvailable():
	# 	print("Waiting for system tray")
	# while not QSystemTrayIcon.isSystemTrayAvailable():
	# 	time.sleep(1)

	print("Starting Quetpy Networkd Tray")
	ndtp = NetworkdTrayApp(app, devices)

	# SIGINT handling for smooth exit
	signal.signal(signal.SIGINT, sigint_handler)

	timer = QtCore.QTimer()
	timer.timeout.connect(lambda: None)
	timer.start(100)

	ndtp.show_in_tray_when_available()

	sys.exit(app.exec())
