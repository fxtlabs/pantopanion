// TODO:
// - Guide bearings holder with labels (ø in mm and std router bit)

use <math.scad>
include <constants.scad>

$fa = 1;
$fs = 0.4;


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

centering_pin();