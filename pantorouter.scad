// PantoRouter template generator

// This code follows the naming conventions used in the PantoRouter
// How-To Guide.
// Mortises and tenons are defined by the width, thickness, and depth/length.
// Width and h_* or horizontal refer to the x axis.
// Thickness and v_* or vertical refer to the y axis.
// Height and depth refer to the z axis.

// TODO:
// - The standard dowel template could have a tiny bit of taper in the
//   mortise slot
// - Guide bearings holder with labels (ø in mm and std router bit)
// - Create a parametric spacer to enable proper spacing and centering
//   of double M&Ts (vertical orientation)
// - Consider adding flanges when the holes do not fit inside the
//   mortise part (should they extend vertically or horizontally?
//   Horizontally for vertical templates, but harder to say for horizontal
//   templates; I would go for vertically so they are not in the way of
//   a lineup of templates (which would not stack vertically because they
//   would be limited to the tracks spacing).
//   Make flanges a user option, independent on whether the mortise part
//   has space for the holes or not.
// - Haunched mortise and tenon
// - Reorganize code into several files: customizer.scad, constants.scad,
//   math.scad, utilities.scad, accessories.scad, templates.scad (maybe
//   rename the project to PantoRouter Templates as well).

use <math.scad>
use <BOSL/math.scad>
use <BOSL/shapes.scad>
include <BOSL/constants.scad>


// Customizable parameters

Template = "M&T"; // ["Dowel", "M&T", "Std Dowel", "Std M&T", "Double M&T", "Std M&T Spacer", "Centering Pin", "Calibration"]

Inner_Bit = 0.375; // [0.125:"1/8\"", 0.1875:"3/16\"", 0.25:"1/4\"", 0.3125:"5/16\"", 0.375:"3/8\"", 0.5:"1/2\"", 0.75:"3/4\"", 1:"1\""]
Outer_Bit = 0.5; // [0.125:"1/8\"", 0.1875:"3/16\"", 0.25:"1/4\"", 0.3125:"5/16\"", 0.375:"3/8\"", 0.5:"1/2\"", 0.75:"3/4\"", 1:"1\""]
Inner_Guide_Bearing = 10;   // [6:6 mm, 10:10 mm, 12:12 mm, 15:15 mm, 22:22 mm, 35:35 mm, 48:48 mm]
Outer_Guide_Bearing = 15;   // [6:6 mm, 10:10 mm, 12:12 mm, 15:15 mm, 22:22 mm, 35:35 mm, 48:48 mm]
Label_Units = "f";  // [d:Decimal Inches, f:Fractional Inches, m:Millimeters]
Bottom_Label = true;
Registration_Tabs = true;

/* [ Mortise And Tenon Template ] */

Orientation = "H"; // [H:Horizontal, V:Vertical]
// in inches
Mortise_Width = 2.5; // [0.25:0.0625:4]
// in inches
Mortise_Thickness = 0.5; // [0.125:0.0625:2]
// in inches
Corner_Radius = 0;   // [0:0.0625:1]

/* [ Dowel Template ] */

// in inches
Dowel_Diameter = 1; // [0.25:0.125:4]

/* [ Mortise And Tenon Spacer Template ] */

Mortises_Spacing = 1; // [0.75:0.0625:4]

/* [Hidden] */

$fa = 1;
$fs = 0.4;
hole_fn = 64;

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

module tenon_part(height, width, thickness, radius) {
    dx = width / 2 - radius;
    dy = thickness / 2 - radius;
    d_r = taper / 2;

    if (radius > eps) {
        // rounded ends
        hull() {
            translate([dx, dy, 0])
                cylinder(h=height, r1=radius+d_r, r2=radius-d_r, center=false);
            if (dx > 0) {
                translate([-dx, dy, 0])
                    cylinder(h=height, r1=radius+d_r, r2=radius-d_r, center=false);
            }
            if (dy > 0) {
                translate([dx, -dy, 0])
                    cylinder(h=height, r1=radius+d_r, r2=radius-d_r, center=false);
                if (dx > 0) {
                    translate([-dx, -dy, 0])
                        cylinder(h=height, r1=radius+d_r, r2=radius-d_r, center=false);
                }
            }
        }
    } else {
        // square ends
        // The intersection is used to remove the bottom part of the hull
        // because that is not tapered
        intersection() {
            hull() {
                translate([0, 0, height - eps / 2])
                    cube([width-taper, thickness-taper, eps], center=true);
                translate([0, 0, -eps / 2])
                    cube([width+taper, thickness+taper, eps], center=true);                    
            }
            translate([0, 0, height])
                cube([2 * width, 2 * thickness, 2 * height], center=true);
        }
    }
}

