$fa = 8;
$fs = 0.25;
$fn=30;

m4_include(lib/socket_organizer.scad.m4)m4_dnl

socket_organizer(
    holes=[
        [ 11.9, "4"   ],
        [ 11.9, "4.5" ],
        [ 11.9, "5"   ],
        [ 11.9, "5.5" ],
        [ 11.9, "6"   ],
        [ 11.9, "7"   ],
        [ 11.9, "8"   ],
        [ 13.0, "9"   ],
        [ 14.6, "10"  ],
        [ 15.9, "11"  ],
        [ 16.8, "12"  ],
        [ 17.6, "13"  ],
    ],
    text_primary_side="left",
    depth=15,
    patternx=4,
    dynamic_spacing=true,
    length=42,
    enable_lip=false,
    hole_clearance=0.75
);

