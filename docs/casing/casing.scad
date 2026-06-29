// From https://github.com/BelfrySCAD/BOSL2
include <../../../BOSL2/std.scad>
include <../../../BOSL2/threading.scad>
include <../../../BOSL2/std.scad>

// From https://github.com/mrWheel/YAPP_Box
include <../../../YAPP_Box/YAPPgenerator_v3.scad>

// From https://github.com/brodykenrick/text_on_OpenSCAD
//use <../../../text_on_OpenSCAD/text_on.scad>

params = create_params(
  inner_length = 120,
  inner_depth = 60,
  inner_height = 30,
  wall_thickness = 3,
  led_housing_diameter = 7.6 + 1.0, // Add uncertainty
  wire_diameter = 3.15 + 0.5, // Add uncertainty 
  display_mode = 3 // How the casing is displayed:
  // 0: to print, both
  // 1: to print, lower half, with wire holes
  // 2: to print, upper half, with text
  // 3: assambled
  // 4: assambled, cutout from left to right
  // 5: assambled, cutout from front to back
);

// Some warnings
if (struct_val(params, "wall_thickness") <= 2.0) {
  echo("Warning: a wall thickness below 2 mm results in a fragile casing");
}


function create_params(
  inner_length,
  inner_depth,
  inner_height,
  wall_thickness,
  led_housing_diameter,
  wire_diameter,
  display_mode
) 
  = struct_set(
    [],  
    [
      "inner_length", inner_length, 
      "inner_depth", inner_depth, 
      "inner_height", inner_height, 
      "wall_thickness", wall_thickness, 
      "led_housing_diameter", led_housing_diameter, 
      "wire_diameter", wire_diameter, 
      "display_mode", display_mode,
      // Helpers
      "outer_length", inner_length + wall_thickness, 
      "outer_depth", inner_depth + wall_thickness, 
      "outer_height", inner_height + wall_thickness, 
    ]
  );

module check_params(params) 
{
  assert(is_struct(params), "params must be a struct. Tip: use 'create_params'");
  inner_length = struct_val(params, "inner_length");
  inner_depth = struct_val(params, "inner_depth");
  inner_height = struct_val(params, "inner_height");
  wall_thickness = struct_val(params, "wall_thickness");
  display_mode = struct_val(params, "display_mode");

  // Variables must make sense
  assert(inner_length >= 0);
  assert(inner_depth >= 0);
  assert(inner_height >= 0);
  assert(wall_thickness > 0);
  assert(display_mode >= 0);
  assert(display_mode <= 5);
}


module draw_casing(params) 
{
  check_params(params);
  inner_length = struct_val(params, "inner_length");
  inner_depth = struct_val(params, "inner_depth");
  inner_height = struct_val(params, "inner_height");
  outer_length = struct_val(params, "outer_length");
  outer_depth = struct_val(params, "outer_depth");
  outer_height = struct_val(params, "outer_height");
  wall_thickness = struct_val(params, "wall_thickness");
  // Hollow 3/4 box
  difference() { 
    union() {
      // Hollow box
      difference() {
        cube([outer_length, outer_depth, outer_height], center = true);
        cube([inner_length, inner_depth, inner_height], center = true);
      };
      translate([0, -outer_depth / 2, 0])
        cube([outer_length / 2, outer_depth, outer_height / 2]);
    };
    translate([wall_thickness / 2, wall_thickness - (outer_depth / 2), wall_thickness / 2])
      cube([(inner_length / 2) - wall_thickness, inner_depth / 2 - (2 * wall_thickness), inner_height / 2], center = false);
    translate([wall_thickness / 2, wall_thickness, wall_thickness / 2])
      cube([(inner_length / 2) - wall_thickness, inner_depth / 2 - (2 * wall_thickness), inner_height / 2], center = false);

  };

  
}

//-----------------------------------------------------------------------
// Displayal
//-----------------------------------------------------------------------
module display(params)
{
  check_params(params);
  display_mode = struct_val(params, "display_mode");
  if (display_mode == 0 || display_mode == 1 || display_mode == 2) 
  {
    // Make the outsides be up; only scaffolding marks on the inside
    if (display_mode == 0 || display_mode == 2)
    {
      // draw_upper_half(params);
    }
    if (display_mode == 0 || display_mode == 1)
    {
      //spere_diameter = struct_val(params, "sphere_diameter");
      //translate([spere_diameter + 1, 0, 0])
      //rotate([180, 0, 0])
      //draw_lower_half(params);
    }
  }
  else if (display_mode == 3) 
  {
    draw_casing(params);
  }
  else if (display_mode == 4) 
  {
    // Show cutout
    difference() {
      draw_casing(params);
      translate([-500,0,-500])
        cube([1000, 100, 1000]);
    }
  } 
  else if (display_mode == 5) 
  {
    // Show cutout
    difference() {
      draw_casing(params);
      translate([0,-500,-500])
        cube([100, 1000, 1000]);
    }
  } 
}

//-----------------------------------------------------------------------
// Program starts here
//-----------------------------------------------------------------------
display(params);