module mortise_part(height,width, thickness, radius) {
    step_height = height / n_mortise_steps;
    offset = max(width / 2 - radius, 0);
    dy = thickness / 2 - radius;
    intersection() {
        union() {
            for (i=[0:1:n_mortise_steps-1]) {
                hull() {
                    dx = offset + mortise_step_width * i;
                    dz = step_height * i;
                    translate([-dx, dy, dz])
                        cylinder(h=height, r=radius, center=false);
                    translate([dx, dy, dz])
                        cylinder(h=height, r=radius, center=false);
                    if (dy > eps) {
                        translate([-dx, -dy, dz])
                            cylinder(h=height, r=radius, center=false);
                        translate([dx, -dy, dz])
                            cylinder(h=height, r=radius, center=false);
                    }
                }
            }
        }
        translate([0, 0, height/2+eps])
            cube([width+2*(n_mortise_steps*mortise_step_width), thickness, height+2*eps], center=true);
    }
}

// Given the radius of a circle (or cylinder), return a new radius that would
// yield a polygonal approximation that circumscribes the original circle.
// Use it for subtracted shapes so that the resulting hole is as big as
// requested.
// References:
// https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/undersized_circular_objects
function circumscribed(radius) =
    let (n = segs(radius)) radius / cos(180 / n);

module center_hole() {
    radius = circumscribed(center_hole_diameter / 2) + hole_radius_adjust;
    cylinder(h=template_height*2, r=radius, center=true);
}

module screw_hole() {
    countersink_radius = screw_countersink_diameter / 2 + hole_radius_adjust;
    countersink_height =
        countersink_radius / tan(screw_countersink_angle / 2);
    screw_hole_radius = circumscribed(screw_hole_diameter / 2) + hole_radius_adjust;
    union() {
        cylinder(h=template_height*2, r=screw_hole_radius, center=true);
        translate([0, 0, base_height - countersink_height + eps])
            cylinder(countersink_height, r1=0, r2=countersink_radius, center=false);
    }
}

module center_hole_clearance() {
    side = center_hole_diameter + 2 * registration_tab_spacer;
    cube([side, side, 2*template_height], center=true);
}

module screw_hole_clearance() {
    side = screw_hole_diameter + 2 * registration_tab_spacer;
    cube([side, side, 2*template_height], center=true);
}

function v_screw_position(width) =
    // For vertical templates, either the screws can go into the upper and
    // lower tracks of the template holder or we put a single screw in the
    // middle track
    (width >= 2 * track_spacing + screw_countersink_diameter) ? track_spacing : 0;

function h_screw_position(width) =
    // For horizontal templates, the screws are spaced out along
    // the middle track of the template holder, getting closer and
    // closer to the ends
    (width >= 2 * track_spacing + screw_countersink_diameter) ?
        (((width - screw_countersink_diameter) / 2 + track_spacing) / 2) :
        ((width > min_screw_spacing + screw_countersink_diameter) ?
            ((width - screw_countersink_diameter) / 2) : 0);

function screw_layout(width, thickness, vertical_p) =
    vertical_p ? v_screw_position(width=width) : h_screw_position(width=width);

function holes_layout(width, thickness, vertical_p) =
    let (
        screw_position = screw_layout(width=width, thickness=thickness, vertical_p=vertical_p)
    )
        (2 * screw_position > min_screw_spacing + center_hole_diameter) ? [screw_position, 0] : [screw_position, undef];

