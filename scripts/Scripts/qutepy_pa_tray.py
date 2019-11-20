#!/usr/bin/env python3

import sys, signal, os
from PyQt5 import QtGui, QtCore
from PyQt5.QtWidgets import QSystemTrayIcon, QApplication, QMenu
from PyQt5.QtGui import QIcon

class PATrayApp():
	def __init__(self, app):
		self.mixer_command = "pavucontrol"
		self.tray_icon_high = QIcon.fromTheme("audio-volume-high-symbolic")
		self.tray_icon_mute = QIcon.fromTheme("audio-volume-low-symbolic")

		self.tray = QSystemTrayIcon(self.tray_icon_mute, app)
		self.tray_icon_is_mute = True

		self.menu = QMenu()
		self.action_open_mixer = self.menu.addAction("Open Mixer")
		self.action_open_mixer.triggered.connect(self.do_action_open_mixer)
		self.action_toggle_mute = self.menu.addAction("Toggle Mute")
		self.action_toggle_mute.triggered.connect(self.do_action_toggle_muted)
		self.action_quit = self.menu.addAction("Quit")
		self.action_quit.triggered.connect(self.do_action_quit)
		self.tray.setContextMenu(self.menu)

		# self.tray.setToolTip("")


		self.tray.activated.connect(self.do_action_clicked)

	def show(self):
		self.tray.show()

	def do_set_muted(self,is_mute):
		if is_mute:
			self.tray.setIcon(self.tray_icon_mute)
		else:
			self.tray.setIcon(self.tray_icon_high)

	def do_action_clicked(self,reason):
		if reason == QSystemTrayIcon.Trigger:
			print("clicked")
		# double clicking doesn't seem to work
		# elif reason == QSystemTrayIcon.DoubleClick:
			# print("double clicked")
		elif reason == QSystemTrayIcon.MiddleClick:
			print("middle clicked")
		else:
			pass

	def do_action_open_mixer(self):
		os.system("swaymsg exec '" + self.mixer_command + "'")

	def do_action_quit(self):
		QApplication.quit()

	def do_action_toggle_muted(self):
		self.tray_icon_is_mute = not self.tray_icon_is_mute
		self.do_set_muted(self.tray_icon_is_mute)

def sigint_handler(signum,stack):
	"""handler for the SIGINT signal."""
	sys.stderr.write('\r')
	QApplication.quit()

if __name__ == '__main__':
	app = QApplication(sys.argv)
	pata = PATrayApp(app)

	# SIGINT handling for smooth exit
	signal.signal(signal.SIGINT, sigint_handler)

	timer = QtCore.QTimer()
	timer.timeout.connect(lambda: None)
	timer.start(100)

	pata.show()
	sys.exit(app.exec_())
