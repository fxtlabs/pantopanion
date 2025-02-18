// PantoRouter template generator

// This code follows the naming conventions used in the PantoRouter
// How-To Guide.
// Mortises and tenons are defined by the width, thickness, and depth/length.
// Width and h_* or horizontal refer to the x axis.
// Thickness and v_* or vertical refer to the y axis.
// Height and depth refer to the z axis.

// TODO:
// - Bring layout logic into position_holes()
// - The standard dowel template could have a tiny bit of taper in the
//   mortise slot
// - Create a parametric spacer to enable proper spacing and centering
//   of double M&Ts (vertical orientation)

use <math.scad>
include <constants.scad>
use <BOSL/math.scad>
use <BOSL/shapes.scad>
include <BOSL/constants.scad>


/* [Hidden] */

$fa = 1;
$fs = 0.4;


//////////////////////////
// Template Components
//////////////////////////


module center_hole() {
    radius = circumscribed(center_hole_diameter / 2) + hole_radius_adjust;
    cylinder(h=template_height*2, r=radius, center=true);
}


module center_hole_clearance() {
    side = center_hole_diameter + 2 * registration_tab_spacer;
    cube([side, side, 2*template_height], center=true);
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


// This center mark will work well on tapered templates, but not so well
// on templates that use a base plate.
module center_mark() {
    size = 2 * center_mark_height;
    rotate([0, 0, 45]) cube(size, center=true);
}


module center_marks(width, thickness, vertical_p) {
    if (vertical_p) {
        center_mark_x = width / 2 + center_mark_height * sqrt(2) - center_mark_depth;
        translate([-center_mark_x, 0, 0]) center_mark();
        translate([center_mark_x, 0, 0]) center_mark();
    } else {
        center_mark_y = thickness / 2 + center_mark_height * sqrt(2) - center_mark_depth;
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


function settings_text(inner_guide_bearing, outer_guide_bearing, inner_bit, outer_bit) =
    let (
        inner_bit_s = as_fractional_inches(to_inches(inner_bit)),
        outer_bit_s = as_fractional_inches(to_inches(outer_bit)),
        /* Unfortunately, there isn't enough space to properly label
           the guide bearing diameter with the "mm" unit without
           hurting readability. At least not with a 0.4 mm print nozzle.
        inner_guide_bearing_s = as_millimeters(inner_guide_bearing),
        outer_guide_bearing_s = as_millimeters(outer_guide_bearing),
        */
        mortise_s = str("M", inner_bit_s, "•", inner_guide_bearing),
        tenon_s = str("T", outer_bit_s, "•", outer_guide_bearing)
    )
        str(mortise_s, " ", tenon_s);


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


// Operator module.
module complete_template(outer_width, outer_thickness, inner_width, inner_thickness, vertical_p, registration_tabs_p) {
    difference() {
        children(0);
        position_holes(width=inner_width+taper, thickness=inner_thickness, vertical_p=vertical_p) {
            center_hole();
            screw_hole();
        }

        // registration_tabs
        difference() {
            registration_tabs(outer_width, outer_thickness, vertical_p=vertical_p);
            position_holes(width=inner_width, thickness=inner_thickness, vertical_p=vertical_p) {
                center_hole_clearance();
                screw_hole_clearance();
            }
        }
    }

    if (registration_tabs_p) {
        // Include the registration tabs for printing 
        translate([0, (outer_thickness + (vertical_p ? outer_thickness - 2 * registration_tab_spacer : registration_tab_thickness)) / 2 + registration_tab_spacer, registration_tab_protrusion])
            difference() {
                registration_tabs(outer_width, outer_thickness, vertical_p);
                position_holes(width=inner_width, thickness=inner_thickness, vertical_p=vertical_p) {
                    center_hole_clearance();
                    screw_hole_clearance();
                }
            }
    }    
}


module label_part(label_text, bounds) {
    if (len(label_text) > 0) {
        text_size = text_size_factor * bounds.y;
        tm = textmetrics(size=text_size, halign="center", valign="center", text=label_text);
        too_big_p = tm.size.x > bounds.x;
        linear_extrude(height=label_height*2, center=true) {
            if (too_big_p) {
                resize([bounds.x, 0, 0], auto=[true, true, false])
                    text(size=text_size, halign="center", valign="center", text=label_text);
            } else {
                text(size=text_size, halign="center", valign="center", font=":style=Bold", text=label_text);
            }
        }
    }
}


//////////////////////////
// M&T Templates
//////////////////////////


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


function mt_size_text(mortise_width, mortise_thickness, vertical_p, label_units) =
    str(
        as_value_with_units(mortise_width, label_units),
        "\u00d7", // Unicode for vertically centered x
        as_value_with_units(mortise_thickness, label_units),
        (vertical_p ? "-V" : "")
    );


function mt_label_bounds(outer_width, outer_thickness, outer_radius, inner_thickness) =
    let (
        max_size = ((outer_thickness - taper) - inner_thickness) / 2,
        text_top = (outer_thickness - taper) / 2,
        text_bottom = inner_thickness / 2,
        r = outer_radius > 0 ? 0.5 * outer_thickness * (1 - sin(acos(((text_size_factor + 0.5 * (1 - text_size_factor)) * text_top + 0.5 * (1 -text_size_factor) * text_bottom) / (outer_thickness / 2)))) : 0,
        max_width = outer_width - 2 * max(r, text_margin) - taper
    ) [max_width, max_size];


function mt_template_dimensions(
    mortise_width,
    mortise_thickness,
    corner_radius,
    inner_guide_bearing,
    outer_guide_bearing,
    inner_bit,
    outer_bit) =
    let (
        outer_thickness = (mortise_thickness + outer_bit) * 2 - outer_guide_bearing,
        outer_width = (mortise_width + outer_bit) * 2 - outer_guide_bearing,
        outer_radius = corner_radius > 0 ? (min(2 * corner_radius, mortise_thickness) + outer_bit - outer_guide_bearing / 2) : 0,
        inner_thickness = mortise_thickness > inner_bit ? ((mortise_thickness - inner_bit) * 2 + inner_guide_bearing) : inner_guide_bearing,
        inner_width = (mortise_width - inner_bit) * 2 + inner_guide_bearing,
        inner_radius = max(0, min(2 * corner_radius, mortise_thickness) - inner_bit) + inner_guide_bearing / 2 + inner_radius_adjust
    ) [outer_width, outer_thickness, outer_radius, inner_width, inner_thickness, inner_radius];


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
    top_label_text=undef,
    bottom_label_text=undef,
    registration_tabs_p=true) {
    assert(inner_bit <= mortise_thickness, "The router bit used for the mortise cannot be bigger than the mortise thickness!");
    assert(inner_bit <= mortise_width, "The router bit used for the mortise cannot be bigger than the mortise width!");
    assert(mortise_thickness <= mortise_width, "The mortise width cannot be smaller than the mortise thickness!");

    // I wish OpenSCAD supported objects :-(
    dimensions = mt_template_dimensions(mortise_width, mortise_thickness, corner_radius, inner_guide_bearing, outer_guide_bearing, inner_bit, outer_bit);
    outer_width = dimensions[0];
    outer_thickness = dimensions[1];
    outer_radius = dimensions[2];
    inner_width = dimensions[3];
    inner_thickness = dimensions[4];
    inner_radius = dimensions[5];

    label_bounds = mt_label_bounds(
        outer_width=outer_width,
        outer_thickness=outer_thickness,
        outer_radius=outer_radius,
        inner_thickness=inner_thickness);
    top_label_t = top_label_text == undef ? mt_size_text(mortise_width, mortise_thickness, vertical_p, label_units) : top_label_text;
    bottom_label_t = bottom_label_text == undef ? settings_text(inner_guide_bearing, outer_guide_bearing, inner_bit, outer_bit) : bottom_label_text;

    complete_template(
        outer_width=outer_width + taper,
        outer_thickness=outer_thickness + taper,
        inner_width=inner_width,
        inner_thickness=inner_thickness,
        vertical_p=vertical_p,
        registration_tabs_p=registration_tabs_p
    ) {
        union() {
            difference() {
                tenon_part(height=template_height, width=outer_width, thickness=outer_thickness, radius=outer_radius);
                translate([0, 0, base_height])
                    mortise_part(height=template_height-base_height, width=inner_width, thickness=inner_thickness, radius=inner_radius);
                center_marks(width=outer_width+taper, thickness=outer_thickness+taper, vertical_p=vertical_p);
            }
            if (len(top_label_t) > 0) {
                translate([0, (outer_thickness-taper+inner_thickness)/4, template_height])
                    label_part(top_label_t, label_bounds);
            }
            if (len(bottom_label_t) > 0) {
                translate([0, -(outer_thickness-taper+inner_thickness)/4, template_height])
                    label_part(bottom_label_t, label_bounds);
            }
        }
    }
}


module std_mt_template(
    mortise_width,
    vertical_p=false,
    label_units,
    top_label_text=undef,
    bottom_label_text="",
    registration_tabs_p=true) {
    
    mt_template(
        mortise_width=mortise_width,
        mortise_thickness=std_inner_bit,
        corner_radius=std_inner_bit/2,
        inner_guide_bearing=std_inner_guide_bearing,
        outer_guide_bearing=std_outer_guide_bearing,
        inner_bit=std_inner_bit,
        outer_bit=std_outer_bit,
        vertical_p=vertical_p,
        label_units=label_units,
        top_label_text=top_label_text,
        bottom_label_text=bottom_label_text,
        registration_tabs_p=registration_tabs_p);
}


module baseless_mt_template(
    mortise_width,
    mortise_thickness,
    corner_radius,
    inner_guide_bearing,
    outer_guide_bearing,
    inner_bit,
    outer_bit,
    top_label_text=undef,
    bottom_label_text=undef) {
    assert(inner_bit <= mortise_thickness, "The router bit used for the mortise cannot be bigger than the mortise thickness!");
    assert(inner_bit <= mortise_width, "The router bit used for the mortise cannot be bigger than the mortise width!");
    assert(mortise_thickness <= mortise_width, "The mortise width cannot be smaller than the mortise thickness!");

    // I wish OpenSCAD supported objects :-(
    dimensions = mt_template_dimensions(mortise_width, mortise_thickness, corner_radius, inner_guide_bearing, outer_guide_bearing, inner_bit, outer_bit);
    outer_width = dimensions[0];
    outer_thickness = dimensions[1];
    outer_radius = dimensions[2];
    inner_width = dimensions[3];
    inner_thickness = dimensions[4];
    inner_radius = dimensions[5];

    label_bounds = mt_label_bounds(
        outer_width=outer_width,
        outer_thickness=outer_thickness,
        outer_radius=outer_radius,
        inner_thickness=inner_thickness);
    top_label_t = top_label_text == undef ? mt_size_text(mortise_width, mortise_thickness, vertical_p, label_units) : top_label_text;
    bottom_label_t = bottom_label_text == undef ? settings_text(inner_guide_bearing, outer_guide_bearing, inner_bit, outer_bit) : bottom_label_text;

    union() {
        difference() {
            tenon_part(height=baseless_height, width=outer_width, thickness=outer_thickness, radius=outer_radius);
            translate([0, 0, -eps])
                mortise_part(height=baseless_height+2*eps, width=inner_width, thickness=inner_thickness, radius=inner_radius);
        }
        if (len(top_label_t) > 0) {
            translate([0, (outer_thickness-taper+inner_thickness)/4, baseless_height])
                label_part(top_label_t, label_bounds);
        }
        if (len(bottom_label_t) > 0) {
            translate([0, -(outer_thickness-taper+inner_thickness)/4, baseless_height])
                label_part(bottom_label_t, label_bounds);
        }
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
    extra_label_text=undef,
    registration_tabs_p=true) {
    assert(inner_bit <= mortise_thickness, "The router bit used for the mortise cannot be bigger than the mortise thickness!");
    assert(inner_bit <= mortise_width, "The router bit used for the mortise cannot be bigger than the mortise width!");
    assert(mortise_thickness <= mortise_width, "The mortise width cannot be smaller than the mortise thickness!");

    // I wish OpenSCAD supported objects :-(
    dimensions = mt_template_dimensions(mortise_width, mortise_thickness, corner_radius, inner_guide_bearing, outer_guide_bearing, inner_bit, outer_bit);
    outer_width = dimensions[0];
    outer_thickness = dimensions[1];
    outer_radius = dimensions[2];
    inner_width = dimensions[3];
    inner_thickness = dimensions[4];
    inner_radius = dimensions[5];

    mt_size_label_text = mt_size_text(mortise_width, mortise_thickness, vertical_p, label_units);
    settings_label_text = settings_text(inner_guide_bearing, outer_guide_bearing, inner_bit, outer_bit);
    distance_label_text = str(">", as_value_with_units(distance, label_units), "<");
    custom_label_text = extra_label_text == undef ? "" : extra_label_text;
    
    complete_template(
        outer_width=outer_width+taper,
        outer_thickness=outer_thickness+taper+2*distance,
        inner_width=outer_width+taper,
        inner_thickness=2*distance-(outer_thickness+taper),
        vertical_p=vertical_p,
        registration_tabs_p=registration_tabs_p
    ) union() {
        // First M&T
        translate([0, distance, base_height-eps])
            baseless_mt_template(
                mortise_width=mortise_width,
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
        translate([0, -distance, base_height-eps])
            baseless_mt_template(
                mortise_width=mortise_width,
                mortise_thickness=mortise_thickness,
                corner_radius=corner_radius,
                inner_guide_bearing=inner_guide_bearing,
                outer_guide_bearing=outer_guide_bearing,
                inner_bit=inner_bit,
                outer_bit=outer_bit,
                top_label_text=distance_label_text,
                bottom_label_text=custom_label_text
            );
        // Base Plate
        base_plate(width=outer_width+taper, thickness=outer_thickness+taper+2*distance, radius=outer_radius > eps ? outer_radius+taper/2 : 0);
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
                std_mt_template(mortise_width=2*track_spacing, vertical_p=true, label_units=UNIT_OF_FRACTIONAL_INCHES, registration_tabs_p=false);
            translate([0, distance, 0])
                std_mt_template(mortise_width=2*track_spacing, vertical_p=true, label_units=UNIT_OF_FRACTIONAL_INCHES, registration_tabs_p=false);
        }
        translate([0, 0, spacer_height/2+eps])
            cube([(flange_radius+track_spacing)*2+eps, distance*2, spacer_height], center=true);
    }
}


//////////////////////////
// Dowel Templates
//////////////////////////


function dowel_size_text(diameter, units) =
    str( "ø", as_value_with_units(diameter, units)); // Unicode \u2300 for diameter symbol does not work


module dowel_label(label_text, top, bottom) {
    n_chars = len(label_text);
    if (n_chars > 0) {
        opt_text_size = (top - bottom) * text_size_factor;
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


module dowel_template(
    dowel_diameter,
    inner_guide_bearing,
    outer_guide_bearing,
    inner_bit,
    outer_bit,
    label_units,
    top_label_text=undef,
    bottom_label_text=undef,
    registration_tabs_p=true) {
    assert(inner_bit <= dowel_diameter, "The router bit used for the round mortise cannot be bigger than the mortise diameter!");

    outer_diameter = (dowel_diameter + outer_bit) * 2 - outer_guide_bearing;
    inner_diameter = circumscribed(
        (dowel_diameter > inner_bit ? ((dowel_diameter - inner_bit) * 2 + inner_guide_bearing) : inner_guide_bearing)
    ) + hole_radius_adjust * 2;
    
    text_top = (outer_diameter - taper) / 2;
    text_bottom = inner_diameter / 2;
    top_label_t = top_label_text == undef ? dowel_size_text(dowel_diameter, label_units) : top_label_text;
    bottom_label_t = bottom_label_text == undef ? settings_text(inner_guide_bearing, outer_guide_bearing, inner_bit, outer_bit) : bottom_label_text; 
    
    complete_template(
        outer_width=outer_diameter+taper,
        outer_thickness=outer_diameter+taper,
        inner_width=inner_diameter,
        inner_thickness=inner_diameter,
        vertical_p=false,
        registration_tabs_p=registration_tabs_p
    ) {
        union() {
            difference() {
                cylinder(h=template_height, d1=outer_diameter+taper, d2=outer_diameter-taper, center=false);
                translate([0, 0, base_height])
                    cylinder(h=template_height, d=inner_diameter, center=false);

                center_marks(width=outer_diameter+taper, thickness=outer_diameter+taper, vertical_p=false);
            }
            if (len(top_label_t) > 0) {
                dowel_label(label_text=top_label_t, top=text_top, bottom=text_bottom);
            }
            if (len(bottom_label_t) > 0) {
                dowel_label(label_text=bottom_label_t, top=-text_bottom, bottom=-text_top);
            }
        }
    }
}


module std_dowel_template(registration_tabs_p=true) {
    top_outer_diameter = 27; // measured
    bottom_outer_diameter = 31; // measured
    height = 12; // measured
    // inner diameter fits 10mm guide bearing
    inner_diameter = 2 * (circumscribed(std_inner_guide_bearing / 2) + hole_radius_adjust);
    
    complete_template(
        outer_width=bottom_outer_diameter,
        outer_thickness=bottom_outer_diameter,
        inner_width=inner_diameter,
        inner_thickness=inner_diameter,
        vertical_p=false,
        registration_tabs_p=registration_tabs_p
    ) {
        difference() {
            cylinder(h=height, d1=bottom_outer_diameter, d2=top_outer_diameter, center=false);
            translate([0, 0, base_height])
                cylinder(h=height, d=inner_diameter, center=false);

            center_marks(width=bottom_outer_diameter, thickness=bottom_outer_diameter, vertical_p=false);
        }
    }
}