// Operator module. The first child should create the center hole;
// the second child the screw hole.        
module position_holes(width, thickness, vertical_p) {
    assert(thickness >= screw_countersink_diameter);
    assert(width >= screw_countersink_diameter);
    positions = holes_layout(width=width, thickness=thickness, vertical_p=vertical_p);
    screw_position = positions[0];
    center_hole_position = positions[1];
    if (screw_position <= eps) {
        // There is only enough space for one screw in the center
        children(1);
    } else {
        union() {
            translate([-screw_position, 0, 0]) children(1);
            translate([screw_position, 0, 0]) children(1);
            if (center_hole_position == 0) {
                children(0);
            }
        }
    }
}

module center_mark() {
    size = 2 * center_mark_height;
    rotate([0, 0, 45]) cube(size, center=true);
}

module center_marks(width, thickness, vertical_p) {
    if (vertical_p) {
        center_mark_x = (width + taper) / 2 + center_mark_height * sqrt(2) - center_mark_depth;
        translate([-center_mark_x, 0, 0]) center_mark();
        translate([center_mark_x, 0, 0]) center_mark();
    } else {
        center_mark_y = (thickness + taper) / 2 + center_mark_height * sqrt(2) - center_mark_depth;
        translate([0, -center_mark_y, 0]) center_mark();
        translate([0, center_mark_y, 0]) center_mark();
    }
}

module registration_tab(base_width) {
    width = base_width - 2 * registration_tab_spacer;
    thickness = registration_tab_thickness;
    wall = registration_tab_protrusion + registration_tab_intrusion;

    rotate([0, 0, 90]) translate([0, 0, -registration_tab_protrusion])
        narrowing_strut(w=thickness, l=width, wall=wall, ang=45);
}

module registration_tabs(base_width, base_thickness, vertical_p=false) {
    if (vertical_p) {
        rotate([0, 0, 90]) union() {
            translate([0, track_spacing, 0])
                registration_tab(base_thickness);
            translate([0, -track_spacing, 0])
                registration_tab(base_thickness);
        }
    } else {
        registration_tab(base_width);
    }
}

function top_label_string(value, units) =
    units == "d" ?
        as_decimal_inches(to_inches(value)) :
        (units == "f" ?
            as_fractional_inches(to_inches(value)) :
            as_millimeters(value));

function bottom_label_string(inner_guide_bearing, outer_guide_bearing, inner_bit, outer_bit) =
    let (
        inner_bit_s = as_fractional_inches(to_inches(inner_bit)),
        outer_bit_s = as_fractional_inches(to_inches(outer_bit)),
        inner_guide_bearing_s = as_millimeters(inner_guide_bearing),
        outer_guide_bearing_s = as_millimeters(outer_guide_bearing),
        mortise_s = str("M", inner_bit_s, "•", inner_guide_bearing),
        tenon_s = str("T", outer_bit_s, "•", outer_guide_bearing)
    )
        str(mortise_s, " ", tenon_s);
    
module mt_label(label_text, width, height=0, top, bottom) {
    if (len(label_text) > 0) {
        text_size = height > 0 ? height : (top - bottom) * 0.7;
        dy = (top + bottom) / 2;
        tm = textmetrics(size=text_size, halign="center", valign="center", text=label_text);
        too_big_p = tm.size.x / tm.size.y > width / text_size;
        /* NOTE: use the following snippet if you do not want to use
           the experimental textmetrics() function.
        // The average ratio of height to width of characters is 6:5
        too_big_p = len(label_text) > (width / text_size) * 5 / 5.75;
        */
        color("blue") translate([0, dy, template_height]) {
            linear_extrude(height=label_height*2, center=true) {
                if (too_big_p) {
                    resize([width, 0, 0], auto=[true, true, false])
                        text(size=text_size, halign="center", valign="center", text=label_text);
                } else {
                    text(size=text_size, halign="center", valign="center", font=":style=Bold", text=label_text);
                }
            }
        }
    }
}

module dowel_label(label_text, top, bottom) {
    n_chars = len(label_text);
    if (n_chars > 0) {
        opt_text_size = (top - bottom) * 0.7;
        radius = bottom + (top - bottom - opt_text_size) / 2;
        tm = textmetrics(size=opt_text_size, halign="center", valign="baseline", text=label_text);
        text_size = opt_text_size * min(tm.size.x, PI * abs(radius)) / tm.size.x;
        widths = [for (c = label_text) textmetrics(size=text_size, halign="left", valign="baseline", text=c).advance.x];
        total_width = sum(widths);
        total_a = 180 * total_width / (PI * radius);
        start_a = total_a / 2;
        da = total_a / total_width;
        start_as = [for (a = start_a, i = 0; i < len(widths); a = a - da * widths[i], i = i + 1) a];
        for(i = [0 : n_chars - 1]) {
            rotate([0, 0, start_as[i]])
                translate([0, radius, template_height]) {
                    linear_extrude(height=label_height*2, center=true) {
                        text(size=text_size, halign="left", valign="baseline", font=":style=Bold", text=label_text[i]);
                    }
                }
        }
    }
}   

