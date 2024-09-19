
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

// https://files.printables.com/media/prints/417152/pdfs/417152-gridfinity-specification-b1e2cca5-0872-4816-b0ca-5339e5473e13.pdf

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
            translate([x,y, 4.75]) cylinder(h=full_width_height, r=outside_radius);

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
            for (angle = [-45, -30, 0, 30, 45, 60, 90]) roundover_at(angle),
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