include <GIT_VERSION.scad>
echo("GIT_BUILD", GIT_BUILD);

function strtoupper(string) = chr([
    for (s = string) 
    let (c = ord(s)) 
    (c >= 97 && c <= 122) ? c - 32 : c
]);



// --- CONFIGURABLE PARAMETERS --- 
$fn = 300; // Smoothness of the circle (number of fragments)
height = 205; // Total height of the tube (X height) including marker
outer_radius = 41.1 / 2; // sleeve outside diameter / 2
inner_radius = 35 / 2; // sleeve inside diameter / 2
spike_depth = 2; // How deep the spikes go inward (at maximum)

marker_height = 6; // How long the marker is at the end of the barrel
marker_outer_radius = 48.5 / 2;
marker_chamfer_size = 1.5;

coupler_height = 30; // How tall from the inside end of the tube will the coupler section be?
coupler_inner_radius = 38.2 / 2; // outside diameter of the tip of your shell
coupler_chamfer_size = 2;

// --- TEXT ---
text_depth = 2;
text_protrusion = 0.05;

// serial number (git version)
serial_text = strtoupper(GIT_VERSION);;
serial_rotation = 180;
serial_font = "Bahnschrift";
serial_font_size = 4;
serial_font_spacing = 0.7;

// branding
brand_text = "SPUDTEK";
brand_rotation = -70;
brand_rotation2 = 70;
brand_font = "Bahnschrift:style=Bold";
brand_font_size = 4;
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
echo("total_height=", total_height);

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
        linear_extrude(height=slice_thickness, convexity=100) {
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

// Clean curved text for the bottom face with valid 3D normals
module marker_front_text(str_val, radius, rotation = 0, font = "", font_size = 5, font_spacing = 0.6, depth = 1, direction=1) {
    num_chars = len(str_val);

    char_width_approx = font_size * font_spacing;
    step_angle = (char_width_approx / radius) * (180 / PI);
    start_angle = -1*(direction)*(num_chars - 1) * step_angle / 2;

    for (i = [0 : num_chars - 1]) {
        angle = start_angle + (direction * i * step_angle);

        rotate([0, 0, angle + rotation])
            translate([direction * radius, 0, depth-0.01])
                // Rotate 180 on X to view correctly from below without flipping 3D normals inside-out
                rotate([180, 0, 90]) 
                    linear_extrude(height = depth, convexity = 10)
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
    text_center_radius = inner_radius + ((marker_outer_radius - marker_chamfer_size)-inner_radius)/2;
    marker_front_text(brand_text, text_center_radius, rotation=0, brand_font, brand_font_size, font_spacing=0.85, depth=text_depth);
    marker_front_text(serial_text, text_center_radius, rotation=0, serial_font, serial_font_size, font_spacing=0.85, depth=text_depth, direction=-1);
}


module cylinder_bottom_chamfer(radius, size){
  translate([0, 0, -0.1]){
    difference(){
        cylinder(h=size+0.1, r=radius+0.1);
        cylinder(h=size+0.1, r1=radius-size,r2=radius);
    }
  }
}

module cylinder_top_chamfer(radius, size, height){
  translate([0, 0, height-size])
    cylinder(h=size+0.1, r1=radius-size, r2=radius);
}


color("red")
{
  difference()
  {
    tube();
    cylinder_bottom_chamfer(marker_outer_radius, marker_chamfer_size);
    cylinder_top_chamfer(outer_radius, coupler_chamfer_size, total_height);
    cylinder_top_chamfer(coupler_inner_radius, 2, height);
  }
}

color("white")
{
  marker();
}



