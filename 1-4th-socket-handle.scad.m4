$fn = 25;

socket_driver_length = 152;
shaft_diameter = 8.2;
handle_length = 91.2;
clearance = 0.5;

handle_profile = [
    [ 0          , -6.3 ],
    [ 9/2        , -5   ],
    [ 10/2       , -4.65],
    [ 14/2       , -3.15],
    [ 17.2/2     , 0    ],
    [ 24.5/2     , 24.3 ],
    [ 16.4/2     , 66.6 ],
    [ 20.3/2     , 89.3 ],
    [ 20.3/2-2.65, 91.2 ],
    [ 0          , 91.2 ],
];

m4_include(lib/gridfinity_base.scad.m4)m4_dnl

function reverse(list) =
    [ for (i = [len(list)-1:-1:0]) list[i] ];

module profile() {
    linear_extrude(25, center=true)
    polygon(points=[
        each handle_profile,
        each reverse([for (p = handle_profile) [-p.x, p.y]])
    ]);
}

module handle() {
    intersection() {
        profile();
        rotate([0, 90, 0]) profile();
    }
}

module driver() {
    minkowski() {
        handle();
        sphere(d=1, $fn=40);
    }
    rotate([-90,0,0])
    cylinder(d=shaft_diameter + clearance, h=socket_driver_length);
}

module socket_driver_bin() {
    gridx = 1;
    gridy = 4;
    gridz = 3;
    difference() {
        gridfinity_base(gridx, gridy, gridz, stacking_lip=false);
        translate([gridx*42/2, (gridy*42 - socket_driver_length - clearance)/2 + 6.3/2, gridz*7])
        driver();
    }
}

socket_driver_bin();
