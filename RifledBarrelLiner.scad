include <GIT_VERSION.scad>
echo("GIT_BUILD", GIT_BUILD);

// --- CONFIGURABLE PARAMETERS --- 
$fn = 300; // Smoothness of the circle (number of fragments)
height = 205; // Total height of the tube (X height) including marker
outer_radius = 41.1 / 2; // sleeve outside diameter / 2
inner_radius = 35 / 2; // sleeve inside diameter / 2
spike_depth = 3; // How deep the spikes go inward (at maximum)

marker_height = 10; // How long the marker is at the end of the barrel
marker_outer_radius = 48 / 2;

coupler_height = 10; // How tall from the inside end of the tube will the coupler section be?
coupler_inner_radius = 38.2 / 2; // outside diameter of the tip of your shell

// --- TEXT ---
text_depth = 0.5;
text_protrusion = 0.05;

// serial number (git version)
serial_text = GIT_VERSION;
serial_rotation = 180;
serial_font = "Bahnschrift";
serial_font_size = 3.5;
serial_font_spacing = 0.7;

// branding
brand_text = "SPUDTEK";
brand_rotation = -70;
brand_rotation2 = 70;
brand_font = "Liberation Sans:style=Bold";
brand_font_size = 6.4;
brand_font_spacing = 0.75;

// -- advanced --
degrees_per_mm = 0.75; // spike degrees to twist for every 1mm of height
spike_power = 300; // Higher number = narrower/pointier needles  
transition_length = 0.33 * height; // how long is the spike transition
slices_per_mm = 2;

// --- CALCULATION FOR TRANSITION ---
transition_height = height - transition_length;
slices = height * slices_per_mm;
slice_thickness = height / slices;

total_height = height + coupler_height;

module tube() {
  // form tube using individual stacked slices every slice_thickness mm (z)
  for (z = [0:slice_thickness:total_height - slice_thickness]) {
    // current twist angle for this specific height
    current_twist = z * degrees_per_mm;

    // dynamic spike depth for this specific height
    // linearly increases from 0 to spike_depth over the transition zone, then stays constant
    current_depth = (z > transition_height) ? (spike_depth * ( (height - z) / transition_length)) : spike_depth;

    // extrude and position this specific thin slice
    translate([0, 0, z])
      rotate([0, 0, current_twist])
        linear_extrude(height=slice_thickness, convexity=10) {
          difference() {
            // outer radius
            circle(r=(z > marker_height) ? outer_radius : marker_outer_radius);

            // if we are at coupler height, just do a circle, otherwise do some rifles
            if(z >= height)
              circle(r=coupler_inner_radius);
            else
              spiked_circle(inner_radius, current_depth, spike_power);
          }
        }
  }
}

// make a 4 spiked circle
module spiked_circle(R, A, power) {
  polygon(
    points=[
      for (i = [0:$fn - 1]) let (
        theta = i * 360 / $fn,
        r = R - A * pow(cos(2 * theta), power),
        x = r * cos(theta),
        y = r * sin(theta)
      ) [x, y],
    ]
  );
}

// Curved radial text module wrapped around the outer wall
module marker_text(str_val, radius, rotation, font, font_size, font_spacing, depth = text_depth, protrusion = text_protrusion) {
  num_chars = len(str_val);

  // Calculate arc angle per character based on average letter width (approx 0.6 * font_size)
  char_width_approx = font_size * font_spacing;
  step_angle = (char_width_approx / radius) * (180 / PI);

  start_angle = -(num_chars - 1) * step_angle / 2; // Center string at angle 0

  for (i = [0:num_chars - 1]) {
    angle = start_angle + (i * step_angle);

    rotate([0, 0, angle + rotation])
      translate([radius - 5, 0, (marker_height / 2) - (char_width_approx / 2)])
        rotate([90, 0, 90])
          linear_extrude(height=10, convexity=10)
            text(
              str(str_val[i]),
              size=font_size,
              halign="center",
              valign="baseline",
              font=font
            );
  }
}

// Curved text module aligned and un-mirrored for the bottom face
module marker_flat_text(str_val, radius, rotation = 0, font = "", font_size = 5, font_spacing = 0.6, extrude_height = 1) {
    num_chars = len(str_val);

    // Calculate arc angle per character
    char_width_approx = font_size * font_spacing;
    step_angle = (char_width_approx / radius) * (180 / PI);

    start_angle = -(num_chars - 1) * step_angle / 2;

    for (i = [0 : num_chars - 1]) {
        // Advance angle forward for left-to-right reading
        angle = start_angle + (i * step_angle);

        rotate([0, 0, angle + rotation])
            translate([radius, 0, 0])
                rotate([0, 0, -90])
                    linear_extrude(height = extrude_height, convexity = 10)
                        mirror([1, 0, 0]) // Un-mirrors 2D text when viewed from underneath
                            text(
                                str(str_val[i]),
                                size = font_size,
                                halign = "center",
                                valign = "center",
                                font = font
                            );
    }
}

module marker() {
  intersection() {
    // rendered text
    union() {
      marker_text(serial_text, marker_outer_radius, serial_rotation, serial_font, serial_font_size, serial_font_spacing);
      marker_text(brand_text, marker_outer_radius, brand_rotation, brand_font, brand_font_size, brand_font_spacing);
      marker_text(brand_text, marker_outer_radius, brand_rotation2, brand_font, brand_font_size, brand_font_spacing);
    }
    // cut to desired text thickness with a tube
    difference() {
      cylinder(h=marker_height, r=marker_outer_radius + text_protrusion);
      cylinder(h=marker_height, r=marker_outer_radius - text_depth);
    }
  }
}

module coupler() {
  translate([0, 0, height])
    difference() {
      cylinder(h=coupler_height, r=outer_radius);
      cylinder(h=coupler_height, r=coupler_inner_radius);
    }
}

color("orange") {
  tube();
  //coupler();
}

color("white")
{
  marker();
  marker_flat_text("THEY CALL ME TATER SALAD", marker_outer_radius - 3.5, 0, serial_font, serial_font_size, serial_font_spacing);
}
