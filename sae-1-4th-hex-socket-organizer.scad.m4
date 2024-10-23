$fa = 8;
$fs = 0.25;
$fn=30;

m4_include(lib/socket_organizer.scad.m4)m4_dnl

socket_organizer(
    holes=[
        [ 11.9, "3/16"   ],
        [ 11.9, "1/4"   ],
        [ 11.9, "5/16"  ],
        [ 14.6, "5/8"  ],
        [ 15.8, "7/16"  ],
        [ 17.6, "1/2"  ],
    ],
    text_primary_side="left",
    depth=15,
    patternx=2,
    dynamic_spacing=true,
    length=42,
    enable_lip=false,
    hole_clearance=0.75
);
