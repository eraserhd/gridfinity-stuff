
$fn = 50;
clearance = 0.5;
diameter = 12.41;
collar_diameter = 17;
collar_length = 18.2;
taper_length = 7.65;

turny_thinger_diameter = 19;
turny_thinger_length = 51.6;
turny_thinger_nub_length = 10.5;
turny_thinger_nub_diameter = 12.3;
turny_thinger_taper_length = 4.5;

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

module extension(length) {
   cylinder(d=diameter + 2*clearance, h=length + 2*clearance);
   cylinder(d=collar_diameter + 2*clearance, h=collar_length + clearance);

   translate([0,0,collar_length+clearance])
   cylinder(d1=collar_diameter + 2*clearance,
            d2=diameter + 2*clearance,
            h=taper_length);
}

module turny_thinger() {
    fat_length = turny_thinger_length - turny_thinger_nub_length - turny_thinger_taper_length;
    translate([0, 0, -clearance])
    cylinder(d=turny_thinger_diameter + 2*clearance, h=fat_length + clearance);
    
    translate([0, 0, fat_length]) 
    cylinder(d1=turny_thinger_diameter + 2*clearance,
             d2=turny_thinger_nub_diameter + 2*clearance,
             h=turny_thinger_taper_length);
             
    translate([0, 0, fat_length + turny_thinger_taper_length]) 
    cylinder(d=turny_thinger_nub_diameter + 2*clearance, h=turny_thinger_nub_length+clearance);
}

module ratchet_extension_bin() {
    gridx = 1;
    gridy = 4;
    gridz = 3;

    space_from_end = (gridy*42 - 6*25.4)/2;

    difference() {
        gridfinity_base(gridx, gridy, gridz, stacking_lip=false);
        
        translate([
            (gridx*42*1/3)-2,
            space_from_end,
            gridz*7
        ])
        rotate([-90,0,0])
        extension(6*25.4);

        translate([
            (gridx*42*2/3)+2,
            3*25.4 + space_from_end + clearance,
            gridz*7
        ])
        rotate([90,0,0])
        extension(3*25.4);

        translate([
            (gridx*42*2/3)+2,
            3*25.4 + 3*space_from_end + 2*clearance,
            gridz*7 
        ])
        rotate([-90,0,0])
        turny_thinger();
    }
}

ratchet_extension_bin();
