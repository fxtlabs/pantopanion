use <math.scad>
use <pantorouter.scad>
use <accessories.scad>
use <calibration.scad>

// Customizable parameters

Template = "M&T"; // ["Dowel", "M&T", "Std Dowel", "Std M&T", "Double M&T", "Std M&T Spacer", "Centering Pin", "Calibration"]

Inner_Bit = 0.375; // [0.125:"1/8\"", 0.1875:"3/16\"", 0.25:"1/4\"", 0.3125:"5/16\"", 0.375:"3/8\"", 0.5:"1/2\"", 0.75:"3/4\"", 1:"1\""]
Outer_Bit = 0.5; // [0.125:"1/8\"", 0.1875:"3/16\"", 0.25:"1/4\"", 0.3125:"5/16\"", 0.375:"3/8\"", 0.5:"1/2\"", 0.75:"3/4\"", 1:"1\""]
Inner_Guide_Bearing = 10;   // [6:6 mm, 10:10 mm, 12:12 mm, 15:15 mm, 22:22 mm, 35:35 mm, 48:48 mm]
Outer_Guide_Bearing = 15;   // [6:6 mm, 10:10 mm, 12:12 mm, 15:15 mm, 22:22 mm, 35:35 mm, 48:48 mm]
Label_Units = "f";  // [d:Decimal Inches, f:Fractional Inches, m:Millimeters]
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
        label_units=Label_Units);
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
    calibration_piece();
}
