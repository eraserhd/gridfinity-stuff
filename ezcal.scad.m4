$fn = 50;

caliper_length = 235;
scale_width = 16;
scale_y_offset = 41.15;
scale_thickness = 3.44;
scale_height = 2.57;
thumbwheel_diameter = 11.5;
thumbwheel_height = 7.17;
thumbwheel_position = [
    93.5 - thumbwheel_diameter/2,
    scale_y_offset - thumbwheel_diameter/2
];
body_length = 66.25;
body_width = 29.5;
body_thickness = 18.5;
jaws_thickness = 6.5;

function bezier_coordinate(t, n0, n1, n2, n3) = 
    n0 * pow((1 - t), 3) + 3 * n1 * t * pow((1 - t), 2) + 
        3 * n2 * pow(t, 2) * (1 - t) + n3 * pow(t, 3);

function bezier_point(t, p0, p1, p2, p3) = 
    [
        bezier_coordinate(t, p0[0], p1[0], p2[0], p3[0]),
        bezier_coordinate(t, p0[1], p1[1], p2[1], p3[1])
    ];

function bezier_curve(t_step, p0, p1, p2, p3) = 
    [for(t = [0: t_step: 1]) bezier_point(t, p0, p1, p2, p3)];

body_outline = [
    [80, 57.15],
    [80, scale_y_offset - 5],
    [72.65, 26.67],
    [55.63, 33.78],
    [80 - body_length, 33.78],
    [80 - body_length, 62.68],
    [39.63, 62.68],
    [39.63, 71.37],
    [48.77, 71.37],
    [48.77, 62.68],
    [59.69, 62.68],
    // battery tab
    each bezier_curve(
        0.1,
        [59.69, 62.68],
        [65.03, 66.55],
        [70.62, 66.55],
        [76.71, 62.68]
    ),
    [80, 62.68]
];
jaws_outline = [
    [29.47, 33.78],
    [23.12, 6.86],
    [15.50, 0.0],
    [9.15, 6.86],
    [0.0, 35.31],
    [0.0, 59.44],
    [4.32, 73.66],
    [7.88, 77.22],
    [11.94, 72.9],
    [14.74, 62.68],
];

m4_include(lib/gridfinity_base.scad.m4)m4_dnl

module calipers() {
    linear_extrude(height=body_thickness) polygon(points=body_outline);
    color("grey") linear_extrude(height=6.5) polygon(points=jaws_outline);
    color("green")
        translate([0, scale_y_offset, scale_height])
        cube([caliper_length, scale_width, scale_thickness]);
    translate(thumbwheel_position) cylinder(d=thumbwheel_diameter, h=thumbwheel_height);
}

module ezcal_calipers_bin() {
    //calipers();
    gridfinity_base(1, 6, stacking_lip=true);
}

ezcal_calipers_bin();
