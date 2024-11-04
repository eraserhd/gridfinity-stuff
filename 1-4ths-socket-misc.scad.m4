$fn = 50;
clearance = 0.5;
three_eigths_to_one_quarter_diameter = 16.8;

sockety_things = [ 
    16.8, // three eigths to one quarter diameter
    14.21, // ???
    14.1, // angle bit
    11.8, // random extra bit
];

m4_include(lib/gridfinity_base.scad.m4)m4_dnl

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
