$fn = 50;
clearance = 0.5;
three_eigths_to_one_quarter_diameter = 16.8;

sockety_things = [ 
    16.8, // three eigths to one quarter diameter
    14.21, // ???
    14.1, // angle bit
    11.8, // random extra bit
];

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

module extension() {
    cylinder(d=12.4 + 2*clearance, h=13 + clearance);
    translate([0, 0, 13 + clearance - 0.05])
    cylinder(d1=12.4 + 2*clearance, d2=8.1 + 2*clearance, h=5.5);
    cylinder(d=8.1 + 2*clearance, h=49.8 + 2*clearance);
}

module hex_driver() {
    cylinder(d=12.1 + 2*clearance, h=17.1 + clearance);
    translate([0, 0, 17.1+clearance-0.05])
    cylinder(d1=12.1 + 2*clearance, d2=7.72 + 2*clearance, h=(18.3-17.1));
    cylinder(d=7.72 + 2*clearance, h=27.4 + 2*clearance);
    cylinder(d=7 + 2*clearance, h=50.8 + 2*clearance);
}

module misc_bin() {
    gridx = 1;
    gridy = 3;
    gridz = 3;

    difference() {
        gridfinity_base(gridx, gridy, gridz, stacking_lip = false);
        translate([0, 0, gridz*7]) {
            for (i = [0:len(sockety_things)-1]) {
                translate([
                    42*2/3 + 2,
                    gridy*42 / len(sockety_things) * (i + 0.5),
                    0,
                ])
                cylinder(d=sockety_things[i] + 2*clearance, h=25.4, center=true);
            }
            
            translate([42*1/3 - 2, 10, 0])
            rotate([-90,0,0])
                extension();
                
            translate([42*1/3 - 2, gridy*42/2 + 3, 0])
            rotate([-90,0,0])
                hex_driver();
        }
        
    }
}

misc_bin();
