// ===== INFORMATION ===== //
/*
 Lids for Gridfinity bins, with handles!
 
 All parametric, so you can easily change the sizes of the handles.
 
 This was modified from https://www.printables.com/model/645622-gridfinity-lids-with-handles ,
 chemistbyday, to avoid needing GridFinity Rebuilt and a development build of OpenSCAD, just
 because those are too painful for me to install on NixOS.
 
 This is licensed under:
 Creative Commons (4.0 International License) Attribution—Noncommercial—Share Alike
*/

// ===== PARAMETERS ===== //

/* [Setup Parameters] */
// angle resolution (16 is a good draft setting, but recommend setting to 2 or 4 before final render)
$fa = 16;
$fs = 0.25;

/* [General Settings] */
// number of bases along x-axis
gridx = 2;  
// number of bases along y-axis   
gridy = 2;  
// base unit
length = 42;
// total lid height (note: thickness of flat portion will be about height - 5)
height = 7.5;

/* [Handle Settings] */
// length of handle as a fraction of total x width - note that I found 0.9 worked nicely for lids 1 grid unit wide and 0.4 was good for lids 5 grid units wide, and this calculation does a pretty good job of making reasonable choices in between
handle_scale = 0.9/sqrt(gridx);
// thickness of handle
handle_thickness = 5;
// height of handle
handle_height = 17.5; // NOTE: for handles that scale a little more gracefully with the x dimension, try handle_height = 12.5 + gridx*1
// radius of the indent circle (before handle is stretched into an ellipse)
indent_radius = 15; // NOTE: if you define the handle height to vary with gridx as suggested above, replace this line with indent_radius = handle_height-2.5
// depth of indent
indent_depth = 1.5;

// ===== IMPLEMENTATION ===== //

// https://files.printables.com/media/prints/417152/pdfs/417152-gridfinity-specification-b1e2cca5-0872-4816-b0ca-5339e5473e13.pdf

module gridfinity_base(
    gridx,
    gridy,
    height,
    stacking_lip=true,
    solid_height=undef
) {
    x_center_offset = (gridx * 42 - 0.5)/2.0 - 3.75;
    y_center_offset = (gridy * 42 - 0.5)/2.0 - 3.75;
    full_width_height = (is_undef(solid_height) ? height*7 : solid_height) - 2.15 - 1.8 - 0.8;
    empty_height = is_undef(solid_height) ? undef : height*7 - solid_height;
    lip_width = 2.6;
    outside_radius = 3.75;
    inside_radius = outside_radius - lip_width;
    lip_inset = outside_radius + 0.25;

    module layer(gridx, gridy, z, height, bottom_radius, top_radius, r) {
        br = is_undef(bottom_radius) ? r : bottom_radius;
        tr = is_undef(top_radius) ? r : top_radius;
        hull()
        for (x = [4.0, gridx*42.0-4.0])
            for (y = [4.0, gridy*42.0-4.0])
                translate([x,y,z]) cylinder(h=height, r1=br, r2=tr);
    }
    module cell_layer(z, height, bottom_radius, top_radius, r) {
        layer(gridx=1, gridy=1, z=z, height=height, bottom_radius=bottom_radius, top_radius=top_radius, r=r);
    }
    module base_layer(z, height, bottom_radius, top_radius, r) {
        layer(gridx=gridx, gridy=gridy, z=z, height=height, bottom_radius=bottom_radius, top_radius=top_radius, r=r);
    }
    module cell_base() {
        cell_layer(z=0.0, height=0.8, bottom_radius=0.8, top_radius=1.6);
        cell_layer(z=0.8, height=1.8, bottom_radius=1.6, top_radius=1.6);
        cell_layer(z=2.6, height=2.15, bottom_radius=1.6, top_radius=3.75);
    }
    module lip_profile() {
        function roundover_at(angle) = let (
            radius = 0.5,
            x = outside_radius - radius,
            y = 3.69 - radius
        ) [ x + radius * sin(angle), y + radius * cos(angle) ];
        polygon(points=[
            [ outside_radius - lip_width  ,   0 ],
            [ outside_radius - 1.9        , 0.7 ],
            [ outside_radius - 1.9        , 0.7 + 1.8 ],
            for (angle = [-45, -30, 0, 30, 45, 60, 90]) roundover_at(angle),
            [ outside_radius              ,   0 ],
            [ outside_radius - lip_width  ,   0 ]
        ]);
    }
    module lip_side(grids) {
        rotate([90,0,0]) linear_extrude(grids*42.0 - 2 * lip_inset) lip_profile();
        rotate_extrude(angle=90) lip_profile();
    }
    module stacking_lip() {
        translate([gridx*42.0 - lip_inset, gridy*42.0 - lip_inset, height*7]) lip_side(gridy);
        translate([lip_inset, lip_inset, height*7]) rotate([0,0,180]) lip_side(gridy);
        translate([gridx*42.0 - lip_inset, lip_inset, height*7]) rotate([0,0,-90]) lip_side(gridx);
        translate([lip_inset, gridy*42 - lip_inset, height*7]) rotate([0,0,90]) lip_side(gridx);
    }

    module solid_part() {
        for (x = [0:gridx-1])
            for (y = [0:gridy-1])
                translate([x*42.0, y*42.0, 0])
                    cell_base();

        base_layer(z=4.75, height=full_width_height, r=outside_radius);

        if (!is_undef(empty_height)) {
            difference() {
                base_layer(z=solid_height, height=empty_height, r=outside_radius);
                base_layer(z=solid_height, height=empty_height+0.1, r=inside_radius);
            }
        }

        if (stacking_lip) {
            stacking_lip();
        }
    }

    difference() {
        solid_part();
        translate([gridx*42/2, gridy*42/2, height*7]) children();
    }

    if (!is_undef(solid_height)) {
        empty_height = height - solid_height;
    }

}

module handle(){
    translate([0,0,height])
    scale([handle_scale*(gridx*length-0.5)/(2*handle_height),1,1])
    translate([0,handle_thickness/2,0])
    rotate([90,0,0])
    
    difference(){
        cylinder(r = handle_height, h = handle_thickness);
        
        union(){
            //translate([0,handle_height/2,handle_thickness])
            translate([0,0,handle_thickness])
                scale([1,1,indent_depth/indent_radius])
                sphere(r=indent_radius);
            
            //translate([0,handle_height/2,0])
                scale([1,1,indent_depth/indent_radius])
                sphere(r=indent_radius);
            
            translate([0,-handle_height,0])
            cube([2*handle_height,2*handle_height,2*handle_height],center=true);
        }
    }
}

module lid(gridx, gridy, height) {
  gridfinity_base(gridx, gridy, height=height/7, stacking_lip=false);
  translate([gridx*42/2, gridy*42/2, 0]) handle();
}

lid(gridx, gridy, height);
