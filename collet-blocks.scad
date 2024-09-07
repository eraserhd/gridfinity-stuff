$fn = 50;

nut_diameter = 50;
nut_height = 35; // includes space for when it is partially unscrewed
block_height = 40;
square_block_width = 45;
hex_block_diameter = 47;

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

module square_collet_block() {
    translate([nut_diameter/2, 0, nut_diameter/2])
    rotate([-90, 0, 0]) {
        translate([0,0,(block_height+0.5)/2])
            cube([square_block_width+1, square_block_width+1, block_height+1], center=true);
        translate([0, 0, block_height])
            cylinder(d=nut_diameter+1, h=nut_height+0.1);
    }
}

module hex_collet_block() {
    translate([nut_diameter/2, 0, nut_diameter/2])
    rotate([-90, 0, 0]) {
        translate([0,0,(block_height+0.5)/2])
            cylinder(d=hex_block_diameter+1, h=block_height+1, $fn=6, center=true);
        translate([0, 0, block_height])
            cylinder(d=nut_diameter+1, h=nut_height+0.1);
    }
}

module collet_blocks_bin() {
    difference() {
        gridfinity_base(3, 2, 3);

        x_space = (42*3 - 51 - 51)/3;
        y_space = (42*2 - nut_height - block_height)/2;

        translate([x_space, y_space, 6]) square_collet_block();
        translate([2*x_space+nut_diameter, y_space, 6]) hex_collet_block();
    }
}

collet_blocks_bin();
