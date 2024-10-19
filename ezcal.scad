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

// https://files.printables.com/media/prints/417152/pdfs/417152-gridfinity-specification-b1e2cca5-0872-4816-b0ca-5339e5473e13.pdf

module gridfinity_base(gridx, gridy, height, stacking_lip=true, solid_height=undef) {
    x_center_offset = (gridx * 42 - 0.5)/2.0 - 3.75;
    y_center_offset = (gridy * 42 - 0.5)/2.0 - 3.75;
    full_width_height = (is_undef(solid_height) ? height*7 : solid_height) - 2.15 - 1.8 - 0.8;
    empty_height = is_undef(solid_height) ? undef : height*7 - solid_height;
    lip_width = 2.6;
    outside_radius = 3.75;
    inside_radius = outside_radius - lip_width;
    lip_inset = outside_radius + 0.25;

    module layer(gridx, gridy, z, height, bottom_radius, top_radius, r) {
        br = is_undef(bottom_radius) ? r : bottom_radius;
        tr = is_undef(top_radius) ? r : top_radius;
        hull()
        for (x = [4.0, gridx*42.0-4.0])
            for (y = [4.0, gridy*42.0-4.0])
                translate([x,y,z]) cylinder(h=height, r1=br, r2=tr);
    }
    module cell_layer(z, height, bottom_radius, top_radius, r) {
        layer(gridx=1, gridy=1, z=z, height=height, bottom_radius=bottom_radius, top_radius=top_radius, r=r);
    }
    module base_layer(z, height, bottom_radius, top_radius, r) {
        layer(gridx=gridx, gridy=gridy, z=z, height=height, bottom_radius=bottom_radius, top_radius=top_radius, r=r);
    }
    module cell_base() {
        cell_layer(z=0.0, height=0.8, bottom_radius=0.8, top_radius=1.6);
        cell_layer(z=0.8, height=1.8, bottom_radius=1.6, top_radius=1.6);
        cell_layer(z=2.6, height=2.15, bottom_radius=1.6, top_radius=3.75);
    }
    module lip_profile() {
        function roundover_at(angle) = let (
            radius = 0.5,
            x = outside_radius - radius,
            y = 3.69 - radius
        ) [ x + radius * sin(angle), y + radius * cos(angle) ];
        polygon(points=[
            [ outside_radius - lip_width  ,   0 ],
            [ outside_radius - 1.9        , 0.7 ],
            [ outside_radius - 1.9        , 0.7 + 1.8 ],
            for (angle = [-45, -30, 0, 30, 45, 60, 90]) roundover_at(angle),
            [ outside_radius              ,   0 ],
            [ outside_radius - lip_width  ,   0 ]
        ]);
    }
    module lip_side(grids) {
        rotate([90,0,0]) linear_extrude(grids*42.0 - 2 * lip_inset) lip_profile();
        rotate_extrude(angle=90) lip_profile();
    }
    module stacking_lip() {
        translate([gridx*42.0 - lip_inset, gridy*42.0 - lip_inset, height*7]) lip_side(gridy);
        translate([lip_inset, lip_inset, height*7]) rotate([0,0,180]) lip_side(gridy);
        translate([gridx*42.0 - lip_inset, lip_inset, height*7]) rotate([0,0,-90]) lip_side(gridx);
        translate([lip_inset, gridy*42 - lip_inset, height*7]) rotate([0,0,90]) lip_side(gridx);
    }

    for (x = [0:gridx-1])
        for (y = [0:gridy-1])
            translate([x*42.0, y*42.0, 0])
                cell_base();

    base_layer(z=4.75, height=full_width_height, r=outside_radius);

    if (!is_undef(empty_height)) {
        difference() {
            base_layer(z=solid_height, height=empty_height, r=outside_radius);
            base_layer(z=solid_height, height=empty_height+0.1, r=inside_radius);
        }
    }

    if (stacking_lip) {
        stacking_lip();
    }

    if (!is_undef(solid_height)) {
        empty_height = height - solid_height;
    }
}

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
