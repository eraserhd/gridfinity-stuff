
$fn = 40;

m4_include(lib/gridfinity_base.scad.m4)m4_dnl

gridfinity_base(2, 2, 1);

translate([42, 42, 7])
cylinder(h=1.0 * 25.4, d=0.990 * 25.4);

//FIXME: Add chamfer to top