module base_plate(width, thickness, radius) {
    dx = width / 2 - radius;
    dy = thickness / 2 - radius;
    height = base_height;

    if (radius > eps) {
        // rounded ends
        hull() {
            translate([dx, dy, 0])
                cylinder(h=height, r=radius, center=false);
            translate([-dx, dy, 0])
                cylinder(h=height, r=radius, center=false);
            translate([dx, -dy, 0])
                cylinder(h=height, r=radius, center=false);
            translate([-dx, -dy, 0])
                cylinder(h=height, r=radius, center=false);
        }
    } else {
        // square ends
        translate([0, 0, base_height/2])
            cube([width, thickness, base_height], center=true);
    }        
}

module double_mt_template(
    distance,
    mortise_width,
    mortise_thickness,
    corner_radius,
    inner_guide_bearing,
    outer_guide_bearing,
    inner_bit,
    outer_bit,
    vertical_p=false,
    label_units,
    bottom_label_p,
    registration_tabs_p=true) {
    assert(inner_bit <= mortise_thickness, "The router bit used for the mortise cannot be bigger than the mortise thickness!");
    assert(inner_bit <= mortise_width, "The router bit used for the mortise cannot be bigger than the mortise width!");
    assert(mortise_thickness <= mortise_width, "The mortise width cannot be smaller than the mortise thickness!");

    outer_thickness = (mortise_thickness + outer_bit) * 2 - outer_guide_bearing;
    outer_width = (mortise_width + outer_bit) * 2 - outer_guide_bearing;
    outer_radius = corner_radius > 0 ? (min(2 * corner_radius, mortise_thickness) + outer_bit - outer_guide_bearing / 2) : 0;

    inner_thickness = mortise_thickness > inner_bit ? ((mortise_thickness - inner_bit) * 2 + inner_guide_bearing) : inner_guide_bearing;
    inner_width = (mortise_width - inner_bit) * 2 + inner_guide_bearing;
    inner_radius = max(0, min(2 * corner_radius, mortise_thickness) - inner_bit) + inner_guide_bearing / 2 + inner_radius_adjust;
    
    // First M&T
    translate([0, distance, base_height-eps]) difference() {
        tenon_part(height=baseless_height, width=outer_width, thickness=outer_thickness, radius=outer_radius);
        translate([0, 0, -eps])
            mortise_part(height=baseless_height+2*eps, width=inner_width, thickness=inner_thickness, radius=inner_radius);
    }
    // Second M&T
    translate([0, -distance, base_height-eps]) difference() {
        tenon_part(height=baseless_height, width=outer_width, thickness=outer_thickness, radius=outer_radius);
        translate([0, 0, -eps])
            mortise_part(height=baseless_height+2*eps, width=inner_width, thickness=inner_thickness, radius=inner_radius);
    }
    // Base Plate
    difference() {
        base_plate(width=outer_width+taper, thickness=outer_thickness+taper+2*distance, radius=outer_radius+taper/2);
        position_holes(width=outer_width+taper, thickness=2*distance-(outer_thickness+taper), vertical_p=vertical_p) {
            center_hole();
            screw_hole();
        }

        // registration_tabs
        difference() {
            registration_tabs(outer_width+taper, outer_thickness+taper+2*distance, vertical_p=vertical_p);
            position_holes(width=outer_width+taper, thickness=2*distance-(outer_thickness+taper), vertical_p=vertical_p) {
                center_hole_clearance();
                screw_hole_clearance();
            }
        }
    }
}

