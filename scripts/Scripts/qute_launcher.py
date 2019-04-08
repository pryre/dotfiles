#!/usr/bin/python3

import sys
import os
import math

from PyQt5 import QtCore
from PyQt5.QtWidgets import (QWidget, QPushButton, QLineEdit,
							 QInputDialog, QApplication, QDialog,
							 QVBoxLayout, QGroupBox, QGridLayout,
							 QScrollArea)
class AppWidget():
	def __init__(self,app_name):
		self.app_name = app_name
		#command
		#icon
		#self.widget = QPushButton(app_name)

class ExitUserSession(QDialog, QWidget):
	icon_size = 90
	icon_spacing = 10

	def __init__(self, app_names):
		super().__init__()

		self.app_names = app_names
		self.app_list = self.gen_app_widgets(app_names)

		self.init_ui()

		self.update_filter()

	def gen_app_widgets(self, app_names):
		apps = []

		for n in app_names:
			a = AppWidget(n)
			apps.append(a)

		return apps

	def init_ui(self):
		self.setWindowTitle( 'Qute Launhcer' )
		self.setGeometry( app.desktop().availableGeometry() )

		frame_size = self.geometry()
		w = frame_size.width()*2/3
		h = frame_size.height()*2/3
		px = frame_size.width()
		py = frame_size.height()

		self.app_search = QLineEdit(self)
		self.app_search.setFixedWidth(w)
		self.app_search.move(px/2 - w/2, py/6 - self.app_search.sizeHint().height()/2)
		self.app_search.textChanged.connect(self.update_filter)
		self.app_search.returnPressed.connect(self.do_run)

		self.scrollarea = QScrollArea(self)
		self.scrollarea.setFixedSize(w,h)
		self.scrollarea.move(px/2 - w/2, py/2 - h/3)
		self.scrollarea.setWidgetResizable(False)
		self.scrollarea.setAlignment(QtCore.Qt.AlignHCenter)

	def update_filter(self):
		self.shortlist = []
		ft = self.app_search.text()

		if ft:
			#shortlist = [x for x in self.app_list if all(a in x.app_name for a in ft)]
			self.shortlist = [x for x in self.app_list if ft in x.app_name]
		else:
			self.shortlist=self.app_list

		self.update_list_layout(self.shortlist)

	def update_list_layout(self, app_list):
		dt_app_list = app_list.copy()

		app_grid = QGridLayout()
		app_grid.setSpacing(self.icon_spacing)
		usable_space = self.scrollarea.geometry().width() \
					 - self.scrollarea.verticalScrollBar().sizeHint().width() \
					 - self.icon_spacing

		cols = int(usable_space / (self.icon_spacing + self.icon_size))

		for ind, app in enumerate(dt_app_list):
			row = int(ind / cols)
			w = QPushButton(app.app_name)
			w.setFixedSize(self.icon_size, self.icon_size)
			app_grid.addWidget(w, row, ind % cols)

		app_list_widget = QWidget()
		app_list_widget.setLayout(app_grid)
		self.scrollarea.setWidget(app_list_widget)

	def keyPressEvent(self, event):
		if event.key() == QtCore.Qt.Key_Escape:
			self.do_cancel()
		#elif event.key() == QtCore.Qt.Key_Enter:
		#	self.do_run()


	def do_run(self):
		print("do_run")

		if len(self.shortlist):
			os.system("swaymsg exec " + self.shortlist[0].app_name)
			self.do_cancel()

	#def do_refresh(self):
	#	pass

	#def do_hide(self):
	#	self.hide()
	#	sleep(1)
	#	self.show()

	def do_cancel(self):
		self.close()

if __name__ == '__main__':
	if not sys.stdin.isatty():
		app_names = []

		for line in sys.stdin:
			app_names.append(line.strip('\n'))

		app = QApplication(sys.argv)

		window = ExitUserSession(sorted(app_names))
		window.show()

		sys.exit(app.exec_())
	else:
		print("Provide list of applications on STDIN")