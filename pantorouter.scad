// PantoRouter template generator

// This code follows the naming conventions used in the PantoRouter
// How-To Guide.
// Mortises and tenons are defined by the width, thickness, and depth/length.
// Width and h_* or horizontal refer to the x axis.
// Thickness and v_* or vertical refer to the y axis.
// Height and depth refer to the z axis.

// TODO:
// - add registration tabs for horizontal and vertical versions
// - adjust for printer slop
// - haunched mortise and tenon

use <math.scad>
use <BOSL/math.scad>
use <BOSL/shapes.scad>
include <BOSL/constants.scad>


// Customizable parameters

Template = "M&T"; // ["Dowel", "M&T", "Calibration"]

Inner_Bit = 0.375; // [0.125:"1/8\"", 0.1875:"3/16\"", 0.25:"1/4\"", 0.3125:"5/16\"", 0.375:"3/8\"", 0.5:"1/2\"", 0.75:"3/4\"", 1:"1\""]
Outer_Bit = 0.5; // [0.125:"1/8\"", 0.1875:"3/16\"", 0.25:"1/4\"", 0.3125:"5/16\"", 0.375:"3/8\"", 0.5:"1/2\"", 0.75:"3/4\"", 1:"1\""]
Inner_Guide_Bearing = 10;   // [6:6 mm, 10:10 mm, 12:12 mm, 15:15 mm, 22:22 mm, 35:35 mm, 48:48 mm]
Outer_Guide_Bearing = 15;   // [6:6 mm, 10:10 mm, 12:12 mm, 15:15 mm, 22:22 mm, 35:35 mm, 48:48 mm]
Label_Units = "f";  // [d:Decimal Inches, f:Fractional Inches, m:Millimeters]

/* [ Mortise And Tenon Template ] */

Orientation = "H"; // [H:Horizontal, V:Vertical]
// in inches
Mortise_Width = 2.5; // [0.25:0.125:4]
// in inches
Mortise_Thickness = 0.5; // [0.125:0.125:2]
// in inches
Corner_Radius = 0;   // [0:0.0625:1]

/* [ Dowel Template ] */

// in inches
Dowel_Diameter = 1; // [0.25:0.125:4]

/* [Hidden] */

$fa = 1;
$fs = 0.4;
hole_fn = 64;

template_height = 12;
bottom_height = 3.5;
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
nut_clearance = 8.5;
track_spacing = 20;
registration_tab_thickness = 4.2;
registration_tab_protrusion = 1.3;
base_margin = 2;
center_mark_height = 3;
center_mark_depth = 0.5;

eps = 0.01;

module tenon_part(width, thickness, radius) {
    dx = width / 2 - radius;
    dy = thickness / 2 - radius;
    echo(dy, thickness, radius);
    d_r = taper / 2;

    if (radius > eps) {
        // rounded ends
        hull() {
            translate([dx, dy, 0])
                cylinder(h=template_height, r1=radius+d_r, r2=radius-d_r, center=false);
            if (dx > 0) {
                translate([-dx, dy, 0])
                    cylinder(h=template_height, r1=radius+d_r, r2=radius-d_r, center=false);
            }
            if (dy > 0) {
                translate([dx, -dy, 0])
                    cylinder(h=template_height, r1=radius+d_r, r2=radius-d_r, center=false);
                if (dx > 0) {
                    translate([-dx, -dy, 0])
                        cylinder(h=template_height, r1=radius+d_r, r2=radius-d_r, center=false);
                }
            }
        }
    } else {
        // square ends
        // The intersection is used to remove the bottom part of the hull
        // because that is not tapered
        intersection() {
            hull() {
                translate([0, 0, template_height - eps / 2])
                    cube([width-taper, thickness-taper, eps], center=true);
                translate([0, 0, -eps / 2])
                    cube([width+taper, thickness+taper, eps], center=true);                    
            }
            translate([0, 0, template_height])
                cube([2 * width, 2 * thickness, 2 * template_height], center=true);
        }
    }
}

