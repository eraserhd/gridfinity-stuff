
$fn = 50;

INCH = 25.4;
shank_length = 1.5 * INCH;
shank_diameter = 1/4 * INCH;

module bottom_bit() {
    module body() {
        rotate_extrude()
        polygon(points=[
            [ 0                 , 0                               ],
            [ 0.25              , 0                               ],
            [ 0.25 + 2.15       , 2.15                            ],
            [ 0.25 + 2.15       , 2.15 + 1.8                      ],
            [ 0.25 + 2.15 + 0.8 , 2.15 + 1.8 + 0.8                ],
            [ 0.25 + 2.15 + 0.8 , 2.15 + 1.8 + 0.8 + 2            ],
            [ shank_diameter/2  , 2.15 + 1.8 + 0.8                ],
            [ shank_diameter/2  , 2.15 + 1.8 + 0.8 + shank_length ],
            [ 0                 , 2.15 + 1.8 + 0.8 + shank_length ],
            [ 0                 , 0 ]
        ]);
    }

    module flute() {
        flute_cutter_diameter = 1/4 * INCH;
        
        translate([flute_cutter_diameter/2 + 0.25, 0, 0])
        hull() {
        rotate([90, 0, 0]) cylinder(h=10, d=flute_cutter_diameter);
        
        translate([0,0,2])
        rotate([90, 0, 0]) cylinder(h=10, d=flute_cutter_diameter);
        }
    }

    difference() {
        body();
        flute();
        rotate([0, 0, 180]) flute();
    }
}

bottom_bit();
