$fn = 50;

v_block_width  = 14.78;
v_block_length = 50;
v_block_height = 20.56;

m4_include(lib/gridfinity_base.scad.m4)m4_dnl

module v_block_cutout() {
    cube([v_block_width+1, v_block_length+1, v_block_height], center=true);
}

module v_blocks_bin() {
    difference() {
        gridfinity_base(1, 2, 2);

        extra_space = 42 - 2*v_block_width;
        spacing = extra_space/3;

        translate([v_block_width/2 + spacing, 42, 3*7]) v_block_cutout();
        translate([v_block_width/2 + v_block_width + 2*spacing, 42, 3*7]) v_block_cutout();
    }
}

v_blocks_bin();
