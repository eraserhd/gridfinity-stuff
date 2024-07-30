
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

        polygon(points=[
            [0, 0],
            [0, handle_length],
            [handle_radius - top_roundover_radius, handle_length],
            [handle_radius - bottom_roundover_radius, 0],
            [0, 0]
        ]);
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

module gridfinity_base(gridx, gridy, height, stacking_lip = true) {
    x_center_offset = (gridx * 42 - 0.5)/2.0 - 3.75;
    y_center_offset = (gridy * 42 - 0.5)/2.0 - 3.75;
    full_width_height = height * 7 - 2.15 - 1.8 - 0.8;
    lip_width = 2.6;
    outside_radius = 3.75;

    module cell_base() {
        module layer(z, height, bottom_radius, top_radius) {
            hull()
            for (x = [4.0, 42.0-4.0])
                for (y = [4.0, 42.0-4.0])
                    translate([x,y,z]) cylinder(h=height, r1=bottom_radius, r2=top_radius);
        }
        layer(z=0.0, height=0.8, bottom_radius=0.8, top_radius=1.6);
        layer(z=0.8, height=1.8, bottom_radius=1.6, top_radius=1.6);
        layer(z=2.6, height=2.15, bottom_radius=1.6, top_radius=3.75);
    }

    for (x = [0:gridx-1])
        for (y = [0:gridy-1])
            translate([x*42.0, y*42.0, 0])
                cell_base();

    hull()
    for (x = [4.0, gridx * 42.0 - 4.0])
        for (y = [4.0, gridy * 42.0 - 4.0])
            translate([x,y, 4.75]) cylinder(h=full_width_height, r=3.75);

    module lip_profile() {
        function roundover_at(angle) = let (
            radius = 0.5,
            x = outside_radius - radius,
            y = 3.69 - radius
        ) [ x + radius * sin(angle), y + radius * cos(angle) ];
        polygon(points=[
            [ outside_radius - lip_width  ,   0 ],
            [ outside_radius - 1.9        , 0.7 ],
            [ outside_radius - 1.9        , 0.7 + 1.8 ],
            for (angle = [-45, -30, 0, 30, 45, 90]) roundover_at(angle),
            [ outside_radius              ,   0 ],
            [ outside_radius - lip_width  ,   0 ]
        ]);
    }

    lip_inset = outside_radius + 0.25;

    module lip_side(grids) {
        rotate([90,0,0]) linear_extrude(grids*42.0 - 2 * lip_inset) lip_profile();
        rotate_extrude(angle=90) lip_profile();
    }
    
    if (stacking_lip) {
        translate([gridx*42.0 - lip_inset, gridy*42.0 - lip_inset, height*7]) lip_side(gridy);
        translate([lip_inset, lip_inset, height*7]) rotate([0,0,180]) lip_side(gridy);
        translate([gridx*42.0 - lip_inset, lip_inset, height*7]) rotate([0,0,-90]) lip_side(gridx);
        translate([lip_inset, gridy*42 - lip_inset, height*7]) rotate([0,0,90]) lip_side(gridx);
    }
}

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

deburring_tool_bin() hole_deburring_tool();
