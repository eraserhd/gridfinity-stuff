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

module base(gridx, gridy, gridz) {
    x_center_offset = (gridx * 42 - 0.5)/2.0 - 3.75;
    y_center_offset = (gridy * 42 - 0.5)/2.0 - 3.75;
    full_width_height = gridz * 7 - 2.15 - 1.8 - 0.8;

    module bottom_cell_layer(height, bottom_radius, top_radius) {
        radius_offset = 41.5/2.0 - 3.75;
        hull()
        for (x = [-radius_offset, +radius_offset]) {
            for (y = [-radius_offset, +radius_offset]) {
                translate([x,y])
                    cylinder(h=height, r1=bottom_radius, r2=top_radius);
            }
        }
    }

    module single_bottom_cell() {
        translate([+42.0/2.0, 42.0/2.0, 0.0])
            bottom_cell_layer(height = 0.8,  bottom_radius=0.8, top_radius=1.6);
        translate([+42.0/2.0, 42.0/2.0, 0.8])
            bottom_cell_layer(height = 1.8,  bottom_radius=1.6, top_radius=1.6);
        translate([+42.0/2.0, 42.0/2.0, 2.6])
            bottom_cell_layer(height = 2.15, bottom_radius=1.6, top_radius=3.75);
    }

    for (x = [0:gridx-1]) {
        for (y = [0:gridy-1]) {
            translate([x*42.0, y*42.0, 0])
                single_bottom_cell();
        }
    }

    hull()
    for (x = [4.0, gridx * 42.0 - 4.0]) {
        for (y = [4.0, gridy * 42.0 - 4.0]) {
            translate([x,y, 4.75])
                cylinder(h=full_width_height, r=3.75);
        }
    }
}

module center_drill_bin(sizes) {
    minimum_width_used = 8.0;
    function drill_width_needed(i) =
        max(
            center_drill_lookup(sizes[i], CENTER_DRILL_BODY_DIAMETER),
            minimum_width_used
        );
    function drill_width_left_of(i) =
        i <= 0 ?
        0.0 :
        drill_width_needed(i-1) + drill_width_left_of(i-1);
    total_drill_width_needed = drill_width_left_of(len(sizes));
    function maximum_drill_length(i=0) =
        i >= len(sizes) ?
        0.0 :
        max(
            center_drill_lookup(sizes[i], CENTER_DRILL_OVERALL_LENGTH),
            maximum_drill_length(i+1)
        );
    total_drill_length_needed = maximum_drill_length();

    gridx = ceil(total_drill_width_needed/42.0);
    gridy = ceil(total_drill_length_needed/42.0);
    actual_width = gridx*42.0;
    actual_y = gridy*42.0;
    spacing = (actual_width - total_drill_width_needed) / (len(sizes) + 1);
    function offset_of_drill(i) =
        actual_width - spacing - (drill_width_left_of(i) + drill_width_needed(i)/2.0 + spacing * i);
    gridz = 5;

    angle = 60.0;
//    difference() {
       %base(gridx, gridy, gridz);
       for (i = [0:len(sizes)-1]) {
           translate([offset_of_drill(i), actual_y/2.0, gridz*7])
           rotate([angle,0,0])
           #center_drill(sizes[i], clearance=0.25);
       }
    //}
}

$fn=20;
center_drill_bin(sizes = ["1","2","3","4","5"]);
