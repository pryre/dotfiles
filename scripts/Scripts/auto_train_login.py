import mechanize
import sys

br = mechanize.Browser()
br.set_handle_equiv(True)
#br.set_handle_gzip(True)
br.set_handle_redirect(True)
br.set_handle_referer(True)
br.set_handle_robots(False)
br.set_handle_refresh(mechanize._http.HTTPRefreshProcessor(), max_time=1)
br.addheaders = [('User-agent', 'Mozilla/5.0 (X11; Linux x86_64; rv:13.0) Gecko/20100101 Firefox/13.0')]

testURL = 'http://www.queenslandrail.com.au/wi-fi/'
#response = br.open(testURL)
br.open(testURL)
#if response.geturl() == testURL:
if br.geturl() == testURL:
	print("AutoLog: You are already logged into QRail Free WiFi?")
	sys.exit(2)


br.select_form(nr=0)
print("-----------------------------------")
print(br.form)
print("-----------------------------------")
br.form.find_control("ACCEPT").items[0].selected = True
br.submit()

print("--- AutoLog [QRail Free WiFi] Done ---")

br.open(testURL)
if br.geturl() == testURL:
	print("AutoLog: You have been logged into QRail Free WiFi!")
	sys.exit(0)
else:
	print("AutoLog: You have not been connected to WiFi.")
	sys.exit(1)

#try:
#	forms = mechanize.ParseResponse(response, backwards_compat=False)
#except:
#	print "AutoLog: Error in parsing forms, Am I already logged in?"
#	sys.exit()

#response.close

#form = forms[0]
#print "-----------------------------------"
#print forms
#print "-----------------------------------"
#form.find_control("ACCEPT").items[0].selected = True
#print form
#print "-----------------------------------"
#request = forms.click()

#request = form.SubmitControl.click()
#response = mechanize.urlopen(request)
#forms = mechanize.ParseResponse(response, backwards_compat=False)
#response.close()