module mt_template(
    mortise_width,
    mortise_thickness,
    corner_radius,
    inner_guide_bearing,
    outer_guide_bearing,
    inner_bit,
    outer_bit,
    vertical_p=false,
    label_units,
    bottom_label_p,
    registration_tabs_p=true) {
    assert(inner_bit <= mortise_thickness, "The router bit used for the mortise cannot be bigger than the mortise thickness!");
    assert(inner_bit <= mortise_width, "The router bit used for the mortise cannot be bigger than the mortise width!");
    assert(mortise_thickness <= mortise_width, "The mortise width cannot be smaller than the mortise thickness!");

    outer_thickness = (mortise_thickness + outer_bit) * 2 - outer_guide_bearing;
    outer_width = (mortise_width + outer_bit) * 2 - outer_guide_bearing;
    outer_radius = corner_radius > 0 ? (min(2 * corner_radius, mortise_thickness) + outer_bit - outer_guide_bearing / 2) : 0;

    inner_thickness = mortise_thickness > inner_bit ? ((mortise_thickness - inner_bit) * 2 + inner_guide_bearing) : inner_guide_bearing;
    inner_width = (mortise_width - inner_bit) * 2 + inner_guide_bearing;
    inner_radius = max(0, min(2 * corner_radius, mortise_thickness) - inner_bit) + inner_guide_bearing / 2 + inner_radius_adjust;

    text_top = (outer_thickness - taper) / 2;
    text_bottom = inner_thickness / 2;
    text_factor = 0.7;
    text_size = (text_top - text_bottom) * text_factor;
    r = outer_radius > 0 ? 0.5 * outer_thickness * (1 - sin(acos(((text_factor + 0.5 * (1 - text_factor)) * text_top + 0.5 * (1 -text_factor) * text_bottom) / (outer_thickness / 2)))) : 0;
    echo(r);
    text_width = outer_width - 2 * max(r, text_margin) - taper;
    top_label = str(
        top_label_string(value=mortise_width, units=label_units),
        "\u00d7", // Unicode for vertically centered x
        top_label_string(value=mortise_thickness, units=label_units),
        (vertical_p ? "-V" : ""));
    bottom_label = bottom_label_p ? bottom_label_string(inner_guide_bearing, outer_guide_bearing, inner_bit, outer_bit) : "";
    
    difference() {
        tenon_part(height=template_height, width=outer_width, thickness=outer_thickness, radius=outer_radius);
        translate([0, 0, base_height])
            mortise_part(height=template_height-base_height, width=inner_width, thickness=inner_thickness, radius=inner_radius);
        center_marks(width=outer_width, thickness=outer_thickness, vertical_p=vertical_p);
        position_holes(width=inner_width, thickness=inner_thickness, vertical_p=vertical_p) {
            center_hole();
            screw_hole();
        }

        mt_label(label_text=bottom_label, width=text_width, height=text_size, top=-text_bottom, bottom=-text_top);

        // registration_tabs
        difference() {
            registration_tabs(outer_width + taper, outer_thickness + taper, vertical_p=vertical_p);
            position_holes(width=inner_width, thickness=inner_thickness, vertical_p=vertical_p) {
                center_hole_clearance();
                screw_hole_clearance();
            }
        }
    }
    
    mt_label(label_text=top_label, width=text_width, height=text_size, top=text_top, bottom=text_bottom);
 
    if (registration_tabs_p) {
        // Include the registration tabs for printing 
        translate([0, (outer_thickness + taper + (vertical_p ? outer_thickness + taper - 2 * registration_tab_spacer : registration_tab_thickness)) / 2 + registration_tab_spacer, registration_tab_protrusion])
            difference() {
                registration_tabs(outer_width + taper, outer_thickness + taper, vertical_p);
                position_holes(width=inner_width, thickness=inner_thickness, vertical_p=vertical_p) {
                    center_hole_clearance();
                    screw_hole_clearance();
                }
            }
        }
}

module std_mt_template(
    mortise_width,
    vertical_p=false,
    label_units,
    registration_tabs_p=true) {
    
    half_inch = to_millimeters(0.5);
    mt_template(
        mortise_width=mortise_width,
        mortise_thickness=half_inch,
        corner_radius=half_inch/2,
        inner_guide_bearing=10,
        outer_guide_bearing=22,
        inner_bit=half_inch,
        outer_bit=half_inch,
        vertical_p=vertical_p,
        label_units=label_units,
        bottom_label_p=false,
        registration_tabs_p=registration_tabs_p);
}

