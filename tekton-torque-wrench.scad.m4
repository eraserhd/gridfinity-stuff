$fn = 50;

clearance = 0.5;
length = 220;

m4_include(lib/gridfinity_base.scad.m4)m4_dnl

module tekton_wrench() {
    parts = [
        // diameter, length, from bottom of handle up.
        [ 22  , 62   ],
        [ 20  , 5.12 ],
        [ 23.5, 25   ],
        [ 18  , 17   ],
        [ 15.1, 81.3 ],
    ];

    head_large_diameter = 21.5;
    head_small_diameter = 18.5;
    head_thickness = 9.6;
    head_small_diameter_distance = 7.7;
    head_large_diameter_distance = 7.7 + 11.9;
    nub_diameter = 8.8;

    module head() {
        rotate([90, 0, 0]) {
            translate([0, 0, -head_thickness/2])
            hull() {
                translate([0, head_large_diameter_distance, 0])
                cylinder(d=head_large_diameter, h=head_thickness);

                translate([0, head_small_diameter_distance, 0])
                cylinder(d=head_small_diameter, h=head_thickness);
            }

            translate([0, head_large_diameter_distance, -(18.4 - head_thickness)])
            cylinder(d=nub_diameter + 2*clearance, h=18.4);
        }
    }

    function offset(n) = n==0 ? 0 : parts[n-1][1] + offset(n-1);

    translate([0, 0, -length/2]) {
        for (i = [0:len(parts)-1])
        translate([0, 0, offset(i) - clearance])
        cylinder(d=parts[i][0] + 2*clearance, h=parts[i][1] + 2*clearance);

        // hole for pin
        translate([0, 0, offset(len(parts)) - 4.5])
        rotate([-90,0,0])
        cylinder(d=5.15, h=15.1+ 2*2.5, center=true); 

        translate([0, 0, offset(len(parts))]) head();

        // finger scoop
        translate([0, 0, 80])
        hull() {
            translate([-21+4, 0, 0]) resize([4, 23.5, 25]) sphere(d=25);
            translate([+21-4, 0, 0]) resize([4, 23.5, 25]) sphere(d=25);
        }
    }
}

module tekton_bin() {
    gridx = 1;
    gridy = ceil(length/42);
    gridz = 3;

    gridfinity_base(gridx, gridy, gridz, stacking_lip=false)
        rotate([-90, 0, 0])
            tekton_wrench();
}

tekton_bin();
