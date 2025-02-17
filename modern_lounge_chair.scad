// TODO:
// - Guide bearings holder with labels (ø in mm and std router bit)

use <math.scad>
include <templates.scad>

// Customizable parameters

Template = "a"; // [a:"Seat Front Rail", b:"Seat Back Rail (Left)", c:"Seat Back Rail (Right)", a:"Backrest Top Rail", d:"Backrest Bottom Rail"]

Registration_Tabs = true;


/* [Hidden] */

$fa = 1;
$fs = 0.4;

mortise_thickness = to_millimeters(0.25);
corner_radius=to_millimeters(0.125);
inner_guide_bearing=10;
outer_guide_bearing=10;
inner_bit = to_millimeters(0.25);
outer_bit = to_millimeters(0.5);
label_units = "f";


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


module modern_lounge_chair_template_b(
    left_p=true,
    registration_tabs_p=true) {
    angle = left_p ? 21 : -21;
    rotate([0, 0, angle]) cube(20, center=true);
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
        extra_label_text="modern lounge chair",
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

