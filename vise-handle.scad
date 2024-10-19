//$fn = 50;

ball_diameter = 25.4 + 1;
short_section_length = 38;

narrow_diameter = 11.5 + 2;
long_section_length = 104;

inner_diameter = 19 + 2;

rotaty_bit_length = 42;

gridx = 5;
gridy = 1;
gridz = 3;

module vise_handle() {
    translate([rotaty_bit_length + long_section_length + short_section_length, 0, 0]) sphere(d=ball_diameter);

    translate([rotaty_bit_length + long_section_length, 0, 0])
    rotate([0,90,0]) cylinder(h=short_section_length+0.01, d1=narrow_diameter, d2=ball_diameter);

    translate([rotaty_bit_length, 0, 0])
    rotate([0,90,0]) cylinder(h=long_section_length+0.01, d1=inner_diameter, d2=narrow_diameter);

    translate([rotaty_bit_length, 0, 0])
    rotate([90, 0, 0]) cylinder(h=19+0.01, d=19 + 1, center=true);

    rotate([0, 90, 0]) cylinder(h=20+0.01, d=27 + 1);

    intersection() {
        union() {
            translate([20, 0, 0]) rotate([0, 90, 0]) cylinder(h=7.01, d1=27 + 1, d2=34.5 + 2);
            translate([27, 0, 0]) rotate([0, 90, 0]) cylinder(h=25.41, d=34.5 + 2);
        }
        translate([27, 0, 0]) cube([2*25.4, 2*27, 27 + 1], center=true);
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

module vise_handle_bin() {
    gridz=3;
    difference() {
        gridfinity_base(gridx, gridy, gridz, stacking_lip=true);
        translate([8, gridy*42/2, gridz*7]) {
           vise_handle();
            
           //thumbs
           translate([rotaty_bit_length + 1/3*long_section_length, 0, 0]) resize([35, 35, 16.5]) sphere(d=35);
       }
    }
}

vise_handle_bin();
