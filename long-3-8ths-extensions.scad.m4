$fn = 50;


m4_include(lib/gridfinity_base.scad.m4)m4_dnl

clearance = 0.5;
flange_diameter = 16.9;
flange_length = 17.75;
shaft_diameter = 12.5;

extension_lengths = [
    75,
    151,
    75 + 151 + 25.6 
];

module extension(length) {
    cylinder(d=shaft_diameter + 2*clearance, h=length + 4*clearance);
    cylinder(d=flange_diameter + 2*clearance, h=flange_length + clearance);
    
    translate([0, 0, flange_length + clearance - 0.05])
    cylinder(
        d1=flange_diameter + 2*clearance,
        d2=shaft_diameter + 2*clearance,
        h=7.5
    );
}

module long_extensions_bin() {
    gridx = 1;
    gridy = 7;
    gridz = 3;
    
    left_spacing = (gridy*42 - extension_lengths[0] - extension_lengths[1] - 8*clearance)/3;
    difference() {
        gridfinity_base(gridx, gridy, gridz, stacking_lip=false);
        
        translate([
            gridx*42*1/3-2,
            left_spacing,
            gridz*7
        ])
        rotate([-90, 0, 0]) extension(extension_lengths[0]);
        
        translate([
            gridx*42*1/3-2,
            2*left_spacing + extension_lengths[0],
            gridz*7
        ])
        rotate([-90, 0, 0]) extension(extension_lengths[1]);
        
        translate([
           gridx*42*2/3+2,
           (gridy*42 - extension_lengths[2] - 2*clearance) /2 + extension_lengths[2] + 2*clearance,
           gridz*7
        ])
        rotate([90, 0, 0]) extension(extension_lengths[2]);
    }
}

long_extensions_bin();
