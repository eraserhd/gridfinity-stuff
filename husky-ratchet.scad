
$fn = 50;

clearance = 0.5;
head_diameter = 32.9;
head_thickness = 14.2;
head_minor_diameter = 27;
head_minor_distance = 26;
drive_flange_diameter = 13.9;
drive_flange_depth = 11.8;

top_of_head_to_second_handle_diameter = 97 - 13.5;

// https://files.printables.com/media/prints/417152/pdfs/417152-gridfinity-specification-b1e2cca5-0872-4816-b0ca-5339e5473e13.pdf

module gridfinity_base(gridx, gridy, height, stacking_lip=true, solid_height=undef) {
    x_center_offset = (gridx * 42 - 0.5)/2.0 - 3.75;
    y_center_offset = (gridy * 42 - 0.5)/2.0 - 3.75;
    full_width_height = (is_undef(solid_height) ? height*7 : solid_height) - 2.15 - 1.8 - 0.8;
    empty_height = is_undef(solid_height) ? undef : height*7 - solid_height;
    lip_width = 2.6;
    outside_radius = 3.75;
    inside_radius = outside_radius - lip_width;
    lip_inset = outside_radius + 0.25;

    module layer(gridx, gridy, z, height, bottom_radius, top_radius, r) {
        br = is_undef(bottom_radius) ? r : bottom_radius;
        tr = is_undef(top_radius) ? r : top_radius;
        hull()
        for (x = [4.0, gridx*42.0-4.0])
            for (y = [4.0, gridy*42.0-4.0])
                translate([x,y,z]) cylinder(h=height, r1=br, r2=tr);
    }
    module cell_layer(z, height, bottom_radius, top_radius, r) {
        layer(gridx=1, gridy=1, z=z, height=height, bottom_radius=bottom_radius, top_radius=top_radius, r=r);
    }
    module base_layer(z, height, bottom_radius, top_radius, r) {
        layer(gridx=gridx, gridy=gridy, z=z, height=height, bottom_radius=bottom_radius, top_radius=top_radius, r=r);
    }
    module cell_base() {
        cell_layer(z=0.0, height=0.8, bottom_radius=0.8, top_radius=1.6);
        cell_layer(z=0.8, height=1.8, bottom_radius=1.6, top_radius=1.6);
        cell_layer(z=2.6, height=2.15, bottom_radius=1.6, top_radius=3.75);
    }
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
    module lip_side(grids) {
        rotate([90,0,0]) linear_extrude(grids*42.0 - 2 * lip_inset) lip_profile();
        rotate_extrude(angle=90) lip_profile();
    }
    module stacking_lip() {
        translate([gridx*42.0 - lip_inset, gridy*42.0 - lip_inset, height*7]) lip_side(gridy);
        translate([lip_inset, lip_inset, height*7]) rotate([0,0,180]) lip_side(gridy);
        translate([gridx*42.0 - lip_inset, lip_inset, height*7]) rotate([0,0,-90]) lip_side(gridx);
        translate([lip_inset, gridy*42 - lip_inset, height*7]) rotate([0,0,90]) lip_side(gridx);
    }

    for (x = [0:gridx-1])
        for (y = [0:gridy-1])
            translate([x*42.0, y*42.0, 0])
                cell_base();

    base_layer(z=4.75, height=full_width_height, r=outside_radius);

    if (!is_undef(empty_height)) {
        difference() {
            base_layer(z=solid_height, height=empty_height, r=outside_radius);
            base_layer(z=solid_height, height=empty_height+0.1, r=inside_radius);
        }
    }

    if (stacking_lip) {
        stacking_lip();
    }

    if (!is_undef(solid_height)) {
        empty_height = height - solid_height;
    }
}

module head() {
    hull() {
        translate([0,0,-head_thickness/2])
        cylinder(d=head_diameter + 2*clearance, h=head_thickness);

        translate([0, head_minor_distance, -head_thickness/2])
        cylinder(d=head_minor_diameter + 2*clearance, h=head_thickness);

        translate([0, top_of_head_to_second_handle_diameter - 44, 0])
        rotate([90,0,0])
        cylinder(d=13.5 + clearance/2, h=0.1);
    }

    translate([0, 0, -drive_flange_depth-clearance-head_thickness/2])
    cylinder(d=drive_flange_diameter + 2*clearance, h=drive_flange_depth+clearance);
}

module shaft() {
    translate([
       0,
       top_of_head_to_second_handle_diameter - 44,
       0
    ])
    rotate([-90,0,0])
    rotate_extrude()
    polygon(points=[
        [ 0                  , 139   ],
        [ 14.2/2 + clearance , 139   ],
        [ 14.2/2 + clearance , 131.5 ],
        [ 11.5/2 + clearance , 126.4 ],
        [ 14.7/2 + clearance , 105   ],
        [ 15.5/2 + clearance , 49    ],
        [ 11.2/2 + clearance , 44    ],
        [ 13.5/2 + clearance , 0     ],
        [ 0 , 0     ],
    ]);
}

module cutout() {
    translate([0, head_diameter/2 + clearance, 0]) {
        head();
        shaft();
    }
}

module ratchet_bin() {
    gridz = ceil(1 + (head_thickness/2 + drive_flange_depth + clearance)/7);
    gridx = ceil(head_diameter/42);
    gridy = 5;

    difference() {
        gridfinity_base(gridx, gridy, gridz, stacking_lip=false);
        translate([gridx*42/2, 6.5, gridz*7]) cutout();

        hull() {
           translate([5, 92, gridz*7]) resize([6,25.4,11.8+2*clearance]) sphere(d=11.8+2*clearance);
           translate([42-5, 92, gridz*7]) resize([6,25.4,11.8+2*clearance]) sphere(d=11.8+2*clearance);
        }
    }
}

ratchet_bin();
