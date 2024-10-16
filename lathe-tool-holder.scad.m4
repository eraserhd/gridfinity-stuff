
bracket_wall_thickness = 6;
bracket_height = 28;
bracket_length = 50;
dovetail_thickness = 0.257 * 25.4;
dovetail_major_length = 1.1 * 25.4;
dovetail_minor_length = 0.92 * 25.4;
tool_clearance_gap = 0.6;
tool_count = 5;
tool_spacing = 32;

m4_include(lib/gridfinity_base.scad.m4)m4_dnl

module tool_holder_post() {
    module fillet() {
        radius = (42*2 - bracket_length) / 2 * 3/4;
        translate([0, -radius, radius])
        rotate([0, 90, 0])
        difference() {
            translate([radius/2, radius/2, bracket_wall_thickness/2])
            cube([radius, radius, bracket_wall_thickness], center=true);
            translate([0, 0, -0.05])
            cylinder(r=radius, h=bracket_wall_thickness+0.1, $fn=100);
        }
    }
    
    module dovetail() {
        top_chamfer = 1.0;
        hull() {
        linear_extrude(bracket_height - top_chamfer)
        polygon(points=[
            [0, dovetail_minor_length/2 - tool_clearance_gap],
            [dovetail_thickness, dovetail_major_length/2 - tool_clearance_gap],
            [dovetail_thickness, -dovetail_major_length/2 + tool_clearance_gap],
            [0, -dovetail_minor_length/2 + tool_clearance_gap],
        ]);
	translate([0, 0, bracket_height - 0.1])
	linear_extrude(0.1)
        polygon(points=[
            [0, dovetail_minor_length/2 - tool_clearance_gap - top_chamfer],
            [dovetail_thickness - top_chamfer, dovetail_major_length/2 - tool_clearance_gap - top_chamfer],
            [dovetail_thickness - top_chamfer, -dovetail_major_length/2 + tool_clearance_gap + top_chamfer],
            [0, -dovetail_minor_length/2 + tool_clearance_gap + top_chamfer],
        ]);
        }
    }
    
    module post() {
        translate([bracket_wall_thickness, 0, 0])
        linear_extrude(bracket_height)
        polygon(points=[
            [-bracket_wall_thickness, bracket_length/2],
            [0, bracket_length/2],
            [0, -bracket_length/2],
            [-bracket_wall_thickness, -bracket_length/2],
        ]);

        translate([0, -bracket_length/2, 0]) fillet();
        translate([+bracket_wall_thickness, bracket_length/2, 0]) rotate([0, 0, 180]) fillet();
    }

    post();
    translate([bracket_wall_thickness, 0, 0]) dovetail();
}

module lathe_tool_holder_bin() {
   gridfinity_base(4, 2, 1, stacking_lip=false);

   for (i = [0:tool_count-1])
   translate([0.25 + i*tool_spacing, 2*42/2, 7])
   tool_holder_post();
}

lathe_tool_holder_bin();
