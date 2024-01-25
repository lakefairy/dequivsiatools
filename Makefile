.POSIX:
.PHONY: all clean checksum getupx 
UPX=./upx
all: dequivsia.zip
clean:
	$(RM) hspsum $(DIST_TARGET) dequivsia.unupx.exe dequivsia/data/savedata/.dummy dequivsia/readme_en.txt
checksum:
	sha256sum -c <dequivsia.sha256
getupx:
	curl -L https://github.com/upx/upx/releases/download/v4.2.2/upx-4.2.2-amd64_linux.tar.xz | tar -xJO upx-4.2.2-amd64_linux/upx > upx
	chmod +x upx
	echo 'e0dff9d826f017f0f55c2c6e07888d4f22e2bafc36bd820b1966ddab7d73e012 *upx' | sha256sum -c || rm upx
hspsum: hspsum.cpp
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(LDFLAGS) hspsum.cpp $(LDLIBS) -o hspsum
dequivsia/english.dpm: dequivsiatools.py dequivsia/data/data.dpm chip_15_en.png
	./dequivsiatools.py replacedpmbmp dequivsia/data/data.dpm chip_15.bmp chip_15_en.png dequivsia/english.dpm
dequivsia.unupx.exe: dequivsia/dequivsia.exe
	$(UPX) -d -o dequivsia.unupx.exe dequivsia/dequivsia.exe
dequivsia/dequivsia.en.exe: dequivsiatools.py hspsum dequivsia.unupx.exe
	./dequivsiatools.py patchexe --dpmname english.dpm            dequivsia.unupx.exe dequivsia/dequivsia.en.exe
	./hspsum -f -o dequivsia/dequivsia.en.exe
dequivsia/dequivsia.15x.exe: dequivsiatools.py hspsum dequivsia.unupx.exe
	./dequivsiatools.py patchexe                       --scale 15 dequivsia.unupx.exe dequivsia/dequivsia.15x.exe
	./hspsum -f -o dequivsia/dequivsia.15x.exe
dequivsia/dequivsia.en.15x.exe: dequivsiatools.py hspsum dequivsia.unupx.exe
	./dequivsiatools.py patchexe --dpmname english.dpm --scale 15 dequivsia.unupx.exe dequivsia/dequivsia.en.15x.exe
	./hspsum -f -o dequivsia/dequivsia.en.15x.exe
dequivsia/data/savedata/.dummy:
	mkdir -p dequivsia/data/savedata
	touch dequivsia/data/savedata dequivsia/data/savedata/.dummy
dequivsia/readme_en.txt: readme_en.txt
	cp -f readme_en.txt dequivsia/readme_en.txt

DIST_TARGET = \
	dequivsia/dequivsia.15x.exe \
	dequivsia/dequivsia.en.15x.exe \
	dequivsia/dequivsia.en.exe \
	dequivsia/english.dpm \
	dequivsia/readme_en.txt

DIST_BASE = \
	dequivsia/data/ani/a1.wav \
	dequivsia/data/ani/a2.wav \
	dequivsia/data/ani/a3.wav \
	dequivsia/data/ani/a4.wav \
	dequivsia/data/mu/1.wav \
	dequivsia/data/mu/2.wav \
	dequivsia/data/mu/3.wav \
	dequivsia/data/mu/4.wav \
	dequivsia/data/mu/5.wav \
	dequivsia/data/mu/21.wav \
	dequivsia/data/mu/22.wav \
	dequivsia/data/se/se_0.wav \
	dequivsia/data/se/se_1.wav \
	dequivsia/data/se/se_2.wav \
	dequivsia/data/se/se_3.wav \
	dequivsia/data/se/se_4.wav \
	dequivsia/data/se/se_5.wav \
	dequivsia/data/se/se_6.wav \
	dequivsia/data/se/se_7.wav \
	dequivsia/data/se/se_8.wav \
	dequivsia/data/se/se_9.wav \
	dequivsia/data/se/se_10.wav \
	dequivsia/data/se/se_11.wav \
	dequivsia/data/se/se_12.wav \
	dequivsia/data/se/se_13.wav \
	dequivsia/data/se/se_14.wav \
	dequivsia/data/se/se_15.wav \
	dequivsia/data/se/se_16.wav \
	dequivsia/data/se/se_17.wav \
	dequivsia/data/se/se_18.wav \
	dequivsia/data/se/se_19.wav \
	dequivsia/data/se/se_20.wav \
	dequivsia/data/se/se_21.wav \
	dequivsia/data/se/se_22.wav \
	dequivsia/data/se/se_23.wav \
	dequivsia/data/se/se_24.wav \
	dequivsia/data/se/se_25.wav \
	dequivsia/data/se/se_26.wav \
	dequivsia/data/se/se_27.wav \
	dequivsia/data/se/se_30.wav \
	dequivsia/data/se/se_31.wav \
	dequivsia/data/se/se_32.wav \
	dequivsia/data/se/se_33.wav \
	dequivsia/data/se/se_34.wav \
	dequivsia/data/se/se_35.wav \
	dequivsia/data/se/se_36.wav \
	dequivsia/data/se/se_37.wav \
	dequivsia/data/se/se_38.wav \
	dequivsia/data/se/se_39.wav \
	dequivsia/data/se/se_40.wav \
	dequivsia/data/se/se_41.wav \
	dequivsia/data/se/se_42.wav \
	dequivsia/data/se/se_43.wav \
	dequivsia/data/se/se_44.wav \
	dequivsia/data/se/se_45.wav \
	dequivsia/data/se/se_46.wav \
	dequivsia/data/se/se_47.wav \
	dequivsia/data/se/se_48.wav \
	dequivsia/data/se/se_49.wav \
	dequivsia/data/se/se_50.wav \
	dequivsia/data/se/se_51.wav \
	dequivsia/data/se/se_52.wav \
	dequivsia/data/100 \
	dequivsia/data/data.dpm \
	dequivsia/data/icon.ico \
	dequivsia/dequivsia.exe \
	dequivsia/dsoundex.hpi \
	dequivsia/readme.txt

dequivsia.zip: $(DIST_BASE) dequivsia/data/savedata/.dummy $(DIST_TARGET)
	-$(RM) dequivsia.zip
	zip -9X dequivsia.zip $(DIST_BASE) dequivsia/data/savedata $(DIST_TARGET)
