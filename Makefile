.EXPORT_ALL_VARIABLES:
PYTHONPATH = ./fonttools/Lib:./fontFeatures
ALLFEA = NotoNastaliq.fea add-spacer-glyphs.fea anchors.fea ccmp-decompose-dots.fea ccmp-localisation.fea ccmp-small-and-enclosed-numerals.fea curs-cursive-positioning.fea curs-kerning.fea gdef.fea glyph-classes.fea init-medi-fina.fea long-number-marks.fea rlig-alt-dot-position.fea rlig-connecting-forms.fea rlig-divine-name.fea rlig-kaf-gaf.fea rlig-lam-alef.fea rlig-sum-spacers.fea rlig-yeh-barree-finalization.fea rlig-yeh-barree-handling.fea rlig-yeh-barree-prep.fea yeh-barree-replace-dots.fea yeh-barree-drop-dots.fea

all: master_ttf/NotoNastaliqUrdu-Regular.ttf

clean:
	rm master_ttf/NotoNastaliqUrdu-Regular*.ttf yeh-barree-replace-dots.fea anchors.fea

master_ttf/NotoNastaliqUrdu-Regular-simple.ttf: NotoNastaliqUrdu.glyphs
	fontmake -o ttf -g NotoNastaliqUrdu.glyphs --master-dir .
	mv master_ttf/NotoNastaliqUrdu-Regular.ttf master_ttf/NotoNastaliqUrdu-Regular-simple.ttf

# Note that this alters the font file
yeh-barree-replace-dots.fea: fee/yeh-barree.fee master_ttf/NotoNastaliqUrdu-Regular-simple.ttf
	python3 fontFeatures/fee2fea master_ttf/NotoNastaliqUrdu-Regular-simple.ttf fee/yeh-barree.fee  > yeh-barree-replace-dots.fea

anchors.fea: fee/anchors.fee master_ttf/NotoNastaliqUrdu-Regular-simple.ttf
	# Create anchors file
	python3 fontFeatures/fee2fea master_ttf/NotoNastaliqUrdu-Regular-simple.ttf fee/anchors.fee > anchors.fea

master_ttf/NotoNastaliqUrdu-Regular.ttf: $(ALLFEA) master_ttf/NotoNastaliqUrdu-Regular-simple.ttf
	python3 -m fontTools.feaLib -o master_ttf/NotoNastaliqUrdu-Regular.ttf NotoNastaliq.fea master_ttf/NotoNastaliqUrdu-Regular-simple.ttf

