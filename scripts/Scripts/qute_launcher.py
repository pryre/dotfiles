#!/usr/bin/python3

import sys
import os
import math
import configparser

from PyQt5 import QtCore
from PyQt5.QtWidgets import (QWidget, QToolButton, QLineEdit,
							 QInputDialog, QApplication, QDialog,
							 QVBoxLayout, QGroupBox, QGridLayout,
							 QScrollArea)
from PyQt5.QtGui import QIcon

class AppWidget():
	def __init__(self, app_path, use_symbolic):
		self.is_valid = False
		self.app_name = ""
		self.app_exec = ""
		self.app_icon = ""
		self.app_path = app_path
		self.use_symbolic = use_symbolic

		self.config = configparser.RawConfigParser()
		self.load_config(self.app_path)

		#print("loading: " + app_path)
		#f = open(app_path, 'r')

		#for l in f:
		#	if "Name" in l:
		#		print(l)
		#		self.app_name = self.get_param_arg(l)
		#	elif "Exec" in line:
		#		self.app_exec = self.get_param_arg(l)
		#	elif "Icon" in line:
		#		self.app_icon = self.get_param_arg(l)

		#f.close()

		#print(self.app_name)
		#print(self.app_exec)
		#print(self.app_icon)
	def load_config(self, app_path):
		#print("Loading: " +self.app_path)
		self.config.read(self.app_path)

		if 'Desktop Entry' in self.config:
			if 'Name' in self.config['Desktop Entry']:
				self.app_name = self.config['Desktop Entry']['Name']
			if 'Exec' in self.config['Desktop Entry']:
				self.app_exec = self.config['Desktop Entry']['Exec'].split('%')[0]
			if 'Icon' in self.config['Desktop Entry']:
				icon = self.config['Desktop Entry']['Icon']

				if self.use_symbolic and not ('/' in icon):
					icon += "-symbolic"

				self.app_icon = QIcon.fromTheme(icon)

		if self.app_name and self.app_exec:
			if not self.app_icon:
				icon = "content-loading"

				if self.use_symbolic:
					icon += "-symbolic"

				self.app_icon = QIcon.fromTheme(icon)

			self.valid = True
		else:
			print("Could not load: " + self.app_path)

	def appValid(self):
		return self.is_valid

	def appPath(self):
		return self.app_path

	def appName(self):
		return self.app_name

	def appExec(self):
		return self.app_exec

	def appIcon(self):
		return self.app_icon

	def runExec(self):
		os.system("swaymsg exec \'" + self.appExec() + "\'")

#class ExitUserSession(QDialog, QWidget):
class ExitUserSession(QWidget):
	def __init__(self, app_names):
		super().__init__()

		self.button_size = 90
		self.button_spacing = 10
		self.use_symbolic = True
		self.use_names = True

		self.app_names = app_names
		self.app_list = self.gen_app_widgets(app_names)

		self.init_ui()

		self.update_filter()

	def gen_app_widgets(self, app_names):
		apps = []

		for n in app_names:
			a = AppWidget(n,self.use_symbolic)
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
		self.app_search.returnPressed.connect(lambda: self.do_run(0))

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
			self.shortlist = [x for x in self.app_list if (ft in x.appName()) or (ft in x.appExec())]
		else:
			self.shortlist=self.app_list

		self.update_list_layout(self.shortlist)

	def update_list_layout(self, app_list):
		app_grid = QGridLayout()
		app_grid.setSpacing(self.button_spacing)
		usable_space = self.scrollarea.geometry().width() \
					 - self.scrollarea.verticalScrollBar().sizeHint().width() \
					 - self.button_spacing

		cols = int(usable_space / (self.button_spacing + self.button_size))

		icon_size = int(self.button_size * 2 / 3)

		for ind, app in enumerate(app_list):
			row = int(ind / cols)
			w = QToolButton()
			w.clicked.connect(lambda text=ind: self.do_run(text))
			w.setFixedSize(self.button_size, self.button_size)
			if self.use_names:
				w.setText(app.appName())
			w.setToolTip(app.appName())
			w.setIcon(app.appIcon())
			w.setIconSize(QtCore.QSize(icon_size, icon_size))
			w.setToolButtonStyle(QtCore.Qt.ToolButtonTextUnderIcon)
			w.setStyleSheet('QToolButton{border: 0px solid;}') #Remove boarder
			app_grid.addWidget(w, row, ind % cols)

		app_list_widget = QWidget()
		app_list_widget.setLayout(app_grid)
		self.scrollarea.setWidget(app_list_widget)

	def keyPressEvent(self, event):
		if event.key() == QtCore.Qt.Key_Escape:
			self.do_cancel()
		#elif event.key() == QtCore.Qt.Key_Enter:
		#	self.do_run()


	def do_run(self,ind):
		if len(self.shortlist) and (ind < len(self.shortlist)):
			self.shortlist[ind].runExec()
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
	app_names = []

	if not sys.stdin.isatty():
		for line in sys.stdin:
			app_names.append(line.strip('\n'))

	app = QApplication(sys.argv)

	window = ExitUserSession(sorted(app_names))
	if '-w' not in sys.argv:
		window.setWindowFlags(QtCore.Qt.Popup)
	window.setAttribute(QtCore.Qt.WA_QuitOnClose)
	window.show()
	window.app_search.setFocus()

	sys.exit(app.exec_())
