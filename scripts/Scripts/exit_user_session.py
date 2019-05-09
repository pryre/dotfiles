#!/usr/bin/python3

import sys
import subprocess
import signal
from PyQt5 import QtCore
from PyQt5.QtWidgets import (QWidget, QPushButton, QLineEdit,
							 QInputDialog, QApplication, QDialog,
							 QVBoxLayout)

class ExitUserSessionPopup(QWidget):
	def __init__(self):
		super().__init__()
		self.init_ui()

	def init_ui(self):
		self.setWindowTitle('Exit User Session')
		#self.setWindowFlags(self.windowFlags() |
		#					QtCore.Qt.WindowStaysOnTopHint) # |
		#					#QtCore.Qt.FramelessWindowHint)
		self.setFocusPolicy(QtCore.Qt.StrongFocus)

		self.button_logout = QPushButton('Logout', self)
		self.button_logout.clicked.connect(self.do_logout)
		self.button_logout.setAutoDefault(True)

		self.button_suspend = QPushButton('Suspend', self)
		self.button_suspend.clicked.connect(self.do_suspend)
		self.button_suspend.setAutoDefault(True)

		self.button_reboot = QPushButton('Reboot', self)
		self.button_reboot.clicked.connect(self.do_reboot)
		self.button_reboot.setAutoDefault(True)

		self.button_shutdown = QPushButton('Shutdown', self)
		self.button_shutdown.clicked.connect(self.do_shutdown)
		self.button_shutdown.setAutoDefault(True)

		self.button_cancel = QPushButton('Cancel', self)
		self.button_cancel.clicked.connect(self.do_cancel)
		self.button_cancel.setAutoDefault(True)

		layout = QVBoxLayout()
		layout.addWidget(self.button_logout)
		layout.addWidget(self.button_suspend)
		layout.addWidget(self.button_reboot)
		layout.addWidget(self.button_shutdown)
		layout.addWidget(self.button_cancel)
		self.setLayout(layout)

		# Set an appropriate size
		self.setGeometry(0,0,160,240)

		# Move the window to be centred
		qtRectangle = self.frameGeometry()
		centerPoint = QApplication.desktop().availableGeometry().center()
		qtRectangle.moveCenter(centerPoint)
		self.move(qtRectangle.topLeft())

	def keyPressEvent(self, event):
		if event.key() == QtCore.Qt.Key_Escape:
			self.do_cancel()

	def do_logout(self):
		subprocess.run(["swaymsg", "exit"])
		self.do_cancel()

	def do_suspend(self):
		subprocess.run(["systemctl", "suspend"])
		self.do_cancel()

	def do_reboot(self):
		subprocess.run(["systemctl", "reboot"])
		self.do_cancel()

	def do_shutdown(self):
		subprocess.run(["systemctl", "poweroff"])
		self.do_cancel()

	def do_cancel(self):
		self.close()

def sigint_handler(signum,stack):
	"""handler for the SIGINT signal."""
	sys.stderr.write('\r')
	QApplication.quit()

if __name__ == '__main__':
	app = QApplication(sys.argv)

	window = ExitUserSessionPopup()
	window.show()

	signal.signal(signal.SIGINT, sigint_handler)

	timer = QtCore.QTimer()
	timer.timeout.connect(lambda: None)
	timer.start(100)

	sys.exit(app.exec_())
