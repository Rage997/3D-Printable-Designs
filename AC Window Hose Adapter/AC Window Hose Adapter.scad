/* AC Window Hose Adapter - Adjustable by Niccolo Zuppichini
 *
 * 07-08-2025
 * 
 * V1.0
 *
 * Licensing: CC BY-NC 4.0.
 * You’re free to remix, adapt, and print these files for personal use as long as proper credit is given.
 * Commercial use is not permitted without permission.
 *
 * Library included below:
 * 'Nut Job' nut, bolt, washer and threaded rod factory by Mike Thompson 1/12/2013, Thingiverse: mike_linus
 */

// ====================================================================
// CONFIGURATION PARAMETERS
// ====================================================================

/* [General] */
type = "top"; // [socket,top]

// Diameter for the plate (Top & Socket)
plate_diameter = 200;

// Height for the plate (Top & Socket)
plate_height = 3.8;

/* [Top] */
// Length of the threaded section
thread_length = 50;

// Outer diameter of the thread
thread_outer_diameter = 8;

/* [Socket] */
// Diameter for the pipe
pipe_diameter = 157;

// Height for the pipe
pipe_height = 65;

// Width of the pipe border
pipe_border = 5;

// Height of the nut
nut_height = 20;

// Outer diameter of the bolt thread to match
nut_thread_outer_diameter = 9;

// Distance between flats for the hex nut
nut_diameter = 12;

// Height for the struts
strut_height = 5;

// Width for the struts
strut_width = 5;

// Ring diameter of the struts
strut_ring_diameter = 20;

/* [Grid Parameters] */
// Height of the grid
grid_height = 5;

// Height of grid fins
fin_height = 10;

// Angle for grid fins (0 for perpendicular grids)
fin_angle = 45; // [0:90]

// Amount of grid fins
fin_amount = 25;

// Amount of fin dividers
grid_dividers = 1;

// Wall thickness of grid fins
grid_wall_thickness = 1;

// Thickness of grid dividers
divider_thickness = 1.5;

// Spacing between grid dividers
divider_spacing = 10;

/* [Mounting Holes] */
// Number of mounting holes
mounting_holes = 8; // [2:8]

// Diameter of mounting holes
mounting_hole_diameter = 4; // [3:0.5:8]

// Distance from plate edge to hole center
mounting_hole_edge_distance = 10; // [5:20]

/* [Locking Ring] */
// Enable locking ring
enable_lock = true; // [true,false]

// Number of lock tabs
lock_count = 6;

// Locking ring thickness
lock_thickness = 5; // [2:5]

// Locking ring extension (how much it protrudes inward)
lock_extension = 2.5; // [3:15]

// Locking ring height
lock_height = 3; // [10:30]

// Locking ring position from top
lock_position = 5; // [0:20]

// Lock angle
lock_angle = 5;

/* [Thread Parameters] */
// Distance between flats for the hex head or diameter for socket or button head (ignored for Rod)
head_diameter = 12;

// Thread step or Pitch (2mm works well for most applications ref. ISO262: M3=0.5,M4=0.7,M5=0.8,M6=1,M8=1.25,M10=1.5)
thread_step = 2;

// Step shape degrees (45 degrees is optimised for most printers ref. ISO262: 30 degrees)
step_shape_degrees = 45;

// Countersink in both ends
countersink = 2;

// Thread step or Pitch for nut
nut_thread_step = 2;

// Step shape degrees for nut
nut_step_shape_degrees = 45;

// Number of facets for hex head type or nut. Default is 6 for standard hex head and nut
facets = 100;

// Resolution (lower values for higher resolution, but may slow rendering)
resolution = 0.5;
nut_resolution = resolution;

// ====================================================================
// CALCULATED VALUES
// ====================================================================

// Calculate strut dimensions
strut_length = ((pipe_diameter/2) - pipe_border) - (nut_diameter/2) - ((strut_ring_diameter - nut_diameter)/2/2);
strut_pos = (nut_diameter/2) + ((strut_ring_diameter - nut_diameter)/2/2);

// ====================================================================
// GRID MODULES
// ====================================================================

module grid_fin(fin_length) {
    translate([0, 0, grid_height/2]) {
        rotate([90 - fin_angle, 0, 0]) {
            // Modified fin with extra length to prevent gaps
            cube([pipe_diameter * 1.2, grid_wall_thickness, fin_length * 1.5], true);
        }
    }
}

