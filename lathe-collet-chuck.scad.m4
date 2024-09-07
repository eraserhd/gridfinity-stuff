$fn = 50;

diameter = 100;
cutout_depth = 7;
gridz = 2;

m4_include(lib/gridfinity_base.scad.m4)m4_dnl

module lathe_collet_chuck() {
    difference() {
        gridfinity_base(3, 3, gridz);
        translate([42*3/2, 42*3/2, 7*gridz])
            cylinder(d=diameter+2, h=2*cutout_depth, center=true);
    }
}

lathe_collet_chuck();
