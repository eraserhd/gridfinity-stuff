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

m4_include(lib/gridfinity_base.scad.m4)m4_dnl

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