module dowel_template(
    dowel_diameter,
    inner_guide_bearing,
    outer_guide_bearing,
    inner_bit,
    outer_bit,
    label_units,
    bottom_label_p,
    registration_tabs_p=true) {
    assert(inner_bit <= dowel_diameter, "The router bit used for the round mortise cannot be bigger than the mortise diameter!");

    outer_diameter = (dowel_diameter + outer_bit) * 2 - outer_guide_bearing;
    inner_diameter = circumscribed(
        (dowel_diameter > inner_bit ? ((dowel_diameter - inner_bit) * 2 + inner_guide_bearing) : inner_guide_bearing)
    ) + hole_radius_adjust * 2;
    
    text_top = (outer_diameter - taper) / 2;
    text_bottom = inner_diameter / 2;
    top_label = str( "ø", top_label_string(value=dowel_diameter, units=label_units)); // Unicode \u2300 for diameter symbol does not work
    bottom_label = bottom_label_p ? bottom_label_string(inner_guide_bearing, outer_guide_bearing, inner_bit, outer_bit) : ""; 
    
    difference() {
        cylinder(h=template_height, d1=outer_diameter+taper, d2=outer_diameter-taper, center=false);
        translate([0, 0, base_height])
            cylinder(h=template_height, d=inner_diameter, center=false);

        center_marks(width=outer_diameter, thickness=outer_diameter, vertical_p=false);
        position_holes(width=inner_diameter, thickness=inner_diameter, vertical_p=false) {
            center_hole();
            screw_hole();
        }

        // registration_tabs
        difference() {
            registration_tab(outer_diameter + taper);
            position_holes(width=inner_diameter, thickness=inner_diameter, vertical_p=false) {
                center_hole_clearance();
                screw_hole_clearance();
            }
        }
        
        color("blue")
            dowel_label(label_text=bottom_label, top=-text_bottom, bottom=-text_top);
    }
    color("blue")
        dowel_label(label_text=top_label, top=text_top, bottom=text_bottom);

    if (registration_tabs_p) {
        // Include the registration tabs for printing
        translate([0, (outer_diameter + taper + registration_tab_thickness) / 2 + registration_tab_spacer, registration_tab_protrusion])
            difference() {
                registration_tab(outer_diameter + taper);
                position_holes(width=inner_diameter, thickness=inner_diameter, vertical_p=false) {
                    center_hole_clearance();
                    screw_hole_clearance();
                }
            }
    }
}

module std_dowel_template(registration_tabs_p=true) {
    top_outer_diameter = 27; // measured
    bottom_outer_diameter = 31; // measured
    height = 12; // measured
    // inner diameter fits 10mm guide bearing
    inner_diameter = circumscribed(10) + 2 * hole_radius_adjust;
    
    difference() {
        cylinder(h=height, d1=bottom_outer_diameter, d2=top_outer_diameter, center=false);
        translate([0, 0, base_height])
            cylinder(h=height, d=inner_diameter, center=false);

        center_marks(width=bottom_outer_diameter - taper, thickness=bottom_outer_diameter - taper, vertical_p=false);
        position_holes(width=inner_diameter, thickness=inner_diameter, vertical_p=false) {
            center_hole();
            screw_hole();
        }

        // registration_tabs
        difference() {
            registration_tab(bottom_outer_diameter);
            position_holes(width=inner_diameter, thickness=inner_diameter, vertical_p=false) {
                center_hole_clearance();
                screw_hole_clearance();
            }
        }
    }

    if (registration_tabs_p) {
        // Include the registration tabs for printing
        translate([0, (bottom_outer_diameter + registration_tab_thickness) / 2 + registration_tab_spacer, registration_tab_protrusion])
            difference() {
                registration_tab(bottom_outer_diameter);
                position_holes(width=inner_diameter, thickness=inner_diameter, vertical_p=false) {
                    center_hole_clearance();
                    screw_hole_clearance();
                }
            }
    }
}

