// Customizable Elliptical Case with USB-C Port
// All dimensions in millimeters

/* [Case Dimensions] */
// Length of the case (X-axis)
case_length = 80;
// Width of the case (Y-axis)
case_width = 60;
// Height of the case (Z-axis)
case_height = 20;
// Wall thickness
wall_thickness = 2;

/* [USB-C Port] */
// USB-C port width
usbc_width = 9;
// USB-C port height
usbc_height = 3.2;
// USB-C port depth (how far it goes into the case)
usbc_depth = 8;
// USB-C port position from bottom (Z position)
usbc_z_position = 5;
// USB-C port angle around the case (0-360 degrees)
usbc_angle = 0;

/* [Opening] */
// Height of the top opening (from top)
opening_height = 5;
// Opening width (X-axis, 0 = full width)
opening_width = 0;
// Opening depth (Y-axis, 0 = full depth)
opening_depth = 0;
// Opening corner radius
opening_radius = 2;

/* [Inner Mount Structure] */
enable_inner_circle = true;
inner_circle_position = 5;
inner_circle_height = 2;
inner_circle_diameter = 50;
inner_ring_thickness = 2;

/* [Advanced] */
// Smoothness (higher = smoother, but slower)
$fn = 100;

module usbc_port() {
    // USB-C connector shape with rounded corners
    hull() {
        r = usbc_height / 2;
        translate([0, -(usbc_width/2 - r), -(usbc_height/2 - r)])
            rotate([0, 90, 0])
                cylinder(h=usbc_depth, r=r);
        translate([0, (usbc_width/2 - r), -(usbc_height/2 - r)])
            rotate([0, 90, 0])
                cylinder(h=usbc_depth, r=r);
        translate([0, -(usbc_width/2 - r), (usbc_height/2 - r)])
            rotate([0, 90, 0])
                cylinder(h=usbc_depth, r=r);
        translate([0, (usbc_width/2 - r), (usbc_height/2 - r)])
            rotate([0, 90, 0])
                cylinder(h=usbc_depth, r=r);
    }
}

module rounded_box(x, y, z, r) {
    hull() {
        translate([-(x/2 - r), -(y/2 - r), 0])
            cylinder(h=z, r=r);
        translate([(x/2 - r), -(y/2 - r), 0])
            cylinder(h=z, r=r);
        translate([-(x/2 - r), (y/2 - r), 0])
            cylinder(h=z, r=r);
        translate([(x/2 - r), (y/2 - r), 0])
            cylinder(h=z, r=r);
    }
}

module elliptical_case() {
    difference() {
        // Outer shell - extruded ellipse
        linear_extrude(height=case_height)
            scale([case_length/2, case_width/2])
                circle(r=1);
        
        // Inner cavity - extruded smaller ellipse (open top)
        translate([0, 0, wall_thickness])
            linear_extrude(height=case_height)
                scale([(case_length/2 - wall_thickness), (case_width/2 - wall_thickness)])
                    circle(r=1);
        
        // USB-C port cutout (horizontal)
        rotate([0, 0, usbc_angle])
        translate([case_length/2 - usbc_depth + 0.1, 0, usbc_z_position])
        usbc_port();
    }
    
    // Inner circle mount ring (for gluing plate inside) - added AFTER the difference
    if (enable_inner_circle) {
        translate([0, 0, case_height - inner_circle_position])
            linear_extrude(height=inner_circle_height)
                difference() {
                    scale([(case_length/2 - wall_thickness), (case_width/2 - wall_thickness)])
                        circle(r=1);
                    circle(d=inner_circle_diameter);
                }
    }
}

// Render the case
elliptical_case();