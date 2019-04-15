#!/usr/bin/python3

import sys
import time
import os
import math
import configparser
import argparse
import signal

from PyQt5 import QtCore
from PyQt5.QtGui import QIcon
from PyQt5.QtWidgets import (QWidget, QToolButton, QLineEdit,
							 QInputDialog, QApplication, QDialog,
							 QVBoxLayout, QGridLayout, QSizePolicy,
							 QScrollArea, QBoxLayout)

def ifprint(do_print, message):
	if do_print:
		print(str(time.time()) + ":\t" + str(message))

class AppWidget():
	def __init__(self, app_path, use_symbolic):
		self.is_valid = False
		self.app_name = ""
		self.app_comment = ""
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
			if 'Comment' in self.config['Desktop Entry']:
				self.app_comment = self.config['Desktop Entry']['Comment']
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

	def appComment(self):
		return self.app_comment

	def appExec(self):
		return self.app_exec

	def appIcon(self):
		return self.app_icon

	def runExec(self):
		os.system("swaymsg exec \'" + self.appExec() + "\'")

class WindowWidget(QWidget):
	resized = QtCore.pyqtSignal()

	def __init__(self):
		super().__init__()

	def resizeEvent(self, event):
		self.resized.emit()
		return QWidget.resizeEvent(self,event)

