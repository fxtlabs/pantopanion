use <math.scad>

/* [Hidden] */

hole_fn = 64;

std_inner_bit = to_millimeters(0.5);
std_outer_bit = to_millimeters(0.5);
std_inner_guide_bearing = 10;
std_outer_guide_bearing = 22;

template_height = 12;
base_height = 3.6;
baseless_height = 10;
// The outside of the template tapers in by 2 mm all around; that amounts
// to a slope of 10° on the standard M&T templates, but a slope of 12° on
// the triple tenon template which has a flanged base before starting to
// taper.
taper = 2;
n_mortise_steps = 3;
mortise_step_width = 1;
center_hole_diameter = 6;
screw_hole_diameter = 4;
screw_countersink_diameter = 9;
screw_countersink_angle = 90;
min_screw_spacing = screw_countersink_diameter;
track_spacing = 20;
registration_tab_thickness = 4.2;
registration_tab_intrusion = 0.6;
registration_tab_protrusion = 1.2;
registration_tab_spacer = 2.2;
center_mark_height = 3;
center_mark_depth = 0.6;
text_margin = 4;
label_height = 0.4;

hole_radius_adjust = 0.12;
inner_radius_adjust = 0.08;
eps = 0.01;
