
$fn = 50;

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

    translate([0, 0, handle_length]) cylinder(h=10, d= 11.0);
    translate([0, 0, handle_length + 10]) cylinder(h=8, d=7.0);
    translate([0, 0, handle_length + 10 + 8 - 0.1]) cylinder(h=9.1, d=3.15);
    translate([0, 0, handle_length + 10 + 8 + 2 + 24/2])
        rotate([0,90,0])
        intersection() {
            cylinder(h=3.15, d=24, center=true);
            translate([+3,0,0]) cube([19,24+1,3.15], center=true);
        }
}

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

module deburring_tool_bin() {
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
        rotate([-90,0,0]) edge_deburring_tool();
        sphere(r=0.5);
    }
    for (o = [0, 5])
    for (x = [-15, 15])
    for (y = [42*3-15, 42*3-5, 42*3+5, 42*3+15, 42*3+25])
        translate([x-sign(x)*o, y-o, -16]) cylinder(h=16.1, d=3.15 + 0.5);
    translate([0,70,0]) thumb_relief();
}
