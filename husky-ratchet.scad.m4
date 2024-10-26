
$fn = 50;

clearance = 0.5;
head_diameter = 32.9;
head_thickness = 14.2;
head_minor_diameter = 27;
head_minor_distance = 26;
drive_flange_diameter = 13.9;
drive_flange_depth = 11.8;

top_of_head_to_second_handle_diameter = 97;

m4_include(lib/gridfinity_base.scad.m4)m4_dnl

module head() {
    hull() {
        translate([0,0,-head_thickness/2])
        cylinder(d=head_diameter + 2*clearance, h=head_thickness);

        translate([0, head_minor_distance, -head_thickness/2])
        cylinder(d=head_minor_diameter + 2*clearance, h=head_thickness);

        translate([0, top_of_head_to_second_handle_diameter - 44, 0])
        rotate([90,0,0])
        cylinder(d=13.5 + clearance/2, h=0.1);
    }

    translate([0, 0, -drive_flange_depth-clearance-head_thickness/2])
    cylinder(d=drive_flange_diameter + 2*clearance, h=drive_flange_depth+clearance);
}

module shaft() {
    translate([
       0,
       top_of_head_to_second_handle_diameter - 44,
       0
    ])
    rotate([-90,0,0])
    rotate_extrude()
    polygon(points=[
        [ 0                  , 139   ],
        [ 14.2/2 + clearance , 139   ],
        [ 14.2/2 + clearance , 131.5 ],
        [ 11.5/2 + clearance , 126.4 ],
        [ 14.7/2 + clearance , 105   ],
        [ 15.5/2 + clearance , 49    ],
        [ 11.2/2 + clearance , 44    ],
        [ 13.5/2 + clearance , 0     ],
        [ 0 , 0     ],
    ]);
}

module cutout() {
    translate([0, head_diameter/2 + clearance, 0]) {
        head();
        shaft();
    }
}

module ratchet_bin() {
    gridz = ceil(1 + (head_thickness/2 + drive_flange_depth + clearance)/7);
    gridx = ceil(head_diameter/42);
    gridy = 6;

    difference() {
        gridfinity_base(gridx, gridy, gridz, stacking_lip=false);
        translate([gridx*42/2, 21, gridz*7]) cutout();
        
        hull() {
           translate([5, 120, gridz*7]) resize([6,25.4,11.8+2*clearance]) sphere(d=11.8+2*clearance);
           translate([42-5, 120, gridz*7]) resize([6,25.4,11.8+2*clearance]) sphere(d=11.8+2*clearance);
        }
    }
}

ratchet_bin();
