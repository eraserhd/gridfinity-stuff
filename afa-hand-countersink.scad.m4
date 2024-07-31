
$fn = 50;

module hole_deburring_head() {
    shaft_length = 14;
    shaft_radius = 12.1/2;
    cylinder(h=shaft_length, r=shaft_radius);

    translate([0,0, shaft_length])
    cylinder(h=3, d=20.5);

    translate([0,0, shaft_length + 3])
    cylinder(h=11.5, d1=20.5, d2=0);
}

module hole_deburring_tool() {
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

    translate([0, 0, 90.5]) hole_deburring_head();
}

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

    cylinder(h=handle_length + 10, d= 11.0);
    cylinder(h=handle_length + 10 + 8, d= 7.0);
}

m4_include(lib/gridfinity_base.scad.m4)m4_dnl

//TODO: blade holes
//TODO: place for blade on handle

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
        union() {
           translate([0,135,14]) rotate([180,0,0]) hole_deburring_head();
           rotate([-90,0,0]) hole_deburring_tool();
        }
        sphere(r=0.5);
    }
    translate([0,70,0]) thumb_relief();
}
