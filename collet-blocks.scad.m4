$fn = 50;

nut_diameter = 50;
nut_height = 35; // includes space for when it is partially unscrewed
block_height = 40;
square_block_width = 45;
hex_block_diameter = 47;

m4_include(lib/gridfinity_base.scad.m4)m4_dnl

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
