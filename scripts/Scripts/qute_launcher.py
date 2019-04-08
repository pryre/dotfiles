#!/usr/bin/python3

import sys
import subprocess
from PyQt5 import QtCore
from PyQt5.QtWidgets import (QWidget, QPushButton, QLineEdit,
							 QInputDialog, QApplication, QDialog)

class ExitUserSession(QDialog, QWidget):
	def __init__(self):
		super().__init__()

		self.init_ui()

	def init_ui(self):
		#self.setWindowTitle( 'Qute Launhcer' )
		self.setGeometry( app.desktop().availableGeometry() )
		#self.setGeometry(300, 300, 120, 230)

		self.button_logout = QPushButton('Hide', self)
		self.button_logout.move(20, 20)
		self.button_logout.clicked.connect(self.do_hide)

	def keyPressEvent(self, event):
		if event.key() == QtCore.Qt.Key_Escape:
			self.do_cancel()

	def do_hide(self):
		self.hide()
		sleep(1)
		self.show()

	def do_cancel(self):
		self.close()

	def handle_sigint(self, sig, frame):
		print("SIGINT")
		self.do_cancel()

if __name__ == '__main__':
	app = QApplication(sys.argv)

	window = ExitUserSession()
	window.show()

	sys.exit(app.exec_())
