
$fn = 50;

module edge_deburring_tool() {
    handle_length = 100.5;
    handle_taper_start = 86;
    handle_radius = 19/2;
    handle_narrow_radius = 12/2;
    top_roundover_radius = 0.5;
    bottom_roundover_radius = 4;

    rotate_extrude()
    hull() {
        translate([handle_narrow_radius - top_roundover_radius, handle_length - top_roundover_radius])
        circle(r=top_roundover_radius);

        translate([handle_radius - top_roundover_radius, handle_taper_start - top_roundover_radius])
        circle(r=top_roundover_radius);

        translate([handle_radius - bottom_roundover_radius, bottom_roundover_radius])
        circle(r=bottom_roundover_radius);

        polygon(points=[
            [0, 0],
            [0, handle_length],
            [handle_narrow_radius - top_roundover_radius, handle_length],
            [handle_radius - top_roundover_radius, handle_taper_start],
            [handle_radius - bottom_roundover_radius, 0],
            [0, 0]
        ]);
    }

    translate([0, 0, handle_length]) cylinder(h=10, d= 11.0);
    translate([0, 0, handle_length + 10]) cylinder(h=8, d=7.0);
    translate([0, 0, handle_length + 10 + 8 - 0.1]) cylinder(h=9.1, d=3.15);
    translate([0, 0, handle_length + 10 + 8 + 9 + 24/2])
        rotate([0,90,0])
        intersection() {
            cylinder(h=3.15, d=24, center=true);
            translate([+3,0,0]) cube([19,24+1,3.15], center=true);
        }
}

m4_include(lib/gridfinity_base.scad.m4)m4_dnl

//TODO: blade holes

module deburring_tool_bin() {
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

deburring_tool_bin() {
    minkowski() {
        rotate([-90,0,0]) edge_deburring_tool();
        sphere(r=0.5);
    }
    for (o = [0, 5])
    for (x = [-15, 15])
    for (y = [42*3-15, 42*3-5, 42*3+5, 42*3+15, 42*3+25])
        translate([x-sign(x)*o, y-o, -16]) cylinder(h=16.1, d=3.15 + 0.5);
    translate([0,70,0]) thumb_relief();
}