module calibration_template1() {
    difference() {
        union() {
            translate([0, 0, template_height / 2]) cube([50, 30, template_height], center = true);
            mt_label(label_text="50mm x 30mm", width=46, top=15, bottom=5);
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
        mt_label(label_text="50mm x 30mm", width=46, top=-5, bottom=-15);
    }
}

/*
// create a cube with recesses for all sizes of the PantoRouter's guide
// bearings.
module calibration_template2() {
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
*/

module calibration_template() {
    difference() {
        union() {
            translate([0, 0, template_height / 2]) cube([50, 30, template_height], center = true);
            mt_label(label_text="50mm x 30mm", width=46, top=15, bottom=5);
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
        mt_label(label_text="50mm x 30mm", width=46, top=-5, bottom=-15);
    }
}

module std_mt_spacer_template(distance) {
    // Notice that "distance" refers to the center-to-center distance
    // between the two mortises; on the PantoRouter templates, that is
    // multiplied by two.
    flange_radius = screw_countersink_diameter;
    spacer_height = template_height / 2;
    intersection() {
        difference() {
            union() {
                hull () {
                    translate([track_spacing, 0, -eps])
                        cylinder(h=base_height+eps, r=flange_radius, center=false);
                    translate([-track_spacing, 0, -eps])
                        cylinder(h=base_height+eps, r=flange_radius, center=false);
                }
                translate([0, 0, spacer_height/2+eps])
                    cube([2*track_spacing-12, (2*distance)-12, spacer_height+2*eps], center=true);
            }
            center_hole();
            translate([track_spacing, 0, 0]) screw_hole();
            translate([-track_spacing, 0, 0]) screw_hole();
            translate([0, -distance, 0])
                std_mt_template(mortise_width=2*track_spacing, vertical_p=true, label_units="f", registration_tabs_p=false);
            translate([0, distance, 0])
                std_mt_template(mortise_width=2*track_spacing, vertical_p=true, label_units="f", registration_tabs_p=false);
        }
        translate([0, 0, spacer_height/2+eps])
            cube([(flange_radius+track_spacing)*2+eps, distance*2, spacer_height], center=true);
    }
}

if (Template == "Dowel") {
    dowel_template(
        dowel_diameter=to_millimeters(Dowel_Diameter),
        inner_guide_bearing=Inner_Guide_Bearing,
        outer_guide_bearing=Outer_Guide_Bearing,
        inner_bit=to_millimeters(Inner_Bit),
        outer_bit=to_millimeters(Outer_Bit),
        label_units=Label_Units,
        bottom_label_p=Bottom_Label);
} else if(Template == "M&T") {
    mt_template(
        mortise_width=to_millimeters(Mortise_Width),
        mortise_thickness=to_millimeters(Mortise_Thickness),
        corner_radius=to_millimeters(Corner_Radius),
        inner_guide_bearing=Inner_Guide_Bearing,
        outer_guide_bearing=Outer_Guide_Bearing,
        inner_bit=to_millimeters(Inner_Bit),
        outer_bit=to_millimeters(Outer_Bit),
        vertical_p=(Orientation == "V" ? true : false),
        label_units=Label_Units,
        bottom_label_p=Bottom_Label);
} else if(Template == "Double M&T") {
    double_mt_template(
        distance=to_millimeters(Mortises_Spacing),
        mortise_width=to_millimeters(Mortise_Width),
        mortise_thickness=to_millimeters(Mortise_Thickness),
        corner_radius=to_millimeters(Corner_Radius),
        inner_guide_bearing=Inner_Guide_Bearing,
        outer_guide_bearing=Outer_Guide_Bearing,
        inner_bit=to_millimeters(Inner_Bit),
        outer_bit=to_millimeters(Outer_Bit),
        vertical_p=(Orientation == "V" ? true : false),
        label_units=Label_Units,
        bottom_label_p=Bottom_Label);        
} else if (Template == "Std Dowel") {
    std_dowel_template();
} else if (Template == "Std M&T") {
    std_mt_template(
        mortise_width=to_millimeters(Mortise_Width),
        vertical_p=(Orientation == "V" ? true : false),
        label_units=Label_Units,
    );
} else if (Template == "Std M&T Spacer") {
    std_mt_spacer_template(distance=to_millimeters(Mortises_Spacing));
} else if (Template == "Centering Pin") {
    centering_pin();
} else {
    calibration_template();
}
