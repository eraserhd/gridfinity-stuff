$fn = 50;
shank_diameter = 3/8 * 25.4;
shank_clearance = 0.75;

columns = 8;
minimum_spacing = 5;
angle = 30;

longest = 3.5 * 25.4;
drawer_height = 2.56 * 25.4;

module _end_of_parameters() {}

gridx = ceil((shank_diameter * columns + minimum_spacing * (columns + 1))/42);
gridy = 2;
gridz = 5;

m4_include(lib/gridfinity_base.scad.m4)m4_dnl

module bar_cutout() {
    actual_spacing = (gridx * 42 - columns * shank_diameter) / (columns + 1);
    bottom_height = 5.5;
    cylinder_height = (gridz*7-bottom_height) / sin(angle);

    translate([
        0,
        sin(angle) * shank_diameter/2 + minimum_spacing,
        cos(angle) * shank_diameter/2 + bottom_height,
    ])
    rotate([-90 + angle, 0, 0]) {
        for (i = [0:columns-1])
        translate([
            (i + 1/2) * shank_diameter + (i + 1)*actual_spacing,
            0,
            0
        ])
        cylinder(d=shank_diameter + shank_clearance, h=cylinder_height);
        
        translate([
            actual_spacing + shank_diameter/2,
            -(shank_diameter + shank_clearance)/2,
            0
        ])
        cube([
             (columns - 1) * shank_diameter + (columns - 1)*actual_spacing,
             shank_diameter/2 + shank_clearance,
             cylinder_height,
        ]);
    }

    // Make sure it will fit in the drawer.
    total_height = bottom_height +
                   sin(angle) * longest + 
                   2 * cos(angle) * (shank_diameter + shank_clearance)/2 +
                   2;
    echo("total height = ", total_height, "; drawer_height = ", drawer_height);
    assert(total_height < drawer_height);
}

module boring_bar_tray() {
    difference() {
        gridfinity_base(gridx, gridy, gridz, stacking_lip=false);
        bar_cutout();
    }
}

boring_bar_tray();
