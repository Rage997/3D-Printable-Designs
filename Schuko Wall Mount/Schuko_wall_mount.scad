$fn = 60; // Resolution for curved surfaces

// Main dimensions
side_length = 88;
height = 40;
base_thickness = 3;
wall_thickness = 4;

// Inner compartment dimensions
inner_square = 30;
inner_diameter = 70;

// Cable opening configuration
cable_hole_diameter = 20;
cable_hole_config = "x-left"; // "none", "x-left", "x-right", "y-bottom", "y-top", "both"

// Screw parameters for mounting to wall box
wall_box_screw_diameter = 4;
wall_box_screw_offset = 15; // Distance from edge to screw center

// Screw parameters for socket holder
holder_screw_diameter = 6;
holder_screw_offset = 12; // Distance from edge to screw center

// Gap parameters
gap_thickness = 0;
hole_wall_thickness = 1;

// Blind hole depth (for single-sided holes)
blind_hole_depth = 15; // How deep the single-sided holes go

difference() {
    // Main housing cube
    cube([side_length, side_length, height]);
    
    // Cut out main cylindrical compartment for socket
    translate([side_length/2, side_length/2, base_thickness]) {
        cylinder(h = height - base_thickness, d = inner_diameter);
    }
    
    // Conditional cable holes based on configuration
    if (cable_hole_config == "x-left" || cable_hole_config == "both" || cable_hole_config == "x-through") {
        // Single hole on left side only (blind hole)
        translate([-1, (side_length/2), (cable_hole_diameter/2) + base_thickness]) {
            rotate([0, 90, 0]) 
                cylinder(d = cable_hole_diameter, h = blind_hole_depth + 1);
        }
    }
    
    if (cable_hole_config == "x-right" || cable_hole_config == "both" || cable_hole_config == "x-through") {
        // Single hole on right side only (blind hole)
        translate([side_length - blind_hole_depth, (side_length/2), (cable_hole_diameter/2) + base_thickness]) {
            rotate([0, 90, 0]) 
                cylinder(d = cable_hole_diameter, h = blind_hole_depth + 1);
        }
    }
    
    if (cable_hole_config == "y-bottom" || cable_hole_config == "both" || cable_hole_config == "y-through") {
        // Single hole on bottom side only (blind hole)
        translate([side_length/2, -1, (cable_hole_diameter/2) + base_thickness]) {
            rotate([90, 0, 0]) {
                cylinder(d = cable_hole_diameter, h = blind_hole_depth + 1);
            }
        }
    }
    
    if (cable_hole_config == "y-top" || cable_hole_config == "both" || cable_hole_config == "y-through") {
        // Single hole on top side only (blind hole)
        translate([side_length/2, side_length - blind_hole_depth, (cable_hole_diameter/2) + base_thickness]) {
            rotate([90, 0, 0]) {
                cylinder(d = cable_hole_diameter, h = blind_hole_depth + 1);
            }
        }
    }

    // For through holes (go all the way through)
    if (cable_hole_config == "x-through") {
        // Through hole on X-axis (left to right)
        translate([-1, (side_length/2), (cable_hole_diameter/2) + base_thickness]) {
            rotate([0, 90, 0]) 
                cylinder(d = cable_hole_diameter, h = side_length + 2);
        }
    }
    
    if (cable_hole_config == "y-through") {
        // Through hole on Y-axis (bottom to top)
        translate([side_length/2, -1, (cable_hole_diameter/2) + base_thickness]) {
            rotate([90, 0, 0]) {
                cylinder(d = cable_hole_diameter, h = side_length + 2);
            }
        }
    }

    // Cut gap for socket mounting (if gap_thickness > 0)
    translate([0, ((side_length/2) - (inner_square/2) + (cable_hole_diameter/2) + (gap_thickness/2)), 15]) {
        cube([side_length - (2*wall_thickness), gap_thickness, height - base_thickness]);
    }
    
    // Cut rectangular cavity around central cylinder
    translate([wall_thickness, ((side_length/2) - (inner_square/2)), base_thickness]) {
        cube([side_length - (2*wall_thickness), inner_square, height - base_thickness]);
    }

    // Cut perpendicular rectangular cavity (rotated 90°)
    translate([((side_length - (2*wall_thickness))/2) + (inner_square/2) + wall_thickness, wall_thickness, base_thickness]) {
        rotate([0, 0, 90]) {
            cube([side_length - (2*wall_thickness), inner_square, height - base_thickness]);
        }
    }
    
    // Cut 4 mounting holes for wall box screws (corners)
    translate([wall_box_screw_offset, wall_box_screw_offset, -1]) {
        cylinder(d = wall_box_screw_diameter, h = height + 2);
    }
    translate([side_length - wall_box_screw_offset, wall_box_screw_offset, -1]) {
        cylinder(d = wall_box_screw_diameter, h = height + 2);
    }
    translate([wall_box_screw_offset, side_length - wall_box_screw_offset, -1]) {
        cylinder(d = wall_box_screw_diameter, h = height + 2);
    }
    translate([side_length - wall_box_screw_offset, side_length - wall_box_screw_offset, -1]) {
        cylinder(d = wall_box_screw_diameter, h = height + 2);
    }
    
    // Cut 4 mounting holes for socket holder (cardinal points)
    translate([side_length/2, holder_screw_offset, -1]) {
        cylinder(d = holder_screw_diameter, h = height + 2);
    }
    translate([side_length/2, side_length - holder_screw_offset, -1]) {
        cylinder(d = holder_screw_diameter, h = height + 2);
    }
    translate([holder_screw_offset, side_length/2, -1]) {
        cylinder(d = holder_screw_diameter, h = height + 2);
    }
    translate([side_length - holder_screw_offset, side_length/2, -1]) {
        cylinder(d = holder_screw_diameter, h = height + 2);
    }
}