module grid_fins() {
    fin_length = grid_height / cos(90 - fin_angle);
    fin_spacing = pipe_diameter / fin_amount;
    
    translate([0, -pipe_diameter/2, 0]) {
        for (i = [0 : fin_amount - 1]) {
            translate([0, i * fin_spacing, 0]) {
                grid_fin(fin_length);
            }
        }
    }
}

module create_grid() {
    intersection() {
        // Outer boundary cylinder
        cylinder(grid_height, d = pipe_diameter - pipe_border * 2);
        
        // First set of angled fins
        grid_fins();
        
        // Second perpendicular set (useful if fin angle is 0)
        // rotate([0, 0, 90])
        //     grid_fins();
    }
}

// ====================================================================
// STRUT/SCREW STRUCTURE MODULES
// ====================================================================

module create_screw_structure() {
    // Four struts in cross pattern
    translate([-(strut_width/2), strut_pos, 0])
        cube([strut_width, strut_length, strut_height], false);
    
    translate([-(strut_width/2), -(strut_pos + strut_length), 0])
        cube([strut_width, strut_length, strut_height], false);
    
    translate([strut_pos, -(strut_width/2), 0])
        cube([strut_length, strut_width, strut_height], false);
    
    translate([-(strut_pos + strut_length), -(strut_width/2), 0])
        cube([strut_length, strut_width, strut_height], false);

    // Ring structure
    difference() {
        cylinder($fn = 100, strut_height, strut_ring_diameter/2, strut_ring_diameter/2, false);
        cylinder($fn = 100, strut_height, nut_diameter/2, nut_diameter/2, false);
    }   
}

// Combined grid with screw structure subtracted
module grid_with_screw_cutout() {
    difference() {
        create_grid();
        
        // Subtract the screw structure from the grid
        difference() {
            cylinder($fn = 100, strut_height, nut_diameter/2, nut_diameter/2, false);

            intersection() {
                create_screw_structure();
                // Create a cutting volume at grid height
                translate([0, 0, -0.1])
                    cylinder(h = strut_height + 0.2, d = pipe_diameter * 2);
            }
        }
    }
}

// ====================================================================
// LOCKING MECHANISM MODULES
// ====================================================================

module create_locking_tabs() {
    if (enable_lock) {
        for (i = [0 : lock_count - 1]) {
            angle = i * (360 / lock_count);
            rotate([0, 0, angle]) {
                // Position at inner surface
                translate([(pipe_diameter/2 - pipe_border), 0, pipe_height - lock_position]) {
                    difference() {
                        // Angled cube extending inward
                        rotate([0, 0, lock_angle]) {
                            translate([-lock_extension, -lock_thickness/2, 0])
                                cube([lock_extension, lock_thickness, lock_height], center = false);
                        }
                        
                        // Cutting plane to remove outer portion
                        rotate([0, 0, -lock_angle]) {
                            translate([0, -pipe_diameter, -1])
                                cube([pipe_diameter, pipe_diameter * 2, lock_height + 2]);
                        }
                    }
                }
            }
        }
    }
}

// ====================================================================
// MAIN SOCKET MODULE
// ====================================================================

module create_socket() {
    // Calculate mounting radius (distance from center to hole centers)
    mounting_radius = (plate_diameter/2) - mounting_hole_edge_distance;
    
    // Main Pipe Structure
    difference() {
        union() {
            // Base plate
            cylinder($fn = 100, plate_height, plate_diameter/2, plate_diameter/2, false);
            
            // Pipe with vents
            difference() {
                cylinder($fn = 100, pipe_height, pipe_diameter/2, pipe_diameter/2, false);
                
                // Cut out inner pipe
                translate([0, 0, -0.1])
                    cylinder($fn = 100, pipe_height + 0.2, pipe_diameter/2 - pipe_border, pipe_diameter/2 - pipe_border, false);
            }
        }
        
        // Inner cutout
        cylinder($fn = 100, 100, pipe_diameter/2 - pipe_border, pipe_diameter/2 - pipe_border, false);
        
        // Mounting holes to base plate
        for(i = [0 : mounting_holes - 1]) {
            angle = i * (360/mounting_holes);
            x = mounting_radius * cos(angle);
            y = mounting_radius * sin(angle);
            translate([x, y, -0.1])
                cylinder(h = plate_height + 0.2, d = mounting_hole_diameter, $fn = 24);
        }
    }