class ExitUserSession(WindowWidget):
	def __init__(self, app_names, app_args):
		super().__init__()

		self.app_args = app_args
		self.stay_alive = False
		self.rendering_done = False

		self.app_names = app_names
		QIcon.setFallbackSearchPaths(["/usr/share/pixmaps"])
		self.app_list = self.gen_app_widgets(app_names)
		self.shortlist = self.app_list

		self.init_ui()

	def gen_app_widgets(self, app_names):
		apps = []

		for n in app_names:
			a = AppWidget(n,self.app_args.use_symbolic)
			apps.append(a)

		return apps

	def init_ui(self):
		self.setWindowTitle( 'Qute Launcher' )

		if self.app_args.daemonize:
			self.setAttribute(QtCore.Qt.WA_QuitOnClose)

		self.frame_margin = 2
		#self.frame_offset_x = 0
		#self.frame_offset_y = 0

		# If a size has not bee defined, allow it to stretch (later)
		# Otherwise we define a fallback size
		size_lock = False
		if (self.app_args.frame_size_x != 0) and (self.app_args.frame_size_y != 0):
			size_lock = True
		else:
			self.app_args.frame_size_x = 800
			self.app_args.frame_size_y = 600

		if not self.app_args.use_fullscreen:
			self.setWindowFlags(QtCore.Qt.FramelessWindowHint)

			if self.app_args.use_popup:
				ifprint(self.app_args.verbose, "Popup mode")
				self.setWindowFlags(self.windowFlags() | QtCore.Qt.Dialog)

				self.setGeometry( QtCore.QRect(0,0,self.app_args.frame_size_x,self.app_args.frame_size_y) )
				qtRectangle = self.frameGeometry()
				centerPoint = QApplication.desktop().availableGeometry().center()
				qtRectangle.moveCenter(centerPoint)
				self.move(qtRectangle.topLeft())

		if self.app_args.use_transparency:
			self.setAttribute(QtCore.Qt.WA_NoSystemBackground)
			self.setAttribute(QtCore.Qt.WA_TranslucentBackground);

		if self.app_args.background_color != '-':
			self.setStyleSheet('QWidget{background-color: ' + str(self.app_args.background_color) +';}')

		# Install an event filter to hide on loss of focus
		if not self.app_args.hold_window:
			self.installEventFilter(self)

		self.frame_widget = QWidget()
		window_layout = QVBoxLayout()
		window_layout.setAlignment(QtCore.Qt.AlignHCenter)
		window_layout.addWidget(self.frame_widget)
		self.setLayout(window_layout)

		# Set frame widget to stay at same size specified
		if size_lock:
			self.frame_widget.setFixedSize(self.app_args.frame_size_x, self.app_args.frame_size_y)

		self.app_search = QLineEdit(self)
		self.app_search.textChanged.connect(self.update_filter)
		self.app_search.returnPressed.connect(lambda: self.do_run(0))
		self.app_search.setStyleSheet('QLineEdit:focus{border: 1px solid; border-color: ' + self.app_args.focus_color + ';}') #Remove boarder

		self.scrollarea = QScrollArea(self)
		self.scrollarea.setAlignment(QtCore.Qt.AlignHCenter)
		self.scrollarea.setWidgetResizable(False)
		self.scrollarea.setFocusPolicy(QtCore.Qt.NoFocus)

		frame_layout = QVBoxLayout()
		frame_layout.addWidget(self.app_search)
		frame_layout.addWidget(self.scrollarea)
		self.frame_widget.setLayout(frame_layout)

		self.resized.connect(lambda text=self.shortlist: self.update_list_layout(text, reason="Resized"))

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

	def update_list_layout(self, app_list, reason="Direct Call"):
		if self.rendering_done:
			ifprint(self.app_args.verbose, 'update_list_layout(' + reason + ')')

			app_layout = None

			usable_space = self.scrollarea.geometry().width() \
						 - self.scrollarea.verticalScrollBar().sizeHint().width()

			if self.app_args.list_layout == "list":
				app_layout = QVBoxLayout()
				app_layout.setSpacing(self.app_args.button_spacing)
				app_layout.setAlignment(QtCore.Qt.AlignLeft)
				usable_space -= 2*self.app_args.button_spacing #leave a little bit of extra space for either-side of the buttons

				for ind, app in enumerate(app_list):
					w = QToolButton()
					w.clicked.connect(lambda arg, text=ind: self.do_run(text))
					w.setFixedSize(usable_space, self.app_args.button_size)
					w.setText("\t" + app.appName() + "\n\t" + app.appComment())
					w.setIcon(app.appIcon())
					w.setIconSize(QtCore.QSize(self.app_args.button_size, self.app_args.button_size))
					w.setToolButtonStyle(QtCore.Qt.ToolButtonTextBesideIcon)
					w.setStyleSheet('QToolButton{border: 0px solid;}') #Remove boarder
					app_layout.addWidget(w)
			else:
				#Use grid mode by default
				app_layout = QGridLayout()
				app_layout.setSpacing(self.app_args.button_spacing)
				usable_space -= self.app_args.button_spacing #leave a little bit of extra space for either-side of the buttons
				cols = int(usable_space / (self.app_args.button_spacing + self.app_args.button_size))
				if cols < 1:
					cols = 1

				# We want the icons to be shrunk down a touch
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
					w.setStyleSheet('QToolButton{border: 1px solid; border-color: transparent;} QToolButton:focus{border: 1px solid; border-color: ' + self.app_args.focus_color + ';}') #Remove boarder
					app_layout.addWidget(w, row, ind % cols)

			if app_layout is not None:
				app_list_widget = QWidget()
				app_list_widget.setLayout(app_layout)
				self.scrollarea.setWidget(app_list_widget)
			else:
				print("FATAL: app_layout note set!")
				QApplication.quit()
		else:
			ifprint(self.app_args.verbose, 'Ignored update_list_layout(' + reason + '), rendering not ready')


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
		ifprint(self.app_args.verbose, 'bring_forward() -> show()')
		self.show()

		# For some reason window does not redraw properly
		# unless show() is called first
		if self.app_args.use_fullscreen:
			self.showFullScreen()

		ifprint(self.app_args.verbose, "bring_forward() -> app_search")
		self.app_search.clear()
		self.app_search.setFocus()

		ifprint(self.app_args.verbose, "bring_forward() -> update_filter()")
		self.rendering_done = True

		if not self.app_args.late_rendering:
			self.update_filter()

	def sigusr_handler(self, signum, stack):
		ifprint(self.app_args.verbose, "Received user signal")
		self.bring_forward()

	def do_cancel(self):
		self.rendering_done = False

		if self.app_args.daemonize:
			self.hide()
		else:
			self.close()

def check_daemon(pidf):
	if os.path.isfile(pidf):
		print("qutepy_launcher daemon running")
		return True
	else:
		print("qutepy_launcher daemon not running!")
		return False

def sigint_handler(signum,stack):
	"""handler for the SIGINT signal."""
	sys.stderr.write('\r')
	QApplication.quit()

def send_daemon_sig(pidf,signum):
	if check_daemon(pidf):
		f = open(pidf, 'r')
		pid = int(f.readline())
		f.close()

		os.kill(pid, signum)

		print("Signal sent to daemon")

