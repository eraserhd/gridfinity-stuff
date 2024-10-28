
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

m4_include(lib/gridfinity_base.scad.m4)m4_dnl

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