    // Reinforcing Ring at Top
    difference() {
        translate([0, 0, pipe_height])
            cylinder($fn = 100, 3, pipe_diameter/2, pipe_diameter/2, false);
        translate([0, 0, pipe_height])
            cylinder($fn = 100, 3.2, pipe_diameter/2 - pipe_border, pipe_diameter/2 - pipe_border, false);
    }
    
    // Add locking tabs
    create_locking_tabs();
}

// ====================================================================
// MAIN ASSEMBLY MODULE
// ====================================================================

module main() {
    if (type == "socket") {
        create_socket();
    }
}

// ====================================================================
// MAIN EXECUTION
// ====================================================================

// Execute main module
main();

// Add screw structure
create_screw_structure();

// Add the grid with screw structure subtracted at the base of the pipe
translate([0, 0, strut_height - grid_height])
    grid_with_screw_cutout();

// ====================================================================
// THREADING SYSTEM (NUT JOB LIBRARY)
// ====================================================================

// Top part with threading
if (type == "top") {
    hex_screw(thread_outer_diameter, thread_step, step_shape_degrees, thread_length, resolution, countersink, head_diameter, 0, plate_height, plate_diameter);
}

// Hex Nut (normally slightly larger outer diameter to fit on bolt correctly)
if (type == "socket") {
    hex_nut(nut_diameter, nut_height, nut_thread_step, nut_step_shape_degrees, nut_thread_outer_diameter, nut_resolution);
}

/* Library included below to allow customizer functionality    
 *   
 * polyScrewThread_r1.scad    by aubenc @ Thingiverse
 *
 * Modified by mike_mattala @ Thingiverse 1/1/2017 to remove deprecated assign
 * 
 * This script contains the library modules that can be used to generate
 * threaded rods, screws and nuts.
 *
 * http://www.thingiverse.com/thing:8796
 *
 * CC Public Domain
 */

module screw_thread(od,st,lf0,lt,rs,cs)
{
    or=od/2;
    ir=or-st/2*cos(lf0)/sin(lf0);
    pf=2*PI*or;
    sn=floor(pf/rs);
    lfxy=360/sn;
    ttn=round(lt/st+1);
    zt=st/sn;

    intersection()
    {
        if (cs >= -1)
        {
           thread_shape(cs,lt,or,ir,sn,st);
        }

        full_thread(ttn,st,sn,zt,lfxy,or,ir);
    }
}

module hex_nut(df,hg,sth,clf,cod,crs)
{

    difference()
    {
        hex_head(hg,df);

        hex_countersink_ends(sth/2,cod,clf,crs,hg);

        screw_thread(cod,sth,clf,hg,crs,-2);
    }
}


module hex_screw(od,st,lf0,lt,rs,cs,df,hg,ntl,ntd)
{
    ntr=od/2-(st/2)*cos(lf0)/sin(lf0);

    union()
    {
        hex_head(hg,df);

        translate([0,0,hg])
        if ( ntl == 0 )
        {
            cylinder(h=0.01, r=ntr, center=true);
        }
        else
        {
            if ( ntd == -1 )
            {
                cylinder(h=ntl+0.01, r=ntr, $fn=floor(od*PI/rs), center=false);
            }
            else if ( ntd == 0 )
            {
                union()
                {
                    cylinder(h=ntl-st/2,
                             r=od/2, $fn=floor(od*PI/rs), center=false);

                    translate([0,0,ntl-st/2])
                    cylinder(h=st/2,
                             r1=od/2, r2=ntr, 
                             $fn=floor(od*PI/rs), center=false);
                }
            }
            else
            {
                cylinder(h=ntl, r=ntd/2, $fn=ntd*PI/rs, center=false);
            }
        }

        translate([0,0,ntl+hg]) screw_thread(od,st,lf0,lt,rs,cs);
    }
}

module hex_screw_0(od,st,lf0,lt,rs,cs,df,hg,ntl,ntd)
{
    ntr=od/2-(st/2)*cos(lf0)/sin(lf0);

    union()
    {
        hex_head_0(hg,df);

