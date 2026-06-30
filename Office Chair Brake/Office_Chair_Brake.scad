////////////////////////////
// VARIABLES



/* [Wheel] */

//Wheel Diameter
wheelDiameter = 55;

wheelRadius = wheelDiameter/2;

//Thickness of Entire Wheel Structure
wheelThickness = 54;

//Space Between Wheels
wheelSpace = 22;


/* [Brake] */

//Height of Brake
boxHeight = 20;

boxThickness = wheelThickness+1;

//Brake Floor Thickness
boxBottomThickness = 2;

//Approx Groove Size for Inner Brace
innerBraceGroove = 35;


/* [Mounting Base] */

// Extra width of base beyond brake block on each side
baseOverhang = 15;

// Thickness of the base plate
baseThickness = 6;

// Diameter of each mounting screw hole
holeDiameter = 5;

// Distance from the nearest base edge to the hole centre
holeEdgeOffset = 7;

// Add a countersink for a flat/flush screw head? (1 = yes, 0 = no)
addCountersink = 1;

// Countersink angle (degrees) – 90° suits most flat-head screws
countersinkAngle = 90;

// Countersink head diameter (flat-head M5 ≈ 10 mm)
countersinkHeadDiameter = 10;


/* [Hidden] */
$fn = 120;


////////////////////////////
// COMPUTED DIMENSIONS

baseWidth  = boxThickness + 2 * baseOverhang;
baseDepth  = wheelDiameter + 2 * baseOverhang;


////////////////////////////
// MODULES

// Drill one hole (+ optional countersink) at position [hx, hy] on the base plate
// Hole runs along Z, entering from the top and exiting at the bottom (floor side)
module mountingHole(hx, hy) {
    // Shaft – full depth through the plate, from top (z=0) to bottom (z=-baseThickness)
    translate([hx, hy, -baseThickness - 0.1])
        cylinder(h = baseThickness + 0.2, d = holeDiameter);

    // Countersink – cone opening upward from the top face (screw enters from above)
    if (addCountersink == 1) {
        csDepth = (countersinkHeadDiameter - holeDiameter) / 2 / tan(countersinkAngle / 2);
        translate([hx, hy, -csDepth])
            cylinder(h = csDepth + 0.1, d1 = holeDiameter, d2 = countersinkHeadDiameter);
    }
}

module mountingBase() {
    hx_left  = -baseOverhang + holeEdgeOffset;
    hx_right =  boxThickness + baseOverhang - holeEdgeOffset;
    hy_front = -baseOverhang + holeEdgeOffset;
    hy_back  =  wheelDiameter + baseOverhang - holeEdgeOffset;

    difference() {
        // Base plate
        translate([-baseOverhang, -baseOverhang, -baseThickness])
            cube([baseWidth, baseDepth, baseThickness]);

        // Four corner holes
        mountingHole(hx_left,  hy_front);
        mountingHole(hx_right, hy_front);
        mountingHole(hx_left,  hy_back);
        mountingHole(hx_right, hy_back);
    }
}


////////////////////////////
// RENDER

union() {
    // ── Original brake assembly ──────────────────────────────────────────
    intersection()
    {
        //ROUNDED CORNER
        translate([boxThickness/2, wheelDiameter, -((wheelThickness+1)*(17/32))])
            rotate([90,0,0])
                cylinder(r=wheelThickness+1, h=wheelDiameter);

        union()
        {
            translate([((wheelThickness+1)/2)-(wheelSpace/2), 0, (wheelDiameter/2)])
            //INNER BRACE
            difference()
            {
                //BRACE
                translate([0, wheelDiameter/2, 0]) rotate([0,90,0])
                    cylinder(h=wheelSpace, d=wheelDiameter);

                union()
                {
                    //Brace Top Subtraction
                    translate([-(wheelThickness/2) + (wheelSpace/2), 0, boxHeight-(wheelRadius)])
                        cube([wheelThickness, wheelDiameter+1, wheelDiameter - boxHeight]);
                    //Brace Groove Subtraction
                    translate([-.1, wheelDiameter/2, 0]) rotate([0,90,0])
                        cylinder(h=wheelSpace+1, d=innerBraceGroove);
                }
            }

            //MAIN BLOCK
            difference()
            {
                cube([boxThickness, wheelDiameter, boxHeight]);

                rotate([0,90,0])
                    translate([-(wheelDiameter/2+boxBottomThickness), wheelDiameter/2, -.1])
                        cylinder(h=wheelThickness+2, d=wheelDiameter);
            }
        }
    }

    // ── Mounting base ────────────────────────────────────────────────────
    mountingBase();
}