
bracket_wall_thickness = 6;
bracket_height = 28;
bracket_length = 50;
dovetail_thickness = 0.257 * 25.4;
dovetail_major_length = 1.1 * 25.4;
dovetail_minor_length = 0.92 * 25.4;
tool_clearance_gap = 0.25;
tool_count = 5;
tool_spacing = 32;

m4_include(lib/gridfinity_base.scad.m4)m4_dnl

module tool_holder_post() {
    translate([bracket_wall_thickness, 0, 0])
    linear_extrude(bracket_height)
    polygon(points=[
        [-bracket_wall_thickness, bracket_length/2],
        [0, bracket_length/2],
        
        [0, dovetail_minor_length/2 - tool_clearance_gap],
        [dovetail_thickness, dovetail_major_length/2 - tool_clearance_gap],
        [dovetail_thickness, -dovetail_major_length/2 + tool_clearance_gap],
        [0, -dovetail_minor_length/2 + tool_clearance_gap],
        
        [0, -bracket_length/2],
        [-bracket_wall_thickness, -bracket_length/2],
    ]);
    
    module fillet() {
        radius = (42*2 - bracket_length) / 2;
        translate([0, -radius, radius])
        rotate([0, 90, 0])
        difference() {
            translate([radius/2, radius/2, bracket_wall_thickness/2])
            cube([radius, radius, bracket_wall_thickness], center=true);
            translate([0, 0, -0.05])
            cylinder(r=radius, h=bracket_wall_thickness+0.1, $fn=50);
        }
    }
    translate([0, -bracket_length/2, 0]) fillet();
    translate([+bracket_wall_thickness, bracket_length/2, 0]) rotate([0, 0, 180]) fillet();
    
}

module lathe_tool_holder_bin() {
   gridfinity_base(4, 2, 1, stacking_lip=false);

   for (i = [0:tool_count-1])
   translate([i*tool_spacing, 2*42/2, 7])
   tool_holder_post();
}

lathe_tool_holder_bin();
