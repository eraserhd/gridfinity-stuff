$fn = 50;
tool_width = 3/8 * 25.4;
tool_clearance = 0.75;

gridx = 1;
gridy = 3;

minimum_spacing = 2.5;
angle = 30;

longest_tool = 3.5 * 25.4;
drawer_height = 2.56 * 25.4;

module _end_of_parameters() {}

m4_include(lib/end_mill_tray.scad.m4)m4_dnl

end_mill_tray(
    gridx=gridx,
    gridy=gridy,
    tool_width=tool_width,
    minimum_spacing=minimum_spacing,
    angle=angle,
    tool_clearance=tool_clearance,
    longest_tool=longest_tool,
    drawer_height=drawer_height
);
