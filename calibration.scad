
use <math.scad>
include <constants.scad>
use <templates.scad>

$fa = 1;
$fs = 0.4;


// create a cube with recesses for all sizes of the PantoRouter's guide
// bearings.
module guide_bearing_recesses() {
    difference() {
        translate([0, 0, 5]) cube([130, 58, 10], center=true);
        translate([-60, -24, 3]) {
            translate([48+5, 5, 0]) cylinder(h=10, r=circumscribed(10/2), center=false);
            translate([48+5, 48-6, 0]) cylinder(h=10, r=circumscribed(12/2), center=false);
            translate([48+5+5+35+5+11, 48-7.5, 0]) cylinder(h=10, r=circumscribed(15/2), center=false);
            translate([48+5+5+35+5+11, 11, 0]) cylinder(h=10, r=circumscribed(22/2), center=false);
            translate([48+5+5+17.5, 24, 0]) cylinder(h=10, r=circumscribed(35/2), center=false);
            translate([24, 24, 0]) cylinder(h=10, r=circumscribed(48/2), center=false);
        }
    }
}

module calibration_piece() {
    difference() {
        union() {
            translate([0, 0, template_height / 2]) cube([50, 30, template_height], center = true);
            translate([0, 10, template_height])
                label_part("50mm x 30mm", [46, 10]);
        }
        translate([0, 0, template_height / 2 + base_height]) hull() {
            translate([-15, 0, 0]) cube([10, 10, template_height], center=true);
            translate([15, 0, 0]) cylinder(h=template_height, d=10, center = true);
        }
        translate([-5, 0, 0]) center_hole();
        translate([-15, 0, 0]) screw_hole();
        // Center hole w/o correction for difference operation
        translate([5, 0, 0]) cylinder(h=template_height*2, d=center_hole_diameter, center=true);
        // Screw hole w/o correction for difference operation (and w/o countersink)
        translate([15, 0, 0]) cylinder(h=template_height*2, d=screw_hole_diameter, center=true);
        translate([0, -10, template_height])
            label_part("50mm x 30mm", [46, 10]);
    }
}

*guide_bearing_recesses();
calibration_piece();

