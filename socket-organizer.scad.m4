//=============Read me=============//
/*Original gridfinity utility here:
https://www.printables.com/model/274917-gridfinity-rebuilt-in-openscad

Original Author's note (still true, as of 09/2023 you still need to get a nightly build not an official release build):
"IMPORTANT: rendering will be better for analyzing the model if fast-csg is enabled. As of writing, this feature is only available in the development builds and not the official release of OpenSCAD, but it makes rendering only take a couple seconds, even for comically large bins. Enable it in Edit > Preferences > Features > fast-csg"



Basic information:
-Fill out list of holes with measured size in mm and desired label text.
-Order of list will determine position, starting at bottom left or right (depending on primary label side).
-Overall size is determined by pattern, size of holes, and gridfinity units
-using a standard 42mm gridfinity base unit results in a lot of wasted space; I recommend keeping defualt baseplate size, but using half size on the socket holder par.
-Use other parameters as needed and as described.
-Double check labels work with list



"text_primary_side" Notes:
Setting left and right label side also controls Left-to-Right vs Right-to-Left building of hole pattern.
With 4 columns this only sets order of hole population. "right" builds left to right, bottom to top (with labels on the right). Setting the "text_primary_side" to the left moves labels to the left side and builds the hole pattern from right to left, bottom to top. This works out so that labels will read in the same order as the input list in most cases.
If using 4 wide grid though, pay attention to label output; if you want to read ascending or descending you may have to manually rearrange list.

*/

//=============PRIMARY PARAMETERS=============//


//list of hole diameter and string of label. Hole clearance gets added later, so measured diameter goes here. Order of list determines position in grid.
holes=[
    [ 17.2, "8"  ],
    [ 16.9, "10" ],
    [ 17.2, "12" ],
    [ 18.2, "13" ],
    [ 19.5, "14" ],
    [ 23.4, "17" ],
    [ 25.7, "19" ],
];

depth=15; //depth of hole, should not be deeper than depth internal from gridfinity section

patternx=2; //how many columns of holes? {2-4}. Num rows is determined by how many holes there are

text_primary_side="right"; //Labels on left or right side, also controls Left-to-Right vs Right-to-Left building of holes.

dynamic_spacing=true; //true (no quotes) squeezes rows together as possible, false  is consistant spacing based on largest hole diameter

length = 42; //Gridfinity base unit length (default 42, 21 works best for best use of space with default grid pieces)

enable_lip = false; //Whether to add the stacking lip

hole_clearance=0.75; //oversize holes by this much. and also used for line clearance


//=============Secondary Parameters (that shouldn't need changed) =============//

 //STUFF FROM ORIGINAL UTILITY THAT SHOULDN'T NEED TO BE TOUCHED
/* [Setup Parameters] */
$fa = 8;
$fs = 0.25;
$fn=30;

module _end_of_parameters() {}

m4_include(lib/socket_organizer.scad.m4)m4_dnl

socket_organizer(
    holes=holes,
    text_primary_side=text_primary_side,
    depth=depth,
    patternx=patternx,
    dynamic_spacing=dynamic_spacing,
    length=length,
    enable_lip=enable_lip,
    hole_clearance=hole_clearance
);
