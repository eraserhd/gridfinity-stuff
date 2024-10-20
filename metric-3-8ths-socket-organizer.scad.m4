$fa = 8;
$fs = 0.25;
$fn=30;

m4_include(lib/socket_organizer.scad.m4)m4_dnl

socket_organizer(
    holes=[
        [ 17.2, "8"  ],
        [ 16.9, "10" ],
        [ 17.3, "12" ],
        [ 18.2, "13" ],
        [ 19.5, "14" ],
        [ 23.4, "17" ],
        [ 25.6, "19" ],
    ],
    text_primary_side="right",
    depth=15,
    patternx=4,
    dynamic_spacing=true,
    length=42,
    enable_lip=false,
    hole_clearance=0.75
);
