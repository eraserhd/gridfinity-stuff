
$fn = 50;

module hole_deburring_tool() {
    handle_length = 90.5;
    handle_radius = 19/2;
    shaft_length = 14;
    shaft_radius = 12.1/2;
    top_roundover_radius = 0.5;
    bottom_roundover_radius = 4;

    rotate_extrude()
    hull() {
        translate([handle_radius - top_roundover_radius, handle_length - top_roundover_radius])
        circle(r=top_roundover_radius);

        translate([handle_radius - bottom_roundover_radius, bottom_roundover_radius])
        circle(r=bottom_roundover_radius);
    }

    cylinder(h=handle_length + shaft_length, r=shaft_radius);

    translate([0,0, 90.5 + 14])
    cylinder(h=3, d=20.5);

    translate([0,0, 90.5 + 14 + 3])
    cylinder(h=11.5, d1=20.5, d2=0);
}

module edge_deburring_tool() {
    handle_length = 100.5;
    handle_taper_start = 86;
    handle_radius = 19/2;
    handle_narrow_radius = 12/2;
    top_roundover_radius = 0.5;
    bottom_roundover_radius = 4;
    // 86 100.5

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

module gridfinity_base(gridx, gridy, gridz, stacking_lip = true) {
    x_center_offset = (gridx * 42 - 0.5)/2.0 - 3.75;
    y_center_offset = (gridy * 42 - 0.5)/2.0 - 3.75;
    full_width_height = gridz * 7 - 2.15 - 1.8 - 0.8;
    lip_height = 4.4;
    lip_thickness = 2;
    outside_radius = 3.75;

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

    module lip_profile() {
        polygon(points=[
            [   0       ,   0 ],
            [ 0.7       , 0.7 ],
            [ 0.7       , 0.7 + 1.8 ],
            [ 0.7 + 1.9 , 0.7 + 1.8 + 1.9 ],
            [ 0.7 + 1.9 ,   0 ],
            [   0       ,   0 ]
        ]);
    }

    module lip_straight(grids) {
        rotate([90,0,0])
            linear_extrude(grids * 42.0 - 2 * outside_radius)
            lip_profile();
    }

    if (stacking_lip) {
        // 2.6 = lip_width
        translate([gridx*42.0 - 2.6 - 0.25, gridy*42.0 - outside_radius, gridz*7]) lip_straight(gridy);
        translate([0.25 + 2.6, outside_radius, gridz*7]) rotate([0,0,180]) lip_straight(gridy);
        translate([gridx*42.0 - outside_radius + 0.25, 2.6, gridz*7]) rotate([0,0,-90]) lip_straight(gridx);
        translate([outside_radius + 0.25, gridy*42 - 2.6 - 0.25, gridz*7]) rotate([0,0,90]) lip_straight(gridx);
    }
}

//TODO: Lip
//TODO: blade holes
//TODO: place for blade on handle
//TODO: fix hole deburring handle holes
//TODO: Extract gridfinity_base somehow

module deburring_tool_bin() {
    spacing = 30;
    handle_diameter = 19;
    gridz = 3;

    difference() {
        gridfinity_base(1, 4, gridz, stacking_lip=true);

        translate([21, 15, gridz*7])
        rotate([-90,0,0])
        children();
    }
}

deburring_tool_bin() edge_deburring_tool();