def parse_args():
	parser = argparse.ArgumentParser()

	parser.add_argument('-k', '--kill-daemon',	dest='kill',
						help='Signals the running daemon to exit',
						action='store_true', default=False)
	parser.add_argument('-c', '--call-daemon',	dest='call',
						help='Signals the running daemon to show the window',
						action='store_true', default=False)
	parser.add_argument('-d', '--daemonize',	dest='daemonize',
						help='Starts a backgrounded daemon',
						action='store_true', default=False)
	parser.add_argument('-v', '--verbose',	dest='verbose',
						help='Output debug messages',
						action='store_true', default=False)

	parser.add_argument('-w', '--hold-window',	dest='hold_window',
						help='Disables automatic window hiding',
						action='store_true', default=False)
	parser.add_argument('-l', '--late-rendering',	dest='late_rendering',
						help='Skips first rendering step (on window show) and waits for the window resize to trigger the applicaiton list to update (this should stop a unneeded processing on tiling window systems)',
						action='store_true', default=False)
	parser.add_argument('-f', '--fullscreen',	dest='use_fullscreen',
						help='Dislpays the window in fullscreen mode',
						action='store_true', default=False)
	parser.add_argument('-p', '--popup',		dest='use_popup',
						help='Displays the window as a popup',
						action='store_true', default=False)
	parser.add_argument('-s', '--symbolic-icons', dest='use_symbolic',
						help='Prefer symbolic icons (if available)',
						action='store_true', default=False)
	parser.add_argument('-t', '--transparent',	dest='use_transparency',
						help='Set the background layer to be transparent',
						action='store_true', default=False)
	parser.add_argument('-n', '--show-names',	dest='use_names',
						help='Display names under icons in grid mode',
						action='store_true', default=False)

	parser.add_argument('--button-size',		dest="button_size",
						help='Size of the button to use (px)',
						action='store', type=int, default=90)
	parser.add_argument('--button-spacing',		dest="button_spacing",
						help='Size of padding between buttons (px)',
						action='store', type=int, default=10)
	parser.add_argument('--frame-size-x',		dest="frame_size_x",
						help='Width of the drawn frame in fullscreen and popup mode (px)',
						action='store', type=int, default=0)
	parser.add_argument('--frame-size-y',		dest="frame_size_y",
						help='Height of the drawn frame in fullscreen and popup mode (px)',
						action='store', type=int, default=0)
	parser.add_argument('--list-layout',		dest="list_layout",
						help='Selector for the listing display type (options: grid, list)',
						action='store', type=str, default='grid')
	parser.add_argument('--focus-color',		dest="focus_color",
						help='Color to use to signify item that is currently focused (valid CSS color code)',
						action='store', type=str, default='white')
	parser.add_argument('--background-color',		dest="background_color",
						help='Color to use for background (valid CSS color code)',
						action='store', type=str, default='-')

	parsed_args, unparsed_args = parser.parse_known_args()

	return parsed_args, unparsed_args

if __name__ == '__main__':
	# Prep CLI args
	parsed_args, unparsed_args = parse_args()
	qt_args = sys.argv[:1] + unparsed_args

	#Run in forground (dont deamonize)
	pidf = os.environ.get('XDG_RUNTIME_DIR')
	if not pidf:
	    pidf = "/tmp"
	pidf += "/qutepy-launcher.pid"

	do_quit = False
	do_cleanup = False

	#Handle quick-exiting options
	if parsed_args.kill:
		# If there is an invalid PID this will throw
		# best to continue on and clean up
		try:
			print("Attempting to kill daemon")
			send_daemon_sig(pidf, signal.SIGINT)
		except ProcessLookupError:
			print("Unable to contact daemon (invalid process)")
			print("Performing cleanup")
			do_cleanup = True

		do_quit = True
	elif parsed_args.call:
		try:
			send_daemon_sig(pidf, signal.SIGUSR1)
		except ProcessLookupError:
			print("Unable to contact daemon (invalid process)")

		do_quit = True

	if not do_quit:
		app_names = []

		if not sys.stdin.isatty():
			for line in sys.stdin:
				app_names.append(line.strip('\n'))

		app = QApplication(qt_args)

		window = ExitUserSession(sorted(app_names), parsed_args)

		if parsed_args.daemonize:
			# Make sure there isn't a daemon running already
			if not os.path.isfile(pidf):
				f = open(pidf, 'w')
				f.write(str(os.getpid()))
				f.close()

				do_cleanup = True
			else:
				print("qute_launcher daemon already running!")
				do_quit = True
		else:
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
