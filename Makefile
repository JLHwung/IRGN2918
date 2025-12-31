images/%.jpg: images/%.png
	magick -quality 80 $< $@

jpg: $(addsuffix .jpg, $(basename $(wildcard images/*.png)))

clean-tex:
	-rm -f *.{aux,dvi,log,bbl,blg,brf,fls,toc,thm,out,fdb_latexmk}

all: font venv
	latexmk -lualatex main.tex

ifndef CI
update-font:
	curl --remote-name --location https://www.babelstone.co.uk/Fonts/Download/BabelStoneHanBeta.zip && \
	unzip -o BabelStoneHanBeta.zip -d ./fonts && \
	rm BabelStoneHanBeta.zip

fonts/BabelStoneHan-merged.ttf.ufo: fonts/BabelStoneHan-merged.ttf
	rm -rf ./fonts/BabelStoneHan-merged.ttf.ufo
	$(VENV)/extractufo ./fonts/BabelStoneHan-merged.ttf
	git add ./fonts/BabelStoneHan-merged.ttf.ufo

fonts/source-subset.txt: main.tex main.bib pua-ids.csv
	$(VENV)/python ./fonts/generate-source-subset.py

fonts/BabelStoneHanBasic-subset.ttf: fonts/BabelStoneHan-subset.py fonts/source-subset.txt fonts/BabelStoneHanBasic.ttf
	$(VENV)/python ./fonts/BabelStoneHan-subset.py ./fonts/BabelStoneHanBasic.ttf

fonts/BabelStoneHanExtra-subset.ttf: fonts/BabelStoneHan-subset.py fonts/source-subset.txt fonts/BabelStoneHanExtra.ttf
	$(VENV)/python ./fonts/BabelStoneHan-subset.py ./fonts/BabelStoneHanExtra.ttf

fonts/BabelStoneHanSupplement-subset.ttf: fonts/BabelStoneHan-subset.py fonts/source-subset.txt fonts/BabelStoneHanSupplement.ttf
	$(VENV)/python ./fonts/BabelStoneHan-subset.py ./fonts/BabelStoneHanSupplement.ttf

fonts/BabelStoneHanPUA-pua-subset.ttf: fonts/BabelStoneHanPUA-subset.py pua-ids.csv fonts/BabelStoneHanPUA.ttf
	$(VENV)/python ./fonts/BabelStoneHanPUA-subset.py ./fonts/BabelStoneHanPUA.ttf

fonts/BabelStoneHanSupplement-pua-subset.ttf: fonts/BabelStoneHanPUA-subset.py pua-ids.csv fonts/BabelStoneHanSupplement.ttf
	$(VENV)/python ./fonts/BabelStoneHanPUA-subset.py ./fonts/BabelStoneHanSupplement.ttf

fonts/BabelStoneHan-merged.ttf: pua-ids.csv fonts/BabelStoneHanBasic-subset.ttf fonts/BabelStoneHanExtra-subset.ttf fonts/BabelStoneHanPUA-pua-subset.ttf fonts/BabelStoneHanSupplement-subset.ttf fonts/BabelStoneHanSupplement-pua-subset.ttf ./fonts/BabelStoneHan-merged.py
	$(VENV)/python ./fonts/BabelStoneHan-merged.py
endif

# Build font from the tracked UFO in CI mode
ifdef CI
fonts/BabelStoneHan-merged.ttf: fonts/BabelStoneHan-merged.ttf.ufo
	fontmake -u "./fonts/BabelStoneHan-merged.ttf.ufo" -o ttf --keep-overlaps --ttf-curves keep-quad --output-path ./fonts/BabelStoneHan-merged.ttf
endif
font: fonts/BabelStoneHan-merged.ttf

include Makefile.venv