#!/usr/bin/python3

import sys
import subprocess
from PyQt5.QtWidgets import (QWidget, QPushButton, QLineEdit,
							 QInputDialog, QApplication, QDialog)

class MyPopup(QDialog):
	def __init__(self):
		super().__init__()
		self.init_ui()

class ExitUserSession(QDialog, QWidget):
	def __init__(self):
		super().__init__()
		self.init_ui()

	def init_ui(self):
		self.setWindowTitle('Exit Session')
		self.setGeometry(300, 300, 120, 150)

		self.button_logout = QPushButton('Logout', self)
		self.button_logout.move(20, 20)
		self.button_logout.clicked.connect(self.do_logout)

		self.button_shutdown = QPushButton('Shutdown', self)
		self.button_shutdown.move(20, 60)
		self.button_shutdown.clicked.connect(self.do_shutdown)

		self.button_cancel = QPushButton('Cancel', self)
		self.button_cancel.move(20, 100)
		self.button_cancel.clicked.connect(self.do_cancel)

	def do_logout(self):
		subprocess.run(["swaymsg", "exit"])

	def do_shutdown(self):
		subprocess.run(["systemctl", "poweroff"])

	def do_cancel(self):
		self.close()

if __name__ == '__main__':
	app = QApplication(sys.argv)

	window = ExitUserSession()
	window.show()

	sys.exit(app.exec_())
