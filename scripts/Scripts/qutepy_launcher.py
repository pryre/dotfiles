#!/usr/bin/python3

import sys
import os
import math
import configparser
import signal

from PyQt5 import QtCore
from PyQt5.QtGui import QIcon
from PyQt5.QtWidgets import (QWidget, QToolButton, QLineEdit,
							 QInputDialog, QApplication, QDialog,
							 QVBoxLayout, QGridLayout, QSizePolicy,
							 QScrollArea, QBoxLayout)

class AppArgs():
	hold_window = False
	use_fullscreen = False
	use_popup = False
	use_symbolic = False
	use_transparency = False
	use_names = False
	button_size = 90
	button_spacing = 10
	frame_size_x = 0
	frame_size_y = 0

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

	def load_config(self, app_path):
		self.config.read(self.app_path)

		icon = ""

		if 'Desktop Entry' in self.config:
			if 'Name' in self.config['Desktop Entry']:
				self.app_name = self.config['Desktop Entry']['Name']
			if 'Exec' in self.config['Desktop Entry']:
				self.app_exec = self.config['Desktop Entry']['Exec'].split('%')[0]
			if 'Icon' in self.config['Desktop Entry']:
				icon = self.config['Desktop Entry']['Icon']

				if icon and self.use_symbolic and not ( ('/' in icon) or ('.' in icon)):
					icon += "-symbolic"

		if self.app_name and self.app_exec:
			fallback_icon = "content-loading-symbolic"
			self.app_icon = QIcon.fromTheme(icon, QIcon.fromTheme(fallback_icon))

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

class FrameWidget(QWidget):
	resized = QtCore.pyqtSignal()

	def __init__(self):
		super().__init__()

	def resizeEvent(self, event):
		self.resized.emit()
		return QWidget.resizeEvent(self,event)

class ExitUserSession(QWidget):
	def __init__(self, app_names, app_args):
		super().__init__()

		self.app_args = app_args
		self.stay_alive = False

		self.app_names = app_names
		QIcon.setFallbackSearchPaths(["/usr/share/pixmaps"])
		self.app_list = self.gen_app_widgets(app_names)
		self.shortlist = self.app_list

		self.init_ui()

		#self.update_filter()

	def gen_app_widgets(self, app_names):
		apps = []

		for n in app_names:
			a = AppWidget(n,self.app_args.use_symbolic)
			apps.append(a)

		return apps

	def init_ui(self):
		self.setWindowTitle( 'Qute Launcher' )

		self.frame_margin = 2
		#self.frame_offset_x = 0
		#self.frame_offset_y = 0

		if (self.app_args.frame_size_x == 0) or (self.app_args.frame_size_y == 0):
			self.app_args.frame_size_x = 800
			self.app_args.frame_size_y = 600

		if not self.app_args.use_fullscreen:
			self.setWindowFlags(QtCore.Qt.FramelessWindowHint)

			if self.app_args.use_popup:
				print("Popup mode")
				self.setWindowFlags(self.windowFlags() | QtCore.Qt.Dialog)

				self.setGeometry( QtCore.QRect(0,0,self.frame_size_x,self.frame_size_y) )
				qtRectangle = self.frameGeometry()
				centerPoint = QApplication.desktop().availableGeometry().center()
				qtRectangle.moveCenter(centerPoint)
				self.move(qtRectangle.topLeft())

		if self.app_args.use_transparency:
			self.setAttribute(QtCore.Qt.WA_NoSystemBackground)
			self.setAttribute(QtCore.Qt.WA_TranslucentBackground);

		# Install an event filter to hide on loss of focus
		if not self.app_args.hold_window:
			self.installEventFilter(self)

		self.frame_widget = FrameWidget()
		window_layout = QVBoxLayout()
		window_layout.setAlignment(QtCore.Qt.AlignHCenter)
		window_layout.addWidget(self.frame_widget)
		self.setLayout(window_layout)

		# Set frame widget to stay at same size if fullscreen is given
		if self.app_args.use_fullscreen:
			self.frame_widget.setFixedSize(self.app_args.frame_size_x, self.app_args.frame_size_y)

		self.app_search = QLineEdit(self)
		self.app_search.textChanged.connect(self.update_filter)
		self.app_search.returnPressed.connect(lambda: self.do_run(0))

		self.scrollarea = QScrollArea(self)
		self.scrollarea.setAlignment(QtCore.Qt.AlignHCenter)
		self.scrollarea.setWidgetResizable(False)

		frame_layout = QVBoxLayout()
		frame_layout.addWidget(self.app_search)
		frame_layout.addWidget(self.scrollarea)
		self.frame_widget.setLayout(frame_layout)
		self.frame_widget.resized.connect(lambda text=self.shortlist: self.update_list_layout(text))

	def eventFilter(self, obj, event):
		# See if we lose focus
		if event.type() == QtCore.QEvent.WindowDeactivate:
			self.do_cancel()
			return True
		#See if we have been resized
		#elif event.type() == QtCore.QEvent.GraphicsSceneResize:
		#	self.do_rearrange()
		#	return True

		#Event was not handled here
		return False

	def update_filter(self):
		ft = self.app_search.text()

		if ft:
			#shortlist = [x for x in self.app_list if all(a in x.app_name for a in ft)]
			self.shortlist = [x for x in self.app_list if (ft in x.appName()) or (ft in x.appExec())]
		else:
			self.shortlist=self.app_list

		self.shortlist.sort(key=lambda x: x.app_name.lower())

		self.update_list_layout(self.shortlist)

	def update_list_layout(self, app_list):
		app_grid = QGridLayout()
		app_grid.setSpacing(self.app_args.button_spacing)
		usable_space = self.scrollarea.geometry().width() \
					 - self.scrollarea.verticalScrollBar().sizeHint().width() \
					 - self.app_args.button_spacing
		cols = int(usable_space / (self.app_args.button_spacing + self.app_args.button_size))
		if cols < 1:
			cols = 1

		icon_size = int(self.app_args.button_size * 2 / 3)

		for ind, app in enumerate(app_list):
			row = int(ind / cols)
			w = QToolButton()
			w.clicked.connect(lambda arg, text=ind: self.do_run(text))
			w.setFixedSize(self.app_args.button_size, self.app_args.button_size)
			if self.app_args.use_names:
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

	def bring_forward(self):
		self.show()

		# For some reason window does not redraw properly
		# unless show() is called first
		if self.app_args.use_fullscreen:
			self.showFullScreen()

		self.app_search.clear()
		self.app_search.setFocus()

		self.update_filter()

	def set_is_daemon(self, is_d):
		if not is_d:
			self.setAttribute(QtCore.Qt.WA_QuitOnClose)

		self.stay_alive = is_d

	def sigusr_handler(self, signum, stack):
		print("Received user signal")
		self.bring_forward()

	def do_cancel(self):
		if self.stay_alive:
			self.hide()
		else:
			self.close()

