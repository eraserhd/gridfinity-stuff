$fa = 8;
$fs = 0.25;
$fn=30;

m4_include(lib/socket_organizer.scad.m4)m4_dnl

socket_organizer(
    holes=[
        [16.9, "T55"],
        [16.9, "T50"],
        [16.9, "T45"],
        [16.9, "T40"],
        [16.9, "T30"],
        [11.9, "T27"],
        [11.9, "T25"],
        [11.9, "T20"],
        [11.9, "T15"],
        [11.9, "T10"],
        [11.9, "T8"],
    ],
    text_primary_side="left",
    depth=15,
    patternx=4,
    dynamic_spacing=true,
    length=42,
    enable_lip=false,
    hole_clearance=0.75
);