module mortise_part(width, thickness, radius) {
    depth = template_height - bottom_height;
    step_depth = depth / n_mortise_steps;
    offset = width / 2 - radius;
    dy = thickness / 2 - radius;
    union() {
        for (i=[0:1:n_mortise_steps-1]) {
            hull() {
                dx=offset + mortise_step_width * i;
                dz=bottom_height + step_depth * i;
                translate([-dx, dy, dz])
                    cylinder(h=template_height, r=radius, center=false);
                translate([dx, dy, dz])
                    cylinder(h=template_height, r=radius, center=false);
                if (dy > eps) {
                    translate([-dx, -dy, dz])
                        cylinder(h=template_height, r=radius, center=false);
                    translate([dx, -dy, dz])
                        cylinder(h=template_height, r=radius, center=false);
                }
            }
        }
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
    radius = circumscribed(center_hole_diameter / 2);
    cylinder(h=template_height*2, r=radius, center=true);
}

module screw_hole() {
    countersink_radius = screw_countersink_diameter / 2;
    countersink_height =
        countersink_radius / tan(screw_countersink_angle / 2);
    screw_hole_radius = circumscribed(screw_hole_diameter / 2);
    union() {
        cylinder(h=template_height*2, r=screw_hole_radius, center=true);
        translate([0, 0, bottom_height - countersink_height + eps])
            cylinder(countersink_height, r1=0, r2=countersink_radius, center=false);
    }
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

module holes(width, thickness, vertical_p) {
    assert(thickness >= screw_countersink_diameter);
    assert(width >= screw_countersink_diameter);
    positions = holes_layout(width=width, thickness=thickness, vertical_p=vertical_p);
    screw_position = positions[0];
    center_hole_position = positions[1];
    if (screw_position <= eps) {
        // There is only enough space for one screw in the center
        screw_hole();
    } else {
        union() {
            translate([-screw_position, 0, 0]) screw_hole();
            translate([screw_position, 0, 0]) screw_hole();
            if (center_hole_position == 0) {
                center_hole();
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

module registration_tab(length=10) {
    width = registration_tab_thickness;
    intrusion = width / 2;  // to make sure the printing does not overhang more than 45°
    extrusion = registration_tab_protrusion;

    /*
    offset = (length - width) / 2;
    hull() {
        translate([offset, 0, 0]) cylinder(h=extrusion-eps, d1=width, d2=0, center=false);
        translate([-offset, 0, 0]) cylinder(h=extrusion-eps, d1=width, d2=0, center=false);
        translate([-offset, 0, -extrusion]) cylinder(h=extrusion-eps, d=width, center=false);
        translate([offset, 0, -extrusion]) cylinder(h=extrusion-eps, d=width, center=false);
    }
    */
    rotate([0, 0, 90]) translate([0, 0, -extrusion])
        narrowing_strut(w=width, l=length, wall=extrusion, ang=45);
}

module v_registration_tabs(length) {
    rotate([0, 0, 90]) {
        translate([-10, track_spacing, 0])
            registration_tab(10);
        translate([10, track_spacing, 0])
            registration_tab(10);
        translate([-10, -track_spacing, 0])
            registration_tab(10);
        translate([10, -track_spacing, 0])
            registration_tab(10);
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
        mortise_s = str("M:", inner_bit_s, ",", inner_guide_bearing_s),
        tenon_s = str("T:", outer_bit_s, ",", outer_guide_bearing_s)
    )
        str(mortise_s, " ", tenon_s);
    
module mt_label(label_text, width, top, bottom) {
    if (len(label_text) > 0) {
        text_size = (top - bottom) * 0.7;
        dy = (top + bottom) / 2;
        tm = textmetrics(size=text_size, halign="center", valign="center", text=label_text);
        too_big_p = tm.size.x / tm.size.y > width / text_size;
        /* WARNING: use the following snippet if you do not want to use
           the experimental textmetrics() function.
        // The average ratio of height to width of characters is 6:5
        too_big_p = len(label_text) > (width / text_size) * 5 / 5.75;
        */
        color("blue") translate([0, dy, template_height]) {
            linear_extrude(height=1.2, center=true) {
                if (too_big_p) {
                    resize([width, 0, 0], auto=[true, true, false])
                        text(size=text_size, halign="center", valign="center", text=label_text);
                } else {
                    text(size=text_size, halign="center", valign="center", text=label_text);
                }
            }
        }
    }
}

module dowel_label(label_text, top, bottom) {
    n_chars = len(label_text);
    if (n_chars > 0) {
        text_size = (top - bottom) * 0.7;
        radius = bottom + (top - bottom - text_size) / 2;
        widths = [for (c = label_text) textmetrics(size=text_size, halign="left", valign="baseline", text=c).advance.x];
        total_width = sum(widths);
        total_a = 180 * total_width / (PI * radius);
        start_a = total_a / 2;
        da = total_a / total_width;
        start_as = [for (a = start_a, i = 0; i < len(widths); a = a - da * widths[i], i = i + 1) a];
        color("blue")
        for(i = [0 : n_chars - 1]) {
            rotate([0, 0, start_as[i]])
                translate([0, radius, template_height]) {
                    linear_extrude(height=1.2, center=true) {
                        text(size=text_size, halign="left", valign="baseline", text=label_text[i]);
                    }
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
    label_units) {
    assert(inner_bit <= mortise_thickness, "The router bit used for the mortise cannot be bigger than the mortise thickness!");
    assert(inner_bit <= mortise_width, "The router bit used for the mortise cannot be bigger than the mortise width!");
    assert(mortise_thickness <= mortise_width, "The mortise width cannot be smaller than the mortise thickness!");

    outer_thickness = (mortise_thickness + outer_bit) * 2 - outer_guide_bearing;
    outer_width = (mortise_width + outer_bit) * 2 - outer_guide_bearing;
    outer_radius = corner_radius > 0 ? (min(2 * corner_radius, mortise_thickness) + outer_bit - outer_guide_bearing / 2) : 0;

    inner_thickness = mortise_thickness > inner_bit ? ((mortise_thickness - inner_bit) * 2 + inner_guide_bearing) : inner_guide_bearing;
    inner_width = (mortise_width - inner_bit) * 2 + inner_guide_bearing;
    inner_radius = max(0, min(2 * corner_radius, mortise_thickness) - inner_bit) + inner_guide_bearing / 2;
    
    difference() {
        tenon_part(width=outer_width, thickness=outer_thickness, radius=outer_radius);
        mortise_part(width=inner_width, thickness=inner_thickness, radius=inner_radius);
        center_marks(width=outer_width, thickness=outer_thickness, vertical_p=vertical_p);
        holes(width=inner_width, thickness=inner_thickness, vertical_p=vertical_p);

        // registration_tabs
        if (vertical_p) {
            v_registration_tabs(10);
        } else {
            translate([-track_spacing, 0, 0]) registration_tab();
            translate([track_spacing, 0, 0]) registration_tab();
        }
    }
    text_width = outer_width - 2 * max(outer_radius, base_margin) - taper;
    text_top = (outer_thickness - taper) / 2;
    text_bottom = inner_thickness / 2;
    
    top_label = str(
        top_label_string(value=mortise_width, units=label_units),
        " x ",
        top_label_string(value=mortise_thickness, units=label_units));
    mt_label(label_text=top_label, width=text_width, top=text_top, bottom=text_bottom);

    bottom_label = bottom_label_string(inner_guide_bearing, outer_guide_bearing, inner_bit, outer_bit);
    mt_label(label_text=bottom_label, width=text_width, top=-text_bottom, bottom=-text_top);
}

module dowel_template(
    dowel_diameter,
    inner_guide_bearing,
    outer_guide_bearing,
    inner_bit,
    outer_bit,
    label_units) {
    assert(inner_bit <= dowel_diameter, "The router bit used for the round mortise cannot be bigger than the mortise diameter!");

    outer_diameter = (dowel_diameter + outer_bit) * 2 - outer_guide_bearing;
    inner_diameter = dowel_diameter > inner_bit ? ((dowel_diameter - inner_bit) * 2 + inner_guide_bearing) : inner_guide_bearing;
    
    tab_width = (outer_diameter - nut_clearance) / 2 - base_margin;
    tab_position = ((outer_diameter / 2 - base_margin) + nut_clearance / 2) / 2;
    difference() {
        cylinder(h=template_height, d1=outer_diameter+taper, d2=outer_diameter-taper, center=false);
        translate([0, 0, bottom_height])
            cylinder(h=template_height, d=inner_diameter, center=false);

        center_marks(width=outer_diameter, thickness=outer_diameter, vertical_p=false);
        screw_hole();
        translate([tab_position, 0, 0]) registration_tab(length=tab_width);
        translate([-tab_position, 0, 0]) registration_tab(length=tab_width);
    }

    text_top = (outer_diameter - taper) / 2;
    text_bottom = inner_diameter / 2;
    top_label = str( "ø ", top_label_string(value=dowel_diameter, units=label_units)); // Unicode \u2300 for diameter symbol does not work
    dowel_label(label_text=top_label, top=text_top, bottom=text_bottom);
    bottom_label = bottom_label_string(inner_guide_bearing, outer_guide_bearing, inner_bit, outer_bit);    
    dowel_label(label_text=bottom_label, top=-text_bottom, bottom=-text_top);
    
    // Include the registration tabs for printing
    translate([0, outer_diameter / 2 + 10, registration_tab_protrusion]) {
        translate([tab_position, 0, 0]) registration_tab(length=tab_width);
        translate([-tab_position, 0, 0]) registration_tab(length=tab_width);
    }
}

module calibration_template1() {
    difference() {
        union() {
            translate([0, 0, template_height / 2]) cube([50, 30, template_height], center = true);
            mt_label(label_text="50mm x 30mm", width=46, top=15, bottom=5);
        }
        translate([0, 0, template_height / 2 + bottom_height]) hull() {
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
        translate([0, 0, template_height / 2 + bottom_height]) hull() {
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

if (Template == "Dowel") {
    dowel_template(
        dowel_diameter=to_millimeters(Dowel_Diameter),
        inner_guide_bearing=Inner_Guide_Bearing,
        outer_guide_bearing=Outer_Guide_Bearing,
        inner_bit=to_millimeters(Inner_Bit),
        outer_bit=to_millimeters(Outer_Bit),
        label_units=Label_Units);
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
        label_units=Label_Units);
} else {
    calibration_template();
}
