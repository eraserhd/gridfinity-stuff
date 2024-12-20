$fn = 50;
tool_width = 3/8 * 25.4;
tool_clearance = 0.75;

gridx = 2;
gridy = 3;

minimum_spacing = 2.5;
angle = 30;

longest_tool = 3.5 * 25.4;
drawer_height = 2.56 * 25.4;

module _end_of_parameters() {}

// https://files.printables.com/media/prints/417152/pdfs/417152-gridfinity-specification-b1e2cca5-0872-4816-b0ca-5339e5473e13.pdf

module gridfinity_base(
    gridx,
    gridy,
    height,
    stacking_lip=true,
    solid_height=undef
) {
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

    module solid_part() {
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
    }

    difference() {
        solid_part();
        translate([gridx*42/2, gridy*42/2, height*7]) children();
    }

    if (!is_undef(solid_height)) {
        empty_height = height - solid_height;
    }

}

module end_mill_tray(gridx, gridy, tool_width, minimum_spacing=2.5, angle=30, tool_clearance=0.75, longest_tool, drawer_height, tool_geometry="round") {
    gridz = 4;
    bottom_height = 5.5;
    tool_cutout_length = (gridz*7-bottom_height) / sin(angle);
    tool_y_spacing = (tool_width + tool_clearance) / sin(angle) + minimum_spacing;

    rows = let (
          tool_length_projection = (gridz*7 - bottom_height) / tan(angle),
          tool_diameter_projection = sin(angle)* (tool_width + tool_clearance),
          front_space = tool_length_projection + tool_diameter_projection + minimum_spacing,
          remaining_y = gridy * 42 - front_space - minimum_spacing
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

end_mill_tray(
    gridx=gridx,
    gridy=gridy,
    tool_width=tool_width,
    minimum_spacing=minimum_spacing,
    angle=angle,
    tool_clearance=tool_clearance,
    longest_tool=longest_tool,
    drawer_height=drawer_height,
    tool_geometry="square"
);
