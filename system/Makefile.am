systemdir = $(libdir)/manokwari/system

system_DATA = \
	menu.html \
	desktop.html \
	texture.jpg \
	$(NULL)

systemcssdir = $(systemdir)/css
systemcss_DATA = $(shell find css -name '*.css')

systemjsdir = $(systemdir)/js
systemjs_DATA = $(shell find js -name '*.js')

systemfontsdir = $(systemdir)/fonts
systemfonts_DATA = $(shell find fonts -name '*.*')

systemimgdir = $(systemdir)/img
systemimg_DATA = $(shell find img -name '*.*')

systemimgicondir = $(systemimgdir)/icons
systemimgicon_DATA = $(shell find img/icons -name '*.*')

systemimgplayerdir = $(systemimgdir)/player
systemimgplayer_DATA = $(shell find img/player -name '*.*')

systemweatherdir = $(systemdir)/widget/weather
systemweather_DATA = $(shell find widget/weather -name '*.*')

systemweathercssdir = $(systemweatherdir)/css
systemweathercss_DATA = $(shell find widget/weather/css -name '*.*')

systemweatherfontsdir = $(systemweatherdir)/fonts
systemweatherfonts_DATA = $(shell find widget/weather/fonts -name '*.*')

systemweatherimgdir = $(systemweatherdir)/img
systemweatherimg_DATA = $(shell find widget/weather/img -name '*.*')

systemweatherjsdir = $(systemweatherdir)/js
systemweatherjs_DATA = $(shell find widget/weather/js -name '*.*')

CLEANFILES = \
	$(systemdir_DATA) \
	$(systemcssdir_DATA) \
	$(systemjsdir_DATA) \
	$(systemfontsdir_DATA) \
	$(systemimgdir_DATA) \
	$(systemimgicondir_DATA) \
	$(systemimgplayerdir_DATA) \
	$(systemweatherdir_DATA) \
	$(systemweathercssdir_DATA) \
	$(systemweatherfontsdir_DATA) \
	$(systemweatherimgdir_DATA) \
	$(systemweatherjsdir_DATA)
	
