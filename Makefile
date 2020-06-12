.EXPORT_ALL_VARIABLES:
PYTHONPATH = ./fonttools/Lib:./fontFeatures
ALLFEA = NotoNastaliq.fea add-spacer-glyphs.fea anchors.fea ccmp-decompose-dots.fea ccmp-localisation.fea ccmp-small-and-enclosed-numerals.fea curs-cursive-positioning.fea curs-kerning.fea gdef.fea glyph-classes.fea init-medi-fina.fea long-number-marks.fea rlig-alt-dot-position.fea rlig-connecting-forms.fea rlig-divine-name.fea rlig-kaf-gaf.fea rlig-lam-alef.fea rlig-sum-spacers.fea rlig-yeh-barree-finalization.fea rlig-yeh-barree-handling.fea rlig-yeh-barree-prep.fea

all: master_ttf/NotoNastaliqUrdu-Regular.ttf

master_otf/NotoNastaliqUrdu-Regular-simple.otf: NotoNastaliqUrdu.glyphs
	# Build first cut OTF UFO, from Glyphs
	fontmake -o otf -g NotoNastaliqUrdu.glyphs --master-dir .
	mv master_otf/NotoNastaliqUrdu-Regular.otf master_otf/NotoNastaliqUrdu-Regular-simple.otf

master_ttf/NotoNastaliqUrdu-Regular-simple.ttf: NotoNastaliqUrdu.glyphs
	# Build first cut OTF UFO, from Glyphs
	fontmake -o otf -g NotoNastaliqUrdu.glyphs --master-dir .
	mv master_ttf/NotoNastaliqUrdu-Regular.ttf master_ttf/NotoNastaliqUrdu-Regular-simple.ttf

anchors.fea: fee/anchors.fee master_otf/NotoNastaliqUrdu-Regular-simple.otf
	# Create anchors file
	python3 fontFeatures/fee2fea master_otf/NotoNastaliqUrdu-Regular-simple.otf fee/anchors.fee > anchors.fea

master_otf/NotoNastaliqUrdu-Regular.otf: $(ALLFEA) master_otf/NotoNastaliqUrdu-Regular-simple.otf
	python3 -m fontTools.feaLib -o master_otf/NotoNastaliqUrdu-Regular.otf NotoNastaliq.fea master_otf/NotoNastaliqUrdu-Regular-simple.otf

master_ttf/NotoNastaliqUrdu-Regular.ttf: $(ALLFEA) master_ttf/NotoNastaliqUrdu-Regular-simple.ttf
	python3 -m fontTools.feaLib -o master_ttf/NotoNastaliqUrdu-Regular.ttf NotoNastaliq.fea master_ttf/NotoNastaliqUrdu-Regular-simple.ttf

