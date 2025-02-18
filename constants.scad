/* [Hidden] */

// All quantities within the library are in millimeters and are only
// converted to other units for input and output.
INCH_TO_MM = 25.4;
UNIT_OF_MILLIMETERS = 0;
UNIT_OF_DECIMAL_INCHES = 1;
UNIT_OF_FRACTIONAL_INCHES = 2;

// The standard size of router bit and guide bearings assumed by the
// labels on the original PantoRouter templates.
std_inner_bit = 0.5 * INCH_TO_MM;
std_outer_bit = 0.5 * INCH_TO_MM;
std_inner_guide_bearing = 10;
std_outer_guide_bearing = 22;

//
// A set of measurements taken from the original PantoRouter templates.
//

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
track_spacing = 20;
registration_tab_thickness = 4.2;

//
// A few more measurements shared by all templates in this library.
//

registration_tab_intrusion = 0.6;
registration_tab_protrusion = 1.2;
registration_tab_spacer = 2.2;
center_mark_height = 3;
center_mark_depth = 0.6;
text_margin = 4;
label_height = 0.4;
min_screw_spacing = screw_countersink_diameter;

// Labels try to take 70% of the vertical space available.
text_size_factor = 0.7;

// Circular holes are approximated by polygons; the code adjusts the radius
// so that the approximating polygons is circumscribed to the real circle
// (rather than being inscribed by default), but the radius still needs
// to be increased by a little bit in order for the pantorouter centering
// pin or guide bearing rods to fit through them.
hole_radius_adjust = 0.12;

// Inner radiuses are increased by a tiny amount in so that the PantoRouter
// guide bearings of the same size can fit all the way inside them.
inner_radius_adjust = 0.08;

// A small epsilon is used to ensure coplanar surfaces do not cause trouble
// with CSG operators.
eps = 0.01;
