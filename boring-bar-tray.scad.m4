$fn = 50;
shank_diameter = 3/8 * 25.4;
shank_length = 34;

count = 8;
minimum_spacing = 5;
longest = 3.5 * 25.4;
shortest = 34 + 18;

m4_include(lib/gridfinity_base.scad.m4)m4_dnl

module boring_bar_tray() {
    minimum_distance_from_bottom = 5;

    gridy = ceil((longest + 12) / 42);
    gridx = ceil((count * shank_diameter + (count + 1) * minimum_spacing)/42);
    gridz = ceil((minimum_distance_from_bottom + shank_diameter)/7);
    
    actual_distance_from_bottom = gridz*7 - shank_diameter/2;
    actual_spacing = (gridx*42 - 0.5 - shank_diameter*count) / (count + 1);
    actual_length = gridy*42 - 2*actual_spacing;

    difference() {
        gridfinity_base(gridx, gridy, gridz, solid_height=actual_distance_from_bottom);

        for (i = [0:count-1])
        translate([
            0.25 + actual_spacing + shank_diameter/2 + i*(shank_diameter + actual_spacing),
            actual_spacing,
            actual_distance_from_bottom
        ])
        rotate([-90, 0, 0])
        cylinder(d=shank_diameter + 0.5, h=actual_length);
    }
}

boring_bar_tray();

