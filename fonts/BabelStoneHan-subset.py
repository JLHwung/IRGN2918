from pathlib import Path
from fontTools.ttLib import TTFont
from fontTools.subset import Subsetter, Options
import sys

source_characters = Path("./fonts/source-subset.txt").read_text()

font_path = sys.argv[1]
font_bsh = TTFont(font_path)
options = Options(glyph_names = True)
subsetter = Subsetter(options)
if not "Basic" in font_path:
    # Ignore ASCII characters in Extra/Supplement fonts
    source_characters = ''.join(i for i in source_characters if ord(i) >= 0x20000)

subsetter.populate(text=source_characters)
subsetter.subset(font_bsh)
output_font_path = font_path.replace(".ttf", "-subset.ttf")
font_bsh.save(output_font_path)
