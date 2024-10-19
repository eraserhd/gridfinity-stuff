m4_include(lib/gridfinity_base.scad.m4)m4_dnl

module end_mill_tray(gridx, gridy, tool_width, minimum_spacing=2.5, angle=30, tool_clearance=0.75, longest_tool, drawer_height, tool_geometry="round") {
    gridz = 4;
    bottom_height = 5.5;
    tool_cutout_length = (gridz*7-bottom_height) / sin(angle);
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

    module shank_cutout() {
        if (tool_geometry == "round") {
            cylinder(d=tool_width + tool_clearance, h=tool_cutout_length);
        } else if (tool_geometry == "square") {
            translate([0, 0, tool_cutout_length/2])
            cube([tool_width + tool_clearance, tool_width + tool_clearance, tool_cutout_length], center=true);
        } else {
            assert(false, "Unknown tool geometry");
        }
    }

    module end_mill_cutout() {
        actual_spacing = (gridx * 42 - columns * tool_width) / (columns + 1);

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
            shank_cutout();

            translate([
                actual_spacing + tool_width/2,
                -(tool_width + tool_clearance)/2,
                0
            ])
            cube([
                 (columns - 1) * tool_width + (columns - 1)*actual_spacing,
                 tool_width/2 + tool_clearance,
                 tool_cutout_length,
            ]);
        }

        // Make sure it will fit in the drawer.
        if (!is_undef(longest_tool) && !is_undef(drawer_height)) {
            total_height = bottom_height +
                           sin(angle) * longest_tool + 
                           2 * cos(angle) * (tool_width + tool_clearance)/2 +
                           2;
            echo("total height = ", total_height, "; drawer_height = ", drawer_height);
            assert(total_height < drawer_height);
        }
    }

    difference() {
        gridfinity_base(gridx, gridy, gridz, stacking_lip=false);

        for (row = [0:rows-1])
        translate([0, tool_y_spacing*row, 0])
        end_mill_cutout();
    }
}
