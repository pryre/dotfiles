#!/usr/bin/env python3

import sys, signal, os, typing, subprocess
from PyQt5 import QtGui, QtCore
from PyQt5.QtWidgets import QSystemTrayIcon, QApplication, QMenu #, QMessageBox, QSlider, QWidgetAction
from PyQt5.QtGui import QIcon

def run_detached_process(cmd: str, args: typing.List[str], pwd: str = ""):
	p = QtCore.QProcess()
	p.setStandardInputFile(p.nullDevice())
	p.setStandardOutputFile(p.nullDevice())
	p.setStandardErrorFile(p.nullDevice())
	p.startDetached(cmd, args, pwd)

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
	def __init__(self, app, argv):
		self.devices = []
		if len(argv) >= 2:
			self.devices = argv[1:]
		else:
			print("Error: No device specified")
			self.do_action_quit()

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
		# self.action_open_mixer = self.menu.addAction("Open Mixer")
		# self.action_open_mixer.triggered.connect(self.do_action_open_mixer)
		# self.menu.addSeparator()
		# self.action_volume_raise = self.menu.addAction("Raise Volume")
		# self.action_volume_raise.triggered.connect(self.do_action_volume_raise)
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

	def show(self):
		self.tray.show()

	def update_state(self):
		status = []
		result = subprocess.run(['networkctl', '--no-pager', '--no-legend', 'list'], stdout=subprocess.PIPE)
		for l in result.stdout.splitlines():
			r = l.split()
			if r[1].decode('ASCII') in self.devices:
				status.append(NetworkStatus(r[1].decode('ASCII'), r[2].decode('ASCII'), r[3].decode('ASCII'), r[4].decode('ASCII')))

		self.update_icon(status)

	def update_icon(self, status):
		if not isinstance(status, list):
			status = [status]

		# Get the list of devices in order or priority
		devices_sorted = sorted(status, key=lambda x: self.devices.index(x.device))

		last_index = len(devices_sorted) - 1

		for i, dev in enumerate(devices_sorted):
			if ((dev.operational == 'enslaved') or (dev.operational == 'carrier')) and (dev.setup == 'configured'):
				# print("connected!")
				# Detect the device type and show icon
				if dev.type == 'ether':
					self.tray.setIcon(self.tray_icon_wired)
				elif dev.type == 'wlan':
					self.tray.setIcon(self.tray_icon_wireless)
				else:
					self.tray.setIcon(self.tray_icon_unknown)

				break

			if i == last_index:
				# No connection was detected at all, so show as disconnected
				print("disconnected")
				self.tray.icon = self.tray_icon_none

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

	def do_action_run(self, cmd):
		run_detached_process(self.commands[cmd][0], self.commands[cmd][1:])

	def do_action_quit(self):
		QApplication.quit()

def sigint_handler(signum,stack):
	"""handler for the SIGINT signal."""
	sys.stderr.write('\r')
	QApplication.quit()

if __name__ == '__main__':
	app = QApplication(sys.argv)
	pata = NetworkdTrayApp(app, sys.argv)

	# SIGINT handling for smooth exit
	signal.signal(signal.SIGINT, sigint_handler)

	timer = QtCore.QTimer()
	timer.timeout.connect(lambda: None)
	timer.start(100)

	pata.show()
	sys.exit(app.exec_())
