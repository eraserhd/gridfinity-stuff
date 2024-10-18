$fn = 50;
tool_width = 3/8 * 25.4;
tool_clearance = 0.75;

gridx = 2;
gridy = 3;

minimum_spacing = 3;
angle = 30;

longest_tool = 3.5 * 25.4;
drawer_height = 2.56 * 25.4;

module _end_of_parameters() {}

gridz = 5;
bottom_height = 5.5;

tool_y_spacing = (tool_width + tool_clearance) / sin(angle) + minimum_spacing;

rows = let (
      tool_length_projection = (gridz*7 - bottom_height) / tan(angle),
      tool_diameter_projection = sin(angle)* (tool_width + tool_clearance),
      front_space = tool_length_projection + tool_diameter_projection + minimum_spacing,
      remaining_y = gridy * 42 - front_space
    ) 1 + floor(remaining_y / tool_y_spacing);

columns = floor(
    (gridx * 42 - minimum_spacing) / (tool_width + tool_clearance + minimum_spacing)
);

m4_include(lib/gridfinity_base.scad.m4)m4_dnl

module end_mill_cutout() {
    actual_spacing = (gridx * 42 - columns * tool_width) / (columns + 1);
    cylinder_height = (gridz*7-bottom_height) / sin(angle);

    translate([
        0,
        sin(angle) * tool_width/2 + minimum_spacing,
        cos(angle) * tool_width/2 + bottom_height,
    ])
    rotate([-90 + angle, 0, 0]) {
        for (i = [0:columns-1])
        translate([
            (i + 1/2) * tool_width + (i + 1)*actual_spacing,
            0,
            0
        ])
        cylinder(d=tool_width + tool_clearance, h=cylinder_height);
        
        translate([
            actual_spacing + tool_width/2,
            -(tool_width + tool_clearance)/2,
            0
        ])
        cube([
             (columns - 1) * tool_width + (columns - 1)*actual_spacing,
             tool_width/2 + tool_clearance,
             cylinder_height,
        ]);
    }

    // Make sure it will fit in the drawer.
    total_height = bottom_height +
                   sin(angle) * longest_tool + 
                   2 * cos(angle) * (tool_width + tool_clearance)/2 +
                   2;
    echo("total height = ", total_height, "; drawer_height = ", drawer_height);
    assert(total_height < drawer_height);
}

module end_mill_tray() {
    difference() {
        gridfinity_base(gridx, gridy, gridz, stacking_lip=false);

        for (row = [0:rows-1])
        translate([0, tool_y_spacing*row, 0])
        end_mill_cutout();
    }
}

end_mill_tray();
