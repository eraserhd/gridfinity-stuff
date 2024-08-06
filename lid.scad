// ===== INFORMATION ===== //
/*
 Lids for Gridfinity bins, with handles!
 
 All parametric, so you can easily change the sizes of the handles.
 
 NOTE: this file depends on kennetek's "Gridfinity Rebuilt in OpenSCAD" code (https://github.com/kennetek/gridfinity-rebuilt-openscad).  You MUST download these files and put them in the same folder as this file for this file to run. 

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

/* [Base] */
// number of divisions per 1 unit of base along the X axis. (default 1, only use integers. 0 means automatically guess the right division)
div_base_x = 0;
// number of divisions per 1 unit of base along the Y axis. (default 1, only use integers. 0 means automatically guess the right division)
div_base_y = 0; 



// ===== IMPLEMENTATION ===== //

module gridfinity_base(gridx, gridy, height, stacking_lip = true) {
    x_center_offset = (gridx * 42 - 0.5)/2.0 - 3.75;
    y_center_offset = (gridy * 42 - 0.5)/2.0 - 3.75;
    full_width_height = height * 7 - 2.15 - 1.8 - 0.8;
    lip_width = 2.6;
    outside_radius = 3.75;

    module cell_base() {
        module layer(z, height, bottom_radius, top_radius) {
            hull()
            for (x = [4.0, 42.0-4.0])
                for (y = [4.0, 42.0-4.0])
                    translate([x,y,z]) cylinder(h=height, r1=bottom_radius, r2=top_radius);
        }
        layer(z=0.0, height=0.8, bottom_radius=0.8, top_radius=1.6);
        layer(z=0.8, height=1.8, bottom_radius=1.6, top_radius=1.6);
        layer(z=2.6, height=2.15, bottom_radius=1.6, top_radius=3.75);
    }

    for (x = [0:gridx-1])
        for (y = [0:gridy-1])
            translate([x*42.0, y*42.0, 0])
                cell_base();

    hull()
    for (x = [4.0, gridx * 42.0 - 4.0])
        for (y = [4.0, gridy * 42.0 - 4.0])
            translate([x,y, 4.75]) cylinder(h=full_width_height, r=3.75);

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
            for (angle = [-45, -30, 0, 30, 45, 90]) roundover_at(angle),
            [ outside_radius              ,   0 ],
            [ outside_radius - lip_width  ,   0 ]
        ]);
    }

    lip_inset = outside_radius + 0.25;

    module lip_side(grids) {
        rotate([90,0,0]) linear_extrude(grids*42.0 - 2 * lip_inset) lip_profile();
        rotate_extrude(angle=90) lip_profile();
    }

    if (stacking_lip) {
        translate([gridx*42.0 - lip_inset, gridy*42.0 - lip_inset, height*7]) lip_side(gridy);
        translate([lip_inset, lip_inset, height*7]) rotate([0,0,180]) lip_side(gridy);
        translate([gridx*42.0 - lip_inset, lip_inset, height*7]) rotate([0,0,-90]) lip_side(gridx);
        translate([lip_inset, gridy*42 - lip_inset, height*7]) rotate([0,0,90]) lip_side(gridx);
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

lid(6,2,height);

