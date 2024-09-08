$fn = 50;

caliper_length = 235;
scale_width = 16;
scale_bottom_height = 2.45;
thumbwheel_diameter = 11.5;
thumbwheel_position = [ 92.5, 20.32 + scale_width + thumbwheel_diameter/2 ]; // FIXME: double-check

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


caliper_outline = [
    [caliper_length, 57.15],
    [caliper_length, 57.15 - scale_width],
    [94.75, 57.15 - scale_width],
    
    each bezier_curve(
        0.1,
        [94.75, 57.15 - scale_width],
        [94.75, 38.86],
        [98.81, 31.24],
        [91.95, 28.45]
    ),
    each bezier_curve(
        0.1,
        [91.95, 28.45],
        [84.84, 25.65],
        [81.79, 32.0],
        [81.79, 32.0]
    ),
    [72.65, 26.67],
    [55.63, 33.78],
    [29.47, 33.78],
    [23.12, 6.86],
    [15.50, 0.0],
    [9.15, 6.86],
    [1.02, 35.31],
    [0.00, 59.44],
    [4.32, 73.66],
    each bezier_curve(
        0.1,
        [4.32, 73.66],
        [5.08, 74.93],
        [6.35, 76.2],
        [7.88, 77.22]
    ),
    each bezier_curve(
        0.1,
        [7.88, 77.22],
        [9.40, 75.95],
        [10.42, 74.68],
        [11.94, 72.9]
    ),
    [14.74, 63.75],
    [39.63, 63.25],
    [39.63, 71.37],
    [48.52, 71.37],
    [48.77, 63.5],
    [59.69, 63.75],
    each bezier_curve(
        0.1,
        [59.69, 63.75],
        [65.03, 66.55],
        [70.62, 66.55],
        [76.71, 63.75]
    ),
    each bezier_curve(
        0.1,
        [76.71, 63.75],
        [82.55, 64.77],
        [84.08, 63.75],
        [83.32, 57.15]
    ),
    [caliper_length, 57.15],
];

m4_include(lib/gridfinity_base.scad.m4)m4_dnl

module ezcal_calipers_bin() {
    polygon(points=caliper_outline);
    #translate(thumbwheel_position) circle(d=thumbwheel_diameter);
}

ezcal_calipers_bin();
