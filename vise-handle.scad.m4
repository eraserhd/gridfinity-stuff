$fn = 50;

ball_diameter = 25.4;
short_section_length = 38;

narrow_diameter = 11.5;
long_section_length = 104;

inner_diameter = 19;

rotaty_bit_length = 42;

module vise_handle() {
    translate([rotaty_bit_length + long_section_length + short_section_length, 0, 0]) sphere(d=ball_diameter);

    translate([rotaty_bit_length + long_section_length, 0, 0])
    rotate([0,90,0]) cylinder(h=short_section_length, d1=narrow_diameter, d2=ball_diameter);

    translate([rotaty_bit_length, 0, 0])
    rotate([0,90,0]) cylinder(h=long_section_length, d1=inner_diameter, d2=narrow_diameter);
    
    translate([rotaty_bit_length, 0, 0])
    rotate([90, 0, 0]) cylinder(h=19, d=19, center=true);
    
    
    rotate([0, 90, 0]) cylinder(h=20, d=27);
    
    
    intersection() {
        union() {
        translate([20, 0, 0]) rotate([0, 90, 0]) cylinder(h=7, d1=27, d2=34.5);
        translate([27, 0, 0]) rotate([0, 90, 0]) cylinder(h=25.4, d=34.5);
        }
        translate([27, 0, 0]) cube([2*25.4, 2*27, 27], center=true);
    }
}

m4_include(lib/gridfinity_base.scad.m4)m4_dnl

module vise_handle_bin() {
    gridz=3;
    difference() {
       gridfinity_base(5, 1, gridz, stacking_lip=true);
       translate([8, 42/2, gridz*7]) {
           vise_handle();
           //thumbs
           translate([rotaty_bit_length + 1/3*long_section_length, 0, 0]) resize([35, 35, 16.5]) sphere(d=35);
       }
    }
}

vise_handle_bin();
