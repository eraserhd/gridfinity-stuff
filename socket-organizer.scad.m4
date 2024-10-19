//=============Read me=============//
/*Original gridfinity utility here: 
https://www.printables.com/model/274917-gridfinity-rebuilt-in-openscad

Original Author's note (still true, as of 09/2023 you still need to get a nightly build not an official release build):
"IMPORTANT: rendering will be better for analyzing the model if fast-csg is enabled. As of writing, this feature is only available in the development builds and not the official release of OpenSCAD, but it makes rendering only take a couple seconds, even for comically large bins. Enable it in Edit > Preferences > Features > fast-csg"



Basic information:
-Fill out list of holes with measured size in mm and desired label text. 
-Order of list will determine position, starting at bottom left or right (depending on primary label side). 
-Overall size is determined by pattern, size of holes, and gridfinity units
-using a standard 42mm gridfinity base unit results in a lot of wasted space; I recommend keeping defualt baseplate size, but using half size on the socket holder par. 
-Use other parameters as needed and as described.
-Double check labels work with list



"text_primary_side" Notes:
Setting left and right label side also controls Left-to-Right vs Right-to-Left building of hole pattern. 
With 4 columns this only sets order of hole population. "right" builds left to right, bottom to top (with labels on the right). Setting the "text_primary_side" to the left moves labels to the left side and builds the hole pattern from right to left, bottom to top. This works out so that labels will read in the same order as the input list in most cases. 
If using 4 wide grid though, pay attention to label output; if you want to read ascending or descending you may have to manually rearrange list. 

*/


//=============PRIMARY PARAMETERS=============// 


//list of hole diameter and string of label. Hole clearance gets added later, so measured diameter goes here. Order of list determines position in grid. 
holes=[ 
    [ 17.2, "8" ],
    [ 16.9, "10" ],
    [ 17.2, "12"   ],
    [ 18.2, "13"   ],
    [ 19.5, "14"   ],
    [ 23.4, "17"   ],
    [ 25.7, "19"   ],
];

depth=15; //depth of hole, should not be deeper than depth internal from gridfinity section 

patternx=2; //how many columns of holes? {2-4}. Num rows is determined by how many holes there are 

text_primary_side="right"; //Labels on left or right side, also controls Left-to-Right vs Right-to-Left building of holes.

dynamic_spacing=true; //true (no quotes) squeezes rows together as possible, false  is consistant spacing based on largest hole diameter

length = 42; //Gridfinity base unit length (default 42, 21 works best for best use of space with default grid pieces)

height_internal = 20; // gridfinity internal block height of bin (above 5.5mm of bottom grid section)(needs to be taller than depth (hole cut depth)

hole_clearance=0.75; //oversize holes by this much. and also used for line clearance 


{//=============Secondary Parameters (that shouldn't need changed) =============//

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




{ //STUFF FROM ORIGINAL UTILITY THAT SHOULDN'T NEED TO BE TOUCHED
/* [Setup Parameters] */
$fa = 8;
$fs = 0.25;
$fn=30;

/* [Compartments] */
// number of X Divisions
divx = 1;
// number of y Divisions
divy = 1;
// bin height. See bin height information and "gridz_define" below.  
gridz = 3; 


/* [Toggles] */
// internal fillet for easy part removal
enable_scoop = false;
// snap gridz height to nearest 7mm increment
enable_zsnap = false;
// enable upper lip for stacking other bins
enable_lip = false;
// the type of tabs
style_tab = 5; //[0:Full,1:RAuto,2:Left,3:Center,4:ight,5:None]

/* [Other] */
// determine what the variable "gridz" applies to based on your use case
gridz_define = 2; // [0:gridz is the height of bins in units of 7mm increments - Zack's method,1:gridz is the internal height in millimeters, 2:gridz is the overall external height of the bin in millimeters]
/* [Base] */
style_hole = 0; // [0:no holes, 1:magnet holes only, 2: magnet and screw holes - no printable slit, 3: magnet and screw holes - printable slit]
// number of divisions per 1 unit of base along the X axis. (default 1, only use integers. 0 means automatically guess the right division)
div_base_x = 0;
// number of divisions per 1 unit of base along the Y axis. (default 1, only use integers. 0 means automatically guess the right division)
div_base_y = 0; 
}}

module _end_of_parameters() {}

m4_include(lib/gridfinity_base.scad.m4)m4_dnl


{//===Setup===

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

}


{//===RUN===

difference(){
union(){
//build gridfinity box
translate([-gridx*42/2, -gridy*42/2, 0])
gridfinity_base(gridx, gridy, gridz);


//build text and lines
translate([-x_center,-y_center-y_min,(height_internal+5.1-1)]){
    for (i =[0:len(data)-1]) {
        translate([textpos_x(data[i]),textpos_y(data[i]),0])
                    translate([0,center_pos(data[i][3],data)[1],0])
                        linear_extrude(text_depth+1){
                            text(data[i][1], size=text_size, valign="center", halign=text_align(textpos_x(data[i])), font=   "Arial:style=Bold");
                                    }
                label_line(center_pos(data[i][3],data),textpos_x(data[i]),textpos_y(data[i]),data[i]);
}}
}

//remove cylinders and cut from label line
translate([-x_center,-y_center-y_min,(height_internal+5.1)]){ 
    for (i =[0:len(data)-1]) {
        translate(concat(center_pos(data[i][3],data),-depth))
            union(){
            cylinder(depth,d=data[i][0]+hole_clearance);
            translate([0,0,depth-visual_clearance])
                cylinder(text_depth+visual_clearance*2,d=(data[i][0]+line_space*2));
}}}}
}


{//===FUNCTIONS AND MODULES===

module label_line (center,text_x, text_y,hole_data){
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
    
    linear_extrude(height=text_depth+1)
        polygon (points);
}    


function textpos_x (hole_data)=
    patternx==2 ?  
        text_column_p
        
    : patternx==3  && text_primary_side=="right" ?
        hole_data[3][0]==0 ? text_column_l : text_column_r
    : patternx==3 && text_primary_side=="left" ? 
        hole_data[3][0]>=1 ? text_column_l : text_column_r       
        
    : patternx==4 ?
        hole_data[3][0]<=1 ? text_column_s : text_column_p
        :0;

function text_align(posx)= //"left" or "right" depending on side where labels are, for alignment not pos
    posx==text_column_l ? "right" : "left";
    
function textpos_y(hole_data)=

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
//        hole_data[2]/2-text_size/2: static_text_offset_high; //old formula, label at top of hole
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
}

