// TODO:
// - Guide bearings holder with labels (ø in mm and std router bit)

use <math.scad>
include <constants.scad>

// Customizable parameters

Accessory = "Centering Pin"; // ["Centering Pin", "Tenon Stop"]

/* [ Tenon Stop ] */

Stop_Size = 50;    // [50:Small, 75:Medium, 100:Large]

T_Bolt_Size = 1.5;  // [1.0:"1/4-20 x 1\"", 1.5:"1/4-20 x 1.5\"", 2.0:"1/4-20 x 2\"", 2.5:"1/4-20 x 2.5\"", 3.0:"1/4-20 x 3\"", 3.5:"1/4-20 x 3.5\""]


/* [Hidden] */

$fa = 1;
$fs = 0.4;

tenon_stop_thickness = 6;


// Use this accessory through the centering hole from the back of the
// template holder to center templates that have a screw hole in place
// of a center hole (e.g. the standard dowel templates).
module centering_pin() {
    adj = 0.2;
    handle_h = 10;
    handle_d = 12;
    shaft_h = 15;
    shaft_d = center_hole_diameter + adj;
    pin_h = base_height;
    pin_d = screw_hole_diameter + adj;
    tip_h = 3;
    tip_d = 2;
    // handle
    cylinder(h=handle_h, d=handle_d, center=false, $fn=8);
    // shaft
    translate([0, 0, handle_h-eps])
        cylinder(h=shaft_h+eps, d=shaft_d, center=false);
    translate([0, 0, handle_h+shaft_h-eps]) hull() {
        // pin
        cylinder(h=2*eps, d=pin_d, center=true);
        translate([0, 0, pin_h])
            cylinder(h=tip_h, d1=pin_d, d2=tip_d, center=false);
    }
}


// This is a parametric replacement to the PantoRouter Swing Stop.
// It uses a 1/4-20 T-Bolt and a 1/4-20 Female Clamping Knob to attach
// to the edge of the PantoRouter table. The maximum clearance available
// for routing a tenon is set by the length of the T-Bolt.
module tenon_stop(clearance, stop_width, stop_height) {
    stop_thickness = tenon_stop_thickness;
    spacer_height = 28;
    radius = 5;
    t_bolt_hole = circumscribed(7);
    t_bolt_head = 18;
    t_bolt_head_clearance = t_bolt_head + 2 * 2;
    tab_protrusion = 2;
    tab_thickness = 8.2;
    tab_margin = 2;
    tab_width = (stop_width - t_bolt_head_clearance) / 2 - tab_margin;
    
    difference() {
        union() {
            // Main block
            linear_extrude(height=stop_thickness+clearance, center=false)
                offset(r=radius)
                    square([(spacer_height+stop_height)-2*radius, stop_width-2*radius], center=true);
            // Registration tabs
            translate([stop_height/2, 0, stop_thickness+clearance+tab_protrusion/2+eps]) {
                translate([0, (tab_width+t_bolt_head_clearance)/2, 0])
                    cube([tab_thickness, tab_width, tab_protrusion+2*eps], center=true);
                translate([0, -(tab_width+t_bolt_head_clearance)/2, 0])
                    cube([tab_thickness, tab_width, tab_protrusion+2*eps], center=true);
            }
        }
        // Clearance
        translate([-(spacer_height+eps)/2, 0, stop_thickness+(clearance+2*eps)/2])
            cube([stop_height+2*eps, stop_width+2*eps, clearance+2*eps], center=true);
        // Screw hole
        translate([stop_height/2, 0, -eps])
            cylinder(h=stop_thickness+clearance+2*eps, d=t_bolt_hole, center=false);
    }
    
}


function bolt_length_to_clearance(length) =
    let (
        nut_height = 10,
        track_lip = 2
    ) to_millimeters(length)-tenon_stop_thickness-nut_height-track_lip;


if (Accessory == "Centering Pin") {
    centering_pin();
} else if (Accessory == "Tenon Stop") {
    tenon_stop(
        clearance=bolt_length_to_clearance(T_Bolt_Size),
        stop_width=Stop_Size,
        stop_height=Stop_Size/2
    );
}
