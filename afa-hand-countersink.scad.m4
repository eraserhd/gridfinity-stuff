
$fn = 50;

module hand_countersink_head() {
    shaft_length = 14;
    shaft_radius = 12.1/2;
    cylinder(h=shaft_length, r=shaft_radius);

    translate([0,0, shaft_length])
    cylinder(h=3, d=20.5);

    translate([0,0, shaft_length + 3])
    cylinder(h=11.5, d1=20.5, d2=0);
}

module hand_countersink_tool() {
    handle_length = 90.5;
    handle_radius = 19/2;
    top_roundover_radius = 0.5;
    bottom_roundover_radius = 4;

    rotate_extrude()
    hull() {
        translate([handle_radius - top_roundover_radius, handle_length - top_roundover_radius])
        circle(r=top_roundover_radius);

        translate([handle_radius - bottom_roundover_radius, bottom_roundover_radius])
        circle(r=bottom_roundover_radius);

        polygon(points=[
            [0, 0],
            [0, handle_length],
            [handle_radius - top_roundover_radius, handle_length],
            [handle_radius - bottom_roundover_radius, 0],
            [0, 0]
        ]);
    }

    translate([0, 0, 90.5]) hand_countersink_head();
}

m4_include(lib/gridfinity_base.scad.m4)m4_dnl

module tool_tray() {
    spacing = 30;
    handle_diameter = 19;
    gridz = 3;
    difference() {
        gridfinity_base(1, 4, gridz, stacking_lip=true);
        translate([21, 10, gridz*7]) children();
    }
}

module thumb_relief() {
    hull() {
        translate([-10,0,0]) scale([1.0,1.7,1.0]) sphere(d=15);
        translate([+10,0,0]) scale([1.0,1.8,1.0]) sphere(d=15);
    }
}

tool_tray() {
    minkowski() {
        union() {
           translate([0,135,14]) rotate([180,0,0]) hand_countersink_head();
           rotate([-90,0,0]) hand_countersink_tool();
        }
        sphere(r=0.5);
    }
    translate([0,70,0]) thumb_relief();
}
