$fn = 50;
shank_diameter = 3/8 * 25.4;
shank_clearance = 0.75;

gridx = 2;
gridy = 3;

minimum_spacing = 3;
angle = 30;

longest_tool = 3.5 * 25.4;
drawer_height = 2.56 * 25.4;

module _end_of_parameters() {}

gridz = 5;
rows = 3;
columns = floor(
    (gridx * 42 - minimum_spacing) / (shank_diameter + shank_clearance + minimum_spacing)
);

m4_include(lib/gridfinity_base.scad.m4)m4_dnl

module end_mill_cutout() {
    actual_spacing = (gridx * 42 - columns * shank_diameter) / (columns + 1);
    bottom_height = 5.5;
    cylinder_height = (gridz*7-bottom_height) / sin(angle);
    
    echo("cylinder_height = ", cylinder_height);

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
                   sin(angle) * longest_tool + 
                   2 * cos(angle) * (shank_diameter + shank_clearance)/2 +
                   2;
    echo("total height = ", total_height, "; drawer_height = ", drawer_height);
    assert(total_height < drawer_height);
}

module end_mill_tray() {
    difference() {
        gridfinity_base(gridx, gridy, gridz, stacking_lip=false);

        for (row = [0:rows-1])
        translate([
            0,
            ((shank_diameter + shank_clearance) / sin(angle) + minimum_spacing) * row,
            0,
        ])
        end_mill_cutout();
    }
}

end_mill_tray();
