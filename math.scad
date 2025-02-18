// Math functions

use <BOSL/math.scad>
include <constants.scad>


/* [Hidden] */

// Given the radius of a circle (or cylinder), return a new radius that would
// yield a polygonal approximation that circumscribes the original circle.
// Use it for subtracted shapes so that the resulting hole is as big as
// requested.
// References:
// https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/undersized_circular_objects
function circumscribed(radius) =
    let (n = segs(radius)) radius / cos(180 / n);


// greatest common divisor
function gcd(a, b) =
    b == 0 ? a : gcd(b, a % b);


// Given a value as a Number, it returns a mixed number consisting of a
// whole number and a proper fraction as [whole, [numerator, denominator]],
// rounded to the nearest 1/max_denominator.
// Use it with non-negative values and powers of two for the denominator.
// It is meant for dyadic rationals.
// References:
// https://stackoverflow.com/questions/38891250/convert-to-fraction-inches
function to_mixed_number(value, max_denominator=64) =
    let (
        denominator = max_denominator,
        whole = floor(value),
        numerator = floor((value - whole) * denominator + 0.5),
        factor = gcd(numerator, denominator)
    )
        [whole, (factor > 0 ? [numerator / factor, denominator / factor] : [0, 1] )];


// Given a fraction in the form [numerator, denominator], it returns its
// value as a native Number (or undef if the denominator == 0.
function from_fraction(value) =
    value[1] != undef ? value[0] / value[1] : undef;


// Given a mixed number in the form [whole_number, [numerator, denominator]],
// it returns its value as a native Number.
function from_mixed_number(value) =
    value[0] + (value[1] != undef ? from_fraction(value[1]) : 0);


// It converts a value from millimeters to inches.
function to_inches(value) =
    value / INCH_TO_MM;


// It converts a value from inches to millimeters.
function to_millimeters(value) =
    value * INCH_TO_MM;


// Given a value in millimeters, it returns it as a printable string.
// (E.g. 1.75 => "1.75mm")
function as_millimeters(value) =
    str(value, "mm");


// Given a value in inches, it returns a string formatted as decimal inches.
// (E.g. 1.75 => "1.75\"")
function as_decimal_inches(value) =
    str(value, "\"");


// Given a value in inches, it returns a string formatted as fractional inches.
// (E.g. 1.75 => "1-3/4\"")
function as_fractional_inches(value) =
    let (
        mn = to_mixed_number(value),
        whole = mn[0],
        nominator = mn[1][0],
        denominator = mn[1][1],
        separator = whole > 0 && nominator > 0 ? "-" : ""
    )
        str((whole > 0 ? whole : ""),
            separator,
            (nominator > 0 ? str(nominator, "/", denominator) : ""),
            "\"");


// Given a value in millimeters, it converts it to the specified units
// and returns it as a string.
// (E.g. 2.54, UNIT_OF_INCHES => "1\"")
function as_value_with_units(value, units) =
    units == UNIT_OF_DECIMAL_INCHES ?
        as_decimal_inches(to_inches(value)) :
        (units == UNIT_OF_FRACTIONAL_INCHES ?
            as_fractional_inches(to_inches(value)) :
            as_millimeters(value));
