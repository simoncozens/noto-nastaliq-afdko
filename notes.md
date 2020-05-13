# Notes on Noto Nastaliq Urdu

## Substitution Rules

### First order of business: Decompose the dots

As Khaled explains [in this blog post](https://khaledhosny.github.io/2010/05/13/get-off-my-dots.html), the best way to deal with nukta positioning is to treat the nukta as diacritics and separate them from the base characters. This allows for variant forms of the same character to be handled easily, and for the dots to be positioned using standard OpenType anchors attachment. This in turn gives you a lot of flexibility in providing solutions for collision avoidance.

So, [lookup 0](https://github.com/googlefonts/noto-source/blob/master/src/NotoNastaliqUrdu/Noto%20Nastaliq%20Urdu%20Regular%20GSUB.txt#L34) in the Monotype source - and `ccmp-decompose-dots.fea` in my OpenType version - decompose glyphs into dots and bases.

Note that the dots come *after* the bases during the GSUB phase. (They'll be reversed in the GPOS phase.)

### Small and enclosed numbers

The next set of lookups (headed by [lookup 156](https://github.com/googlefonts/noto-source/blob/master/src/NotoNastaliqUrdu/Noto%20Nastaliq%20Urdu%20Regular%20GSUB.txt#L19030) and 157, but chaining into 152-155) is for number handling - in particular, enclosing numbers inside the ayah mark and above the sanah sign. 156 deals with the first digit in a sequence, and 157 deals with subsequent digits - it calculates how many digits are involved, in quite a clever way: in an enclosed/sanah context, lookup 157 calls lookup 154/155 to replace the number (base glyph) with a marker glyph `baseNum` (which is a base) and a version of the number glyph which is a mark. Now if you `ignoreMarks`, you can just count the `baseNums` to determine the width of the sanah (or samvar, or footnote mark, or...) you need:

    sub Sanah baseNum baseNum baseNum by Sanah.alt4;
    sub Sanah baseNum baseNum by Sanah.alt3;
    sub Sanah baseNum by Sanah.alt2;

This will be followed up by a mark-to-ligature rule (lookup 13 in the Monotype GPOS source) which positions each digit at the appropriate place in the wide number-containing glyphs, but that'll come later.

These lookups are implemented in the OpenType version as `ccmp-small-and-enclosed-numerals.fea`.

### Localisation

This is a fairly standard [language specific substitute](https://simoncozens.github.io/fonts-and-layout//localisation.html#language-specific-substitutes) pattern, although not terribly easy to follow in the Monotype source because of the way that the language groupings are at the top level, with features and their lookups underneath them (if you're used to reading AFDKO sources, you think in terms of features at the top level, with language-specific lookups underneath *them*).

At any rate, lookups 9, 10, 11, and 12 arrange for language-specific things to happen: variant forms of hamza, sukun, etc. and of course the language-specific digits. In the OpenType sources, these are expressed in `ccmp-localisation.fea`.

### Init, Medi, Fina

There should be nothing surprising here. Lookups 1-5 in the MonoType source do the standard positional substitutions. The only slight trick is that when language is `ARA` or `FAR` there is an additional call to lookup 6 in the `fina` feature, which adds the `SharetKafNS` mark at the end of final Kaf.

Note that these lookups *also* perform nukta decomposition, to deal with cases where the position of dots differ according to positional form. For example, `Jeem` gets different decomposed nuktas depending on where it appears:

    feature init { ... sub Jeem by HahIni OneDotBelowNS; ... } init;
    feature isol { ... sub Jeem by HahSep OneDotEnclNS; ... } isol;
    feature medi { ... sub Jeem by HahMed OneDotBelowNS; ... } medi;
    feature fina { ... sub Jeem by HahFin OneDotEnclNS; ... } fina;

### Lam Alef

And now we are into "proper" substitution rules, in the sense that everything so far has been fairly standard and preparatory. The lam-alef ligature is an interesting challenge in that you want to be able to form the ligature but also connect with ligature possibilities in future glyph sequences too. GPOS lookups 7 and 8 (and `rlig-lam-alef.fea` in the OpenType source) enable this, using the same techniques that Khaled uses in Amiri, as described in [my book](https://simoncozens.github.io/fonts-and-layout//localisation.html#arabic-urdu-and-sindhi).

### Divine Name

Lam lam heh, on its own, could *technically* mean [anything](https://www.youtube.com/watch?v=TngViNw2pOo). That's why we call the magic null lookup 23 (`sub space by space`) when we see it. I'm guessing that FontDame doesn't naturally support `ignore sub` lookups, so this is the hack-around: the point is that after a lookup applies - even if it does nothing - no other lookups will be fired at that point in the glyph stream, and things will move on. So if lam lam heh by itself is spotted, we apply a dummy lookup and move on.

But lam lam heh with appropriate marks above the second lam quite definitely *does* mean something, and we should get that right. [Lookup 13](https://github.com/googlefonts/noto-source/blob/master/src/NotoNastaliqUrdu/Noto%20Nastaliq%20Urdu%20Regular%20GSUB.txt#L467) in the Monotype source covers all the possibilities of lam lam (+marks) heh, and then dispatches to [lookup 14](https://github.com/googlefonts/noto-source/blob/master/src/NotoNastaliqUrdu/Noto%20Nastaliq%20Urdu%20Regular%20GSUB.txt#L494) to replace that with the appropriate ligature. In the OpenType source, this is represented in `rlig-divine-name.fea`.

Once again, this will get picked up by mark-to-ligature rules to position the marks at the appropriate place in the Name by lookup 15 in the GPOS. But we'll deal with that later.

### Yeh Barree Preparation

Now, this is where things start to get a little complicated, and by "a little", I mean [(quote)](https://developers.googleblog.com/2014/11/i-can-get-another-if-i-break-it.html) "we’ve been working over a year to solve technical and design issues".

The first thing that happens (in lookup 15) is that all marks below a glyph which is part of a yeh-barree sequence, but which are *not immediately adjacent* to the `YehBarreeFin` are converted to their `...YB` equivalents as a way of marking them out for future processing. At the same time, glyphs which *don't* have any marks after them (and are not immediately adjacent to the `YehBarreeFin`) get a fake mark, `ybPre`, added. A yeh-barree sequence is up to four glyphs long - the longest would be four medial glyphs - and anything before that would not take part in this lookup.

So now everything in a YB sequence before the final glyph has a mark after it: either `ybPre` or one of the `...YB` marks.

Before lookup 15:

    [BehxIni|OneDotBelowNS|SeenMed|SeenMed|YehBarreeFin]

After lookup 15:

    [BehxIni|OneDotBelowYB|SeenMed|ybPre|SeenMed|ybPre|SeenMed|YehBarreeFin]

ٓNote that if there's a mark adjacent to the `YehBarreFin`, it's untouched:

    Before: [SeenIni|BehxMed|OneDotBelowNS|YehBarreeFin]
    After:  [SeenIni|ybPre|BehxMed|OneDotBelowNS|YehBarreeFin]

Next up is lookup 19, which adds some counter glyphs to the end of a YB sequence denoting the number of base glyphs involved in the sequence. Watch out with this one because the numbering is confusing. The `YehBarreeFin` in the longest sequence (four medials + yeh barree itself) gets replaced by `YehBarreeFin_5 YBc3 YBc2 YBc1`, and so on down to a sequence of two bases and the yeh barree which becomes `<base> <mk> <base> <mk?> YehBarreeFin_3 YBc1`. There isn't a `YehBarreeFin_2`; that's just `<base> <mk?> YehBarreeFin`.

Finally, any *additional* low marks hanging around in a YB sequence (such as kasra or kasratan after dots) are converted to their `...YB` forms by lookup 20.

These are implemented in the AFDKO course in `rlig-yeh-barree-prep.fea`.

### Connecting Forms

This is the meatiest part of the lookups, and to be honest, it's hard to say much about it. It's all about sewing together different combinations of glyphs to make sure that the ends all have the right thickness and stroke direction. It's very clever, but unless you're working with *this exact glyphset* there's not much you're going to learn from it.

One interesting technical thing here is the use of *multiple lookups per glyph position*, something that's supported only in the very latest fonttools and makeotf (which is why they are submodules to this repository). So for example:

    sub HehDoIni' lookup lookup_78 lookup lookup_100 AinFin' lookup lookup_106;

This takes a heh doachashmee / ain sequence, and changes the `HehDoIni` *first* to `HehDoIni.outT2` (lookup 78) and *then* to `HehDoIni.outT2wide` (lookup 100), which `AinFin` becomes `AinFin.2` (lookup 106).

I suppose the other thing to learn from this is, use better glyph names. `inT2outD2WQ`? No thanks.

These are implemented in the AFDKO course in `rlig-connecting-forms.fea`.

### Yeh Barree Handling

This code makes heavy use of class-based contextual substitutions, including the "class 0" ("any other glyph") class, which makes the AFDKO rules here too big to be compiled! So let's investigate how this works, but on the understanding that we're going to need a different way to do it for an AFDKO-based solution to actually work.

First, let's have a mapping of what the key lookups here do:

|Lookup ID(s)|Meaning|
|-|-|
|42-44|Run the 45/46/47/64 algorithm on sequences of different length|
|45|Mark handling (more detail below)|
|46|Replace YB marks with null marks|
|47|Mark handling (more detail below)|
|48-62|Add below marks back after a YBC*n* marker glyph|
|63|Replace marks with YB marks (not used here)|
|64|Delete a mark before a `NullMk`|
|135-149|Add spacers of various lengths (sp1-sp15)

(XXX More here)

### Alternate dot placement

Noto Nastaliq defines a second anchor on a number of glyphs (see the `..Alt..` classes in the `fee/anchors.fee` file) as an alternative position for a glyph when dots will either collide (بپ, for example) or just not look very Nastaliq (try the sequence 'بببب' for an example). Mostly this deals with medial beh.

Lookups 161 and 162 switch marks for their `Alt` variants based on collision rules, and this is implemented in `rlig-alt-dot-position.fea`.

### Alternate Forms of Gaf and Kaf

Next, we look at gaf-kaf problems: multiple gafs or kafs in a row, connections between kafs and other letters and, in lookup 165, interactions between keheh and kaf. (This is, incidentally, incomplete - the "word" کػک causes a collision!) Lookups 164 and 165 can be found in `rlig-kaf-gaf.fea`.

### Finishing Off

First, we finish off the yeh barree work, mostly by default with the spacer glyphs. Here's another handy map:


|Lookup ID(s)|Meaning|
|-|-|
|117-122|Add 0-5 to a single spacer after init not followed by ybMk|
|123-128|
|129-134|Add 0-5 respectively to the value of a spacer|
|159|Add two sp0s after a glyph|
|160|Add a ybMk before a spacer|

XXX

Finally, we delete all the `ybMk` marker glyphs, and consolidate multiple spaces into the largest space. (`rlig-sum-spacers.fea`)

## Positioning Rules

After all that madness, the positioning side is actually completely straightforward.

### Cursive Positioning

Nothing interesting to see here; look in `curs-kerning.fea`.

### Spacers

Now we finally put those spacing glyphs to use: each one of them adds a multiple of 61 units to the previous glyph - `sp2` adds 132 units, `sp3`
adds 193 units and so on. This is done in `curs-kerning.fea`.

### Mark to Mark and Mark to Base Anchors

There's nothing special here. In my source, the anchors have been generated
by the FEE file `fee/anchors.fea`. The small and enclosed numbers we created in our second GSUB routine are implemented here using mark-to-ligature positioning. I haven't implemented those in `FontFeatures` yet, so I generated
those by hand.

