PREFIX=/usr/local
FONTS=latin1.vtfont latin2.vtfont latin3.vtfont latin4.vtfont latin9.vtfont

all: fonts

clean:
	-rm $(FONTS)

fonts: $(FONTS) 

latin1.vtfont: latin1.pbm
	./mkvtfont latin1.pbm > latin1.vtfont

latin2.vtfont: latin2.pbm
	./mkvtfont latin2.pbm > latin2.vtfont

latin3.vtfont: latin3.pbm
	./mkvtfont latin3.pbm > latin3.vtfont

latin4.vtfont: latin4.pbm
	./mkvtfont latin4.pbm > latin4.vtfont

latin9.vtfont: latin9.pbm
	./mkvtfont latin9.pbm > latin9.vtfont

install: all
	install vtfont $(PREFIX)/bin/vtfont
	install mkvtfont $(PREFIX)/bin/mkvtfont
	
	install -d $(PREFIX)/share/vtfonts/
	install -m 644 *.vtfont $(PREFIX)/share/vtfonts/
