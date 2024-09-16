/*

NOTES:

1. The bits could be aligned on a tangent line, and Extra material could be
removed like my favorite endmill bins.  This could make it easier to put the
drills in and take them out.

2. It would be nice to set the maximum drawer height and compute the display
angle.

3. It would be nice to label the sizes with drill number and body diameter -
the latter so we know what collet to grab.

*/

/* [Setup Parameters] */

$fn=50;

/* [General Settings] */

// angle at which the drills are displayed, 0 being straight up and down
display_angle = 30;

/* [Included Center Drills] */

// #00: 1/8" body diameter, 0.025" drill diameter
size_00 = false;
// #0: 1/8" body diameter, 1/32" drill diameter
size_0 = false;
// #1: 1/8" body diameter, 3/36" drill diameter
size_1 = true;
// #2: 3/16" body diameter, 5/64" drill diameter
size_2 = true;
// #3: 1/4" body diameter, 7/64" drill diameter
size_3 = true;
// #4: 5/16" body diameter, 1/8 drill diameter
size_4 = true;
// #5: 7/16" body diameter, 3/16 drill diameter
size_5 = true;
// #6: 1/2" body diameter, 7/32 drill diameter
size_6 = false;
// #7: 5/8" body diameter, 1/4 drill diameter
size_7 = false;
// #8: 3/4" body diameter, 5/16 drill diameter
size_8 = false;

module end_of_customizer_opts() {}

// Information taken from https://community.sw.siemens.com/s/question/0D54O000061xhK6SAI/center-drills
//  (A) Body diameter
//  (D) Drill Diameter
//  (C) Drill Length
//  (L) Overall Length
center_drills = [
// Size  (A)   (D)    (C)    (L)
  ["00", 1/8,  0.025, 0.030, 1 + 1/8],
  [ "0", 1/8,  1/32,  0.038, 1 + 1/8],
  [ "1", 1/8,  3/36,  3/64,  1 + 1/4],
  [ "2", 3/16, 5/64,  5/64,  1 + 7/8],
  [ "3", 1/4,  7/64,  7/64,  2      ],
  [ "4", 5/16, 1/8,   1/8,   2 + 1/8],
  [ "5", 7/16, 3/16,  3/16,  2 + 3/4],
  [ "6", 1/2,  7/32,  7/32,  3      ],
  [ "7", 5/8,  1/4,   1/4,   3 + 1/4],
  [ "8", 3/4,  5/16,  5/16,  3 + 1/2],
];

function to_millimeters(x) = x*25.4;

CENTER_DRILL_SIZE           = 0;
CENTER_DRILL_BODY_DIAMETER  = 1;
CENTER_DRILL_DIAMETER       = 2;
CENTER_DRILL_LENGTH         = 3;
CENTER_DRILL_OVERALL_LENGTH = 4;

function center_drill_lookup(size, column) =
    let ( indices = search([size], center_drills) )
    assert(len(indices)==1, "Center drill size not found in table.")
    let (
        data = center_drills[indices[0]],
        data_in_mm = [
            data[0],
            to_millimeters(data[1]),
            to_millimeters(data[2]),
            to_millimeters(data[3]),
            to_millimeters(data[4])
        ]
    )
    column ? data_in_mm[column] : data_in_mm;

module center_drill(size, clearance = 0.0) {
  body_diameter = center_drill_lookup(size, CENTER_DRILL_BODY_DIAMETER);
  drill_diameter = center_drill_lookup(size, CENTER_DRILL_DIAMETER);
  drill_length = center_drill_lookup(size, CENTER_DRILL_LENGTH);
  overall_length = center_drill_lookup(size, CENTER_DRILL_OVERALL_LENGTH);
  taper60_length = (body_diameter/2 - drill_diameter/2) / tan(30);
  taper120_length = (drill_diameter/2) / tan(60);

  rotate_extrude()
  polygon(points=[
     [ 0,                            -overall_length/2 ],
     [ drill_diameter/2 + clearance, -overall_length/2 + taper120_length ],
     [ drill_diameter/2 + clearance, -overall_length/2 + drill_length ],
     [ body_diameter/2 + clearance,  -overall_length/2 + drill_length + taper60_length ],
     [ body_diameter/2 + clearance,  +overall_length/2 - drill_length - taper60_length ],
     [ drill_diameter/2 + clearance, +overall_length/2 - drill_length ],
     [ drill_diameter/2 + clearance, +overall_length/2 - taper120_length ],
     [ 0,                            +overall_length/2 ],
  ]);
}