        translate([0,0,hg])
        if ( ntl == 0 )
        {
            cylinder(h=0.01, r=ntr, center=true);
        }
        else
        {
            if ( ntd == -1 )
            {
                cylinder(h=ntl+0.01, r=ntr, $fn=floor(od*PI/rs), center=false);
            }
            else if ( ntd == 0 )
            {
                union()
                {
                    cylinder(h=ntl-st/2,
                             r=od/2, $fn=floor(od*PI/rs), center=false);

                    translate([0,0,ntl-st/2])
                    cylinder(h=st/2,
                             r1=od/2, r2=ntr, 
                             $fn=floor(od*PI/rs), center=false);
                }
            }
            else
            {
                cylinder(h=ntl, r=ntd/2, $fn=ntd*PI/rs, center=false);
            }
        }

        translate([0,0,ntl+hg]) screw_thread(od,st,lf0,lt,rs,cs);
    }
}

module thread_shape(cs,lt,or,ir,sn,st)
{
    if ( cs == 0 )
    {
        cylinder(h=lt, r=or, $fn=sn, center=false);
    }
    else
    {
        union()
        {
            translate([0,0,st/2])
              cylinder(h=lt-st+0.005, r=or, $fn=sn, center=false);

            if ( cs == -1 || cs == 2 )
            {
                cylinder(h=st/2, r1=ir, r2=or, $fn=sn, center=false);
            }
            else
            {
                cylinder(h=st/2, r=or, $fn=sn, center=false);
            }

            translate([0,0,lt-st/2])
            if ( cs == 1 || cs == 2 )
            {
                  cylinder(h=st/2, r1=or, r2=ir, $fn=sn, center=false);
            }
            else
            {
                cylinder(h=st/2, r=or, $fn=sn, center=false);
            }
        }
    }
}

module full_thread(ttn,st,sn,zt,lfxy,or,ir)
{
  if(ir >= 0.2)
  {
    for(i=[0:ttn-1])
    {
        for(j=[0:sn-1])
        {
			pt = [[0,0,i*st-st],
                 [ir*cos(j*lfxy),     ir*sin(j*lfxy),     i*st+j*zt-st       ],
                 [ir*cos((j+1)*lfxy), ir*sin((j+1)*lfxy), i*st+(j+1)*zt-st   ],
				 [0,0,i*st],
                 [or*cos(j*lfxy),     or*sin(j*lfxy),     i*st+j*zt-st/2     ],
                 [or*cos((j+1)*lfxy), or*sin((j+1)*lfxy), i*st+(j+1)*zt-st/2 ],
                 [ir*cos(j*lfxy),     ir*sin(j*lfxy),     i*st+j*zt          ],
                 [ir*cos((j+1)*lfxy), ir*sin((j+1)*lfxy), i*st+(j+1)*zt      ],
                 [0,0,i*st+st]];
               
            polyhedron(points=pt,faces=[[1,0,3],[1,3,6],[6,3,8],[1,6,4], //changed triangles to faces (to be deprecated)
										[0,1,2],[1,4,2],[2,4,5],[5,4,6],[5,6,7],[7,6,8],
										[7,8,3],[0,2,3],[3,2,7],[7,2,5]	]);
        }
    }
  }
  else
  {
    echo("Step Degrees too agresive, the thread will not be made!!");
    echo("Try to increase de value for the degrees and/or...");
    echo(" decrease the pitch value and/or...");
    echo(" increase the outer diameter value.");
  }
}

module hex_head(hg,df)
{
	rd0=df/2/sin(60);
	x0=0;	x1=df/2;	x2=x1+hg/2;
	y0=0;	y1=hg/2;	y2=hg;

	intersection()
	{
	   cylinder(h=hg, r=rd0, $fn=facets, center=false);

		rotate_extrude(convexity=10, $fn=6*round(df*PI/6/0.5))
		polygon([ [x0,y0],[x1,y0],[x2,y1],[x1,y2],[x0,y2] ]);
	}
}

module hex_head_0(hg,df)
{
    cylinder(h=hg, r=df/2/sin(60), $fn=6, center=false);
}

module hex_countersink_ends(chg,cod,clf,crs,hg)
{
    translate([0,0,-0.1])
    cylinder(h=chg+0.01, 
             r1=cod/2, 
             r2=cod/2-(chg+0.1)*cos(clf)/sin(clf),
             $fn=floor(cod*PI/crs), center=false);

    translate([0,0,hg-chg+0.1])
    cylinder(h=chg+0.01, 
             r1=cod/2-(chg+0.1)*cos(clf)/sin(clf),
             r2=cod/2, 
             $fn=floor(cod*PI/crs), center=false);
}