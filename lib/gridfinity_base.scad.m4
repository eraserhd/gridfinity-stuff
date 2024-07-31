module gridfinity_base(gridx, gridy, gridz) {
    x_center_offset = (gridx * 42 - 0.5)/2.0 - 3.75;
    y_center_offset = (gridy * 42 - 0.5)/2.0 - 3.75;
    full_width_height = gridz * 7 - 2.15 - 1.8 - 0.8;

    module bottom_cell_layer(height, bottom_radius, top_radius) {
        radius_offset = 41.5/2.0 - 3.75;
        hull()
        for (x = [-radius_offset, +radius_offset]) {
            for (y = [-radius_offset, +radius_offset]) {
                translate([x,y])
                    cylinder(h=height, r1=bottom_radius, r2=top_radius);
            }
        }
    }

    module single_bottom_cell() {
        translate([+42.0/2.0, 42.0/2.0, 0.0])
            bottom_cell_layer(height = 0.8,  bottom_radius=0.8, top_radius=1.6);
        translate([+42.0/2.0, 42.0/2.0, 0.8])
            bottom_cell_layer(height = 1.8,  bottom_radius=1.6, top_radius=1.6);
        translate([+42.0/2.0, 42.0/2.0, 2.6])
            bottom_cell_layer(height = 2.15, bottom_radius=1.6, top_radius=3.75);
    }

    for (x = [0:gridx-1]) {
        for (y = [0:gridy-1]) {
            translate([x*42.0, y*42.0, 0])
                single_bottom_cell();
        }
    }

    hull()
    for (x = [4.0, gridx * 42.0 - 4.0]) {
        for (y = [4.0, gridy * 42.0 - 4.0]) {
            translate([x,y, 4.75])
                cylinder(h=full_width_height, r=3.75);
        }
    }
}
