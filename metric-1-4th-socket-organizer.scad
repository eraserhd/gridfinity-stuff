$fa = 8;
$fs = 0.25;
$fn=30;

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

module socket_organizer(
    holes,
    text_primary_side="right",
    depth=15,
    patternx=2,
    dynamic_spacing=true,
    length=42,
    enable_lip=false,
    hole_clearance=0.75,
) {
    gridz = 3;
    height_internal = gridz * 7; // gridfinity internal block height of bin (above 5.5mm of bottom grid section)(needs to be taller than depth (hole cut depth)

    line_width_multiplier=3.5; //underline of text, bases on font and font size
    line_angle_multiplier=.5; //affects angle of line, is a muliplier on diamter, .5 to 1 is ideal

    vert_spacing=.1; //Adds vertical spacing between rows works with dynamic or normal spacing

    lateral_spacing=2; //extra between holes, beyond max diam, should be 1 or 2 minimum

    spacingtextx=3; //spacing out from edge of hole to start of text

    text_size=5;

    text_depth=.4;

    line_space=2; //space between line and bottom of nearest holes, also used for overall height clearance

    line_thick=.8; //.8

    visual_clearance=0.01;  //for scad quick rendering

    assert(patternx >=2 && patternx <=4, "Pattern must be set 2-4 columns");
    assert(text_primary_side=="left" || text_primary_side=="right", "text_primary_side must be 'left' or 'right' (w/ quotes)");
    assert(dynamic_spacing==true || dynamic_spacing==false, "dynamic_spacing must be true or false (no quotes)");
    assert(height_internal>depth, "depth must be shallower than bin height");

    max_dia= max([for(a=[0:len(holes)-1]) holes[a][0]]);
    //echo("max dia used for lateral spacing", max_dia);

    minimum_spacing=(text_size*2+line_space*4 + line_thick*2)*1.1;

    max_label_length= max([for(a=[0:len(holes)-1]) len(holes[a][1])]);
    //echo("max label length for overall size", max_label_length);

    spacing_adder_y=line_space*2+line_thick+vert_spacing;

    patterny=ceil(len(holes)/patternx);
    pattern_grid=[patternx,patterny];
    spacing_grid=[max_dia+lateral_spacing+hole_clearance,max_dia+spacing_adder_y+hole_clearance];
    //echo("num holes",len(holes),"pattern", pattern_grid);
    //echo("spacing",spacing_grid);
    //echo(minimum_spacing);

    text_column_r=(patternx-1)*(max_dia+lateral_spacing)+(max_dia/2+spacingtextx);
    text_column_l=-(max_dia/2+spacingtextx);

    text_column_p= text_primary_side=="right"? text_column_r:text_column_l;
    text_column_s= text_primary_side=="right"? text_column_l:text_column_r;
    l_r= text_primary_side=="right" ? 0         :-1;
    //    : patternx==4? //4 wide doesn't have a primary text side?
    //        0:-1;

    static_text_offset_low=-max_dia/2+text_size/2; //dynamic values are based on max hole size in row
    static_text_offset_high=5; //dynamic values are based on max hole size in row

    //data=(dia),(label),(max dia in row),(grid pos),
    data= [for (a =[0:len(holes)-1])
            [holes[a][0], holes[a][1],

            //over comlicated way to get max diam in current row
            max(concat([for (i =[a:a+patternx-1])                          //max of relevant numbers from below
                grid_pos(pattern_grid,a)[1]!=grid_pos(pattern_grid,i)[1] ? //if not in same y row, give 0
                    0 :
                        holes[i][0]==undef ?
                            0:
                                holes[i][0]>=minimum_spacing ?   //then comepare diam to min dynamic spacing
                                    holes[i][0] : minimum_spacing
                    ])),
            grid_pos(pattern_grid,a),
            ]];
    echo(data);
    ;

    //figuring out overall size cause scad doesn't have a command for this...
    //x dimensions of overall size
    num_labels= patternx==2 ? 1:2;
    left_label= patternx==2 && text_primary_side=="right" ? 0:1;

    x_total=(max_dia+lateral_spacing)*(patternx-1) + max_dia + num_labels*(spacingtextx+max_label_length*line_width_multiplier);
    x_min=max_dia/2+(left_label)*(spacingtextx+max_label_length*line_width_multiplier);
    x_center=x_total/2-x_min;

    //y minus is unerline point 2y/3y
    first_hole_data=data[0];
    first_row_max_dia= first_hole_data[2] >= minimum_spacing ? first_hole_data[2] : minimum_spacing;
    y_min= dynamic_spacing==true ?
        -first_row_max_dia/2-line_space-line_thick : -max_dia/2-line_space-line_thick;

    //y plus is top row center position + half max diam of that row (data[-1])
    last_hole_data=data[len(data)-1];
    y_max= dynamic_spacing==true ?
        center_pos(last_hole_data[3],data)[1]+(last_hole_data[2]+hole_clearance)/2+line_space
        : center_pos(last_hole_data[3],data)[1]+(max_dia +hole_clearance)/2+line_space;

    y_total=y_max-y_min;
    y_center=(y_total)/2;


    grid_y_reqd=ceil(y_total/length);
    gridy = grid_y_reqd; //have to input number not formula into gridfinity modules

    grid_x_reqd=ceil(x_total/length);
    gridx = grid_x_reqd;//have to input number not formula into gridfinity modules

    function textpos_x(hole_data) =
        patternx==2 ?
            text_column_p
        : patternx==3  && text_primary_side=="right" ?
            hole_data[3][0]==0 ? text_column_l : text_column_r
        : patternx==3 && text_primary_side=="left" ?
            hole_data[3][0]>=1 ? text_column_l : text_column_r
        : patternx==4 ?
            hole_data[3][0]<=1 ? text_column_s : text_column_p
            :0;

    function text_align(posx) = //"left" or "right" depending on side where labels are, for alignment not pos
        posx==text_column_l ? "right" : "left";

    function textpos_y(hole_data) =
        patternx==2 ?
            hole_data[3][0]==0 ? text_offset_low(hole_data) : text_offset_high(hole_data)
        : patternx==3  && text_primary_side=="right" ?
            hole_data[3][0]<=1 ? text_offset_low(hole_data) : text_offset_high(hole_data)
        : patternx==3  && text_primary_side=="left" ?
            hole_data[3][0]<=1 ? text_offset_low(hole_data) : text_offset_high(hole_data)
        : patternx==4 ?
            hole_data[3][0]==1 || hole_data[3][0]==2 ? text_offset_low(hole_data) : text_offset_high(hole_data)
            :0;

    function text_offset_high (hole_data)=
        dynamic_spacing==true ?
            (hole_data[2]/2-text_size/2 +(-hole_data[2]/2+text_size*1.5))/2 : static_text_offset_high; //new, label centered

    function text_offset_low (hole_data)=
        dynamic_spacing==true ?
            -hole_data[2]/2+text_size/2: static_text_offset_low;

    function grid_pos (pattern, current_pos)=
        [current_pos < pattern[0]-1 ? //column number
            current_pos:(current_pos)-floor(current_pos/pattern[0])*pattern[0], //column number logic to go 0:max

        floor(current_pos/pattern[0]), //row number
        ];

    function center_pos (grid_pos,list)=
       dynamic_spacing==true ?
            [abs(grid_pos[0]+l_r*(patternx-1))*spacing_grid[0],
                //y center
                grid_pos[1]==0
                    ? 0
                    : //if true, do dynamic spacing for everything except first row  y
                    Sum(concat([for (b =[grid_pos[1]:-1:0]) (list[b*patternx][2]+spacing_adder_y)],(-list[grid_pos[1]*patternx][2]-spacing_adder_y)/2,(-list[0][2]-spacing_adder_y)/2))] //addition of ypos times that row's largest dia, then minus half for first and last row.
            : [abs(grid_pos[0]+l_r*(patternx-1))*spacing_grid[0],grid_pos[1]*spacing_grid[1]]; //if false, static spacing y

    //sum function from here: https://www.reddit.com/r/openscad/comments/j5v5pp/sumlist/
    function SubSum(x=0,Index=0)=x[Index]+((Index<=0)?0:SubSum(x=x,Index=Index-1));
    function Sum(x)=SubSum(x=x,Index=len(x)-1);

    module label_line(center,text_x, text_y,hole_data) {
        x=center[0];
        y=center[1];

        underline_len=line_width_multiplier*len(hole_data[1]);
        dir= text_x == text_column_l ? -1:1;

        point1=center;

        point2d=[x+hole_data[2]*line_angle_multiplier*dir,y+text_y-text_size/2-line_space-line_thick];
        point2u=[text_x,y+text_y-text_size/2-line_space-line_thick];
        point2= textpos_y(hole_data)>0 ? point2u:point2d;

        point3=[text_x+underline_len*dir,point2[1]];
        point4=[point3[0],point3[1]+line_thick];
        point5=[point2[0]+line_thick*line_angle_multiplier*dir,point2[1]+line_thick];

        point6=[x+line_thick*line_angle_multiplier*dir,y+line_thick];

        points=[point1,point2,point3,point4,point5,point6];
    //    echo(points)

        color("white")
        linear_extrude(height=text_depth+1)
            polygon (points);
    }

    difference() {
        union() {
            //build gridfinity box
            color("gray")
            translate([-gridx*42/2, -gridy*42/2, 0])
            gridfinity_base(gridx, gridy, gridz, stacking_lip=enable_lip);

            //build text and lines
            translate([-x_center,-y_center-y_min,height_internal]){
                for (i =[0:len(data)-1]) {
                    color("white")
                    translate([textpos_x(data[i]),textpos_y(data[i]),0])
                        translate([0,center_pos(data[i][3],data)[1],0])
                            linear_extrude(text_depth+1)
                                text(data[i][1], size=text_size, valign="center", halign=text_align(textpos_x(data[i])), font=   "Arial:style=Bold");
                    label_line(center_pos(data[i][3],data),textpos_x(data[i]),textpos_y(data[i]),data[i]);
                }
            }
        }

        //remove cylinders and cut from label line
        color("gray")
        translate([-x_center,-y_center-y_min,(height_internal+5.1)]) {
            for (i =[0:len(data)-1]) {
                translate(concat(center_pos(data[i][3],data),-depth))
                    union() {
                        cylinder(depth,d=data[i][0]+hole_clearance);
                        translate([0,0,depth-visual_clearance])
                            cylinder(text_depth+visual_clearance*2,d=(data[i][0]+line_space*2));
                    }
            }
        }
    }
}


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

