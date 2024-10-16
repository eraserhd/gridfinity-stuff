
bracket_wall_thickness = 6;
bracket_height = 28;
bracket_length = 50;
dovetail_thickness = 0.257 * 25.4;
dovetail_major_length = 1.1 * 25.4;
dovetail_minor_length = 0.92 * 25.4;
tool_clearance_gap = 0.6;
tool_count = 5;
tool_spacing = 32;

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

module tool_holder_post() {
    module fillet() {
        radius = (42*2 - bracket_length) / 2 * 3/4;
        translate([0, -radius, radius])
        rotate([0, 90, 0])
        difference() {
            translate([radius/2, radius/2, bracket_wall_thickness/2])
            cube([radius, radius, bracket_wall_thickness], center=true);
            translate([0, 0, -0.05])
            cylinder(r=radius, h=bracket_wall_thickness+0.1, $fn=100);
        }
    }
    
    module dovetail() {
        top_chamfer = 1.0;
        hull() {
        linear_extrude(bracket_height - top_chamfer)
        polygon(points=[
            [0, dovetail_minor_length/2 - tool_clearance_gap],
            [dovetail_thickness, dovetail_major_length/2 - tool_clearance_gap],
            [dovetail_thickness, -dovetail_major_length/2 + tool_clearance_gap],
            [0, -dovetail_minor_length/2 + tool_clearance_gap],
        ]);
	translate([0, 0, bracket_height - 0.1])
	linear_extrude(0.1)
        polygon(points=[
            [0, dovetail_minor_length/2 - tool_clearance_gap - top_chamfer],
            [dovetail_thickness - top_chamfer, dovetail_major_length/2 - tool_clearance_gap - top_chamfer],
            [dovetail_thickness - top_chamfer, -dovetail_major_length/2 + tool_clearance_gap + top_chamfer],
            [0, -dovetail_minor_length/2 + tool_clearance_gap + top_chamfer],
        ]);
        }
    }
    
    module post() {
        translate([bracket_wall_thickness, 0, 0])
        linear_extrude(bracket_height)
        polygon(points=[
            [-bracket_wall_thickness, bracket_length/2],
            [0, bracket_length/2],
            [0, -bracket_length/2],
            [-bracket_wall_thickness, -bracket_length/2],
        ]);

        translate([0, -bracket_length/2, 0]) fillet();
        translate([+bracket_wall_thickness, bracket_length/2, 0]) rotate([0, 0, 180]) fillet();
    }

    post();
    translate([bracket_wall_thickness, 0, 0]) dovetail();
}

module lathe_tool_holder_bin() {
   gridfinity_base(4, 2, 1, stacking_lip=false);

   for (i = [0:tool_count-1])
   translate([0.25 + i*tool_spacing, 2*42/2, 7])
   tool_holder_post();
}

lathe_tool_holder_bin();