def sigint_handler(signum,stack):
	"""handler for the SIGINT signal."""
	sys.stderr.write('\r')
	QApplication.quit()

def send_parent_sig(pidf,signum):
    if os.path.isfile(pidf):
        f = open(pidf, 'r')
        pid = int(f.readline())
        f.close()

        os.kill(pid, signum)
    else:
        print("qute_launcher daemon not running!")

if __name__ == '__main__':
	#Run in forground (dont deamonize)
	pidf = os.environ.get('XDG_RUNTIME_DIR')
	if not pidf:
	    pidf = "/tmp"
	pidf += "/qute-launcher.pid"

	do_quit = False
	do_cleanup = False

	#Handle quick-exiting options
	if "-k" in sys.argv:
		send_parent_sig(pidf, signal.SIGINT)
		do_quit = True
	elif "-c" in sys.argv:
		send_parent_sig(pidf, signal.SIGUSR1)
		do_quit = True

	if not do_quit:
		app_names = []

		if not sys.stdin.isatty():
			for line in sys.stdin:
				app_names.append(line.strip('\n'))

		app = QApplication(sys.argv)

		#Figure out windowing
		app_args = AppArgs()

		if '-f' in sys.argv:
			app_args.use_fullscreen = True
		elif '-p' in sys.argv:
			app_args.use_popup = True

		if '-s' in sys.argv:
			app_args.use_symbolic = True

		if '-t' in sys.argv:
			app_args.use_transparency = True

		if '-h' in sys.argv:
			app_args.hold_window = True

		if '-n' in sys.argv:
			app_args.use_names = True

		window = ExitUserSession(sorted(app_names), app_args)

		if '-d' in sys.argv:
			# Make sure there isn't a daemon running already
			if not os.path.isfile(pidf):
				f = open(pidf, 'w')
				f.write(str(os.getpid()))
				f.close()

				do_cleanup = True
				window.set_is_daemon(True)
			else:
				print("qute_launcher daemon already running!")
				do_quit = True
		else:
			window.set_is_daemon(False)
			window.bring_forward()

	# Either continue processing or quit with bad exit code
	ec = 0
	if not do_quit:
		signal.signal(signal.SIGINT, sigint_handler)
		signal.signal(signal.SIGUSR1, window.sigusr_handler)

		timer = QtCore.QTimer()
		timer.timeout.connect(lambda: None)
		timer.start(100)

		ec = app.exec_()

		if do_cleanup:
			os.remove(pidf)

	sys.exit(ec)
