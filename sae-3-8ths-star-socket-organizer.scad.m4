$fa = 8;
$fs = 0.25;
$fn=30;

m4_include(lib/socket_organizer.scad.m4)m4_dnl

socket_organizer(
    holes=[
        [ 17.3, "7/16" ],
        [ 18.3, "1/2" ],
        [ 22.2, "5/8" ],
        [ 25.7, "3/4" ],
    ],
    text_primary_side="right",
    depth=15,
    patternx=4,
    dynamic_spacing=true,
    length=42,
    enable_lip=false,
    hole_clearance=0.75
);
