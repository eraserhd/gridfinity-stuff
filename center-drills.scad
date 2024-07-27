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

function to_milimeters(x) = x*25.4;

module center_drill(size) {
  indices = search([size], center_drills);
  assert(len(indices)==1, "Center drill size not found in table.");
  data = center_drills[indices[0]];
  body_diameter = to_milimeters(data[1]);
  drill_diameter = to_milimeters(data[2]);
  drill_length = to_milimeters(data[3]);
  overall_length = to_milimeters(data[4]);
  taper60_length = (body_diameter/2 - drill_diameter/2) / tan(30);
  taper120_length = (drill_diameter/2) / tan(60);
  
  rotate_extrude()
  polygon(points=[
     [ 0,                -overall_length/2 ],
     [ drill_diameter/2, -overall_length/2 + taper120_length ],
     [ drill_diameter/2, -overall_length/2 + drill_length ],
     [ body_diameter/2,  -overall_length/2 + drill_length + taper60_length ],
     [ body_diameter/2,  +overall_length/2 - drill_length - taper60_length ],
     [ drill_diameter/2, +overall_length/2 - drill_length ],
     [ drill_diameter/2, +overall_length/2 - taper120_length ],
     [ 0,                +overall_length/2 ],
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
}

//center_drill("2",$fn=25);

$fn=20;
base(2,1,3);
center_drill_bin(sizes = ["1","2","3","4","5"]);
