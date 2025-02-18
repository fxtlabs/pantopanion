// TODO:
// - Guide bearings holder with labels (ø in mm and std router bit)

use <math.scad>
include <constants.scad>
use <templates.scad>

// Customizable parameters

Template = "a"; // [a:"Seat Front Rail / Backrest Top Rail", b:"Seat Back Rail (Left)", c:"Seat Back Rail (Right)", d:"Backrest Bottom Rail"]

Registration_Tabs = true;


/* [Hidden] */

$fa = 1;
$fs = 0.4;

mortise_thickness = to_millimeters(1/4);
corner_radius=to_millimeters(mortise_thickness / 2);
inner_guide_bearing=10;
outer_guide_bearing=10;
inner_bit = to_millimeters(1/4);
outer_bit = to_millimeters(1/2);
label_units = UNIT_OF_FRACTIONAL_INCHES;
extra_label_text = "MODERN LOUNGE CHAIR";


module modern_lounge_chair_template_a(registration_tabs_p=true) {
    mt_template(
        mortise_width=to_millimeters(1 + 7/16),
        mortise_thickness=mortise_thickness,
        corner_radius=corner_radius,
        inner_guide_bearing=inner_guide_bearing,
        outer_guide_bearing=outer_guide_bearing,
        inner_bit=inner_bit,
        outer_bit=outer_bit,
        vertical_p=false,
        label_units=label_units,
        registration_tabs_p=registration_tabs_p);
}


module complete_template_b(angle, width, thickness, registration_tabs_p) {
    difference() {
        children(0);
        center_hole();
        translate([-track_spacing, -tan(angle)*track_spacing, 0])
            screw_hole();
        translate([track_spacing, tan(angle)*track_spacing, 0])
            screw_hole();
        difference() {
            registration_tabs(width, thickness, vertical_p=true);
            translate([-track_spacing, -tan(angle)*track_spacing, 0])
                screw_hole_clearance();
            translate([track_spacing, tan(angle)*track_spacing, 0])
                screw_hole_clearance();
        }
    }

    if (registration_tabs_p) {
        // Include the registration tabs for printing 
        translate([0, (thickness + (thickness - 2 * registration_tab_spacer)) / 2 + registration_tab_spacer, registration_tab_protrusion])
            difference() {
                registration_tabs(width, thickness, vertical_p=true);
                translate([-track_spacing, -tan(angle)*track_spacing, 0])
                    screw_hole_clearance();
                translate([track_spacing, tan(angle)*track_spacing, 0])
                    screw_hole_clearance();
            }
    }   
}


module modern_lounge_chair_template_b(
    left_p=true,
    distance=to_millimeters(1/4 + 3/4),
    registration_tabs_p=true) {

    flip = left_p ? -1 : 1;
    angle = 21 * flip;
    vertical_p=true;
    mortise_width1 = to_millimeters(1 + 3/16);
    mortise_width2 = to_millimeters(15/16);

    // I wish OpenSCAD supported objects :-(
    dimensions1 = mt_template_dimensions(mortise_width1, mortise_thickness, corner_radius, inner_guide_bearing, outer_guide_bearing, inner_bit, outer_bit);
    dimensions2 = mt_template_dimensions(mortise_width2, mortise_thickness, corner_radius, inner_guide_bearing, outer_guide_bearing, inner_bit, outer_bit);
    outer_width1 = dimensions1[0];
    outer_thickness = dimensions1[1];
    outer_radius = dimensions1[2];
    inner_width1 = dimensions1[3];
    inner_thickness = dimensions1[4];
    inner_radius = dimensions1[5];
    outer_width2 = dimensions2[0];
    inner_width2 = dimensions2[3];
    
    d = outer_width1 + taper - 2 * (outer_radius + taper / 2);
    base_width = cos(angle) * d + 2 * (outer_radius + taper / 2);
    base_thickness = sin(abs(angle)) * d + outer_thickness + taper + 2 * distance / cos(angle);

    mt_size_label_text = mt_size_text(mortise_width1, mortise_thickness, vertical_p, label_units);
    settings_label_text = settings_text(inner_guide_bearing, outer_guide_bearing, inner_bit, outer_bit);
    distance_label_text = str(">", as_value_with_units(distance, label_units), "< ", left_p ? "LEFT" : "RIGHT");
    
    complete_template_b(angle,
        width=base_width,
        thickness=base_thickness,
        registration_tabs_p=registration_tabs_p
    ) union() {
        rotate([0, 0, angle]) {
        // First M&T
        translate([flip*tan(angle)*distance, flip*distance, base_height-eps])
            baseless_mt_template(
                mortise_width=mortise_width1,
                mortise_thickness=mortise_thickness,
                corner_radius=corner_radius,
                inner_guide_bearing=inner_guide_bearing,
                outer_guide_bearing=outer_guide_bearing,
                inner_bit=inner_bit,
                outer_bit=outer_bit,
                top_label_text=mt_size_label_text,
                bottom_label_text=settings_label_text
            );
        // Second M&T
        translate([-flip*tan(angle)*distance+mortise_width1-mortise_width2, -flip*distance, base_height-eps])
            baseless_mt_template(
                mortise_width=mortise_width2,
                mortise_thickness=mortise_thickness,
                corner_radius=corner_radius,
                inner_guide_bearing=inner_guide_bearing,
                outer_guide_bearing=outer_guide_bearing,
                inner_bit=inner_bit,
                outer_bit=outer_bit,
                top_label_text=distance_label_text,
                bottom_label_text=extra_label_text
            );
        }
        // Base Plate
        base_plate(
            width=base_width,
            thickness=base_thickness,
            radius=outer_radius+taper/2
        );
    }
}


module modern_lounge_chair_template_c(registration_tabs_p=true) {
    modern_lounge_chair_template_b(
        left_p=false, registration_tabs_p=registration_tabs_p);
}


module modern_lounge_chair_template_d(
    distance=to_millimeters(1/4 + 13/16),
    registration_tabs_p=true) {
    double_mt_template(
        distance=distance,
        mortise_width=to_millimeters(1 + 3/16),
        mortise_thickness=mortise_thickness,
        corner_radius=corner_radius,
        inner_guide_bearing=inner_guide_bearing,
        outer_guide_bearing=outer_guide_bearing,
        inner_bit=inner_bit,
        outer_bit=outer_bit,
        vertical_p=true,
        label_units=label_units,
        extra_label_text=extra_label_text,
        registration_tabs_p=registration_tabs_p);
}


if (Template == "a") {
    modern_lounge_chair_template_a(registration_tabs_p=Registration_Tabs);
} else if (Template == "b") {
    modern_lounge_chair_template_b(registration_tabs_p=Registration_Tabs);
} else if (Template == "c") {
    modern_lounge_chair_template_c(registration_tabs_p=Registration_Tabs);
} else if (Template == "d") {
    modern_lounge_chair_template_d(registration_tabs_p=Registration_Tabs);
}