// https://files.printables.com/media/prints/417152/pdfs/417152-gridfinity-specification-b1e2cca5-0872-4816-b0ca-5339e5473e13.pdf

module gridfinity_base(gridx, gridy, height, stacking_lip = true) {
    x_center_offset = (gridx * 42 - 0.5)/2.0 - 3.75;
    y_center_offset = (gridy * 42 - 0.5)/2.0 - 3.75;
    full_width_height = height * 7 - 2.15 - 1.8 - 0.8;
    lip_width = 2.6;
    outside_radius = 3.75;

    module cell_base() {
        module layer(z, height, bottom_radius, top_radius) {
            hull()
            for (x = [4.0, 42.0-4.0])
                for (y = [4.0, 42.0-4.0])
                    translate([x,y,z]) cylinder(h=height, r1=bottom_radius, r2=top_radius);
        }
        layer(z=0.0, height=0.8, bottom_radius=0.8, top_radius=1.6);
        layer(z=0.8, height=1.8, bottom_radius=1.6, top_radius=1.6);
        layer(z=2.6, height=2.15, bottom_radius=1.6, top_radius=3.75);
    }

    for (x = [0:gridx-1])
        for (y = [0:gridy-1])
            translate([x*42.0, y*42.0, 0])
                cell_base();

    hull()
    for (x = [4.0, gridx * 42.0 - 4.0])
        for (y = [4.0, gridy * 42.0 - 4.0])
            translate([x,y, 4.75]) cylinder(h=full_width_height, r=outside_radius);

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

    lip_inset = outside_radius + 0.25;

    module lip_side(grids) {
        rotate([90,0,0]) linear_extrude(grids*42.0 - 2 * lip_inset) lip_profile();
        rotate_extrude(angle=90) lip_profile();
    }

    if (stacking_lip) {
        translate([gridx*42.0 - lip_inset, gridy*42.0 - lip_inset, height*7]) lip_side(gridy);
        translate([lip_inset, lip_inset, height*7]) rotate([0,0,180]) lip_side(gridy);
        translate([gridx*42.0 - lip_inset, lip_inset, height*7]) rotate([0,0,-90]) lip_side(gridx);
        translate([lip_inset, gridy*42 - lip_inset, height*7]) rotate([0,0,90]) lip_side(gridx);
    }
}

module center_drill_bin(drill_sizes, display_angle=30.0) {
    minimum_width_used = 8.0;
    function drill_width_needed(i) =
        max(
            center_drill_lookup(drill_sizes[i], CENTER_DRILL_BODY_DIAMETER),
            minimum_width_used
        );
    function drill_width_left_of(i) =
        i <= 0 ?
        0.0 :
        drill_width_needed(i-1) + drill_width_left_of(i-1);
    total_drill_width_needed = drill_width_left_of(len(drill_sizes));
    function maximum_drill_length(i=0) =
        i >= len(drill_sizes) ?
        0.0 :
        max(
            center_drill_lookup(drill_sizes[i], CENTER_DRILL_OVERALL_LENGTH),
            maximum_drill_length(i+1)
        );
    total_drill_length_needed = maximum_drill_length();

    gridx = ceil(total_drill_width_needed/42.0);
    gridy = ceil((sin(display_angle) * total_drill_length_needed)/42.0);
    actual_width = gridx*42.0;
    actual_y = gridy*42.0;
    spacing = (actual_width - total_drill_width_needed) / (len(drill_sizes) + 1);
    function offset_of_drill(i) =
        actual_width - spacing - (drill_width_left_of(i) + drill_width_needed(i)/2.0 + spacing * i);

    gridz = ceil(cos(display_angle) * total_drill_length_needed / 2.0 / 7.0);

    echo("Seleted ", gridx, "x", gridy, " grid, height is ", gridz);

    difference() {
       gridfinity_base(gridx, gridy, gridz);
       for (i = [0:len(drill_sizes)-1]) {
           translate([offset_of_drill(i), actual_y/2.0, gridz*7])
           rotate([display_angle,0,0])
           center_drill(drill_sizes[i], clearance=0.5);
       }
    }
}

drill_sizes = concat(
  (size_00 ? ["00"] : []),
  (size_0  ? ["0"]  : []),
  (size_1  ? ["1"]  : []),
  (size_2  ? ["2"]  : []),
  (size_3  ? ["3"]  : []),
  (size_4  ? ["4"]  : []),
  (size_5  ? ["5"]  : []),
  (size_6  ? ["6"]  : []),
  (size_7  ? ["7"]  : []),
  (size_8  ? ["8"]  : [])
  );

center_drill_bin(drill_sizes = drill_sizes, display_angle = display_angle);
