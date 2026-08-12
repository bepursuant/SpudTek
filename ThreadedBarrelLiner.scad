include <GIT_VERSION.scad>
echo("GIT_BUILD", GIT_BUILD);

// --- CONFIGURABLE PARAMETERS ---
$fn = 100;          // Smoothness of the circle (number of fragments)
height = 205;       // Total height of the tube (X height) including marker
outer_radius = 41.1/2;  // sleeve outside diameter / 2
inner_radius = 35/2;    // sleeve inside diameter / 2
spike_depth = 3;    // How deep the spikes go inward (at maximum)
marker_height = 10; // How long the marker is at the end of the barrel
marker_outer_radius = 48/2;

text_extend_depth = 0.3;



// -- advanced --
degrees_per_mm = 0.75;  // spike degrees to twist for every 1mm of height
spike_power = 300;  // Higher number = narrower/pointier needles  
transition_length = 0.33*height; // how long is the spike transition
slices_per_mm = 2;

// --- CALCULATION FOR TRANSITION ---
transition_height = height - transition_length;
slices = height * slices_per_mm;
slice_thickness = height / slices; 



module tube(){
    // form tube using individual stacked slices every slice_thickness mm (z)
    for (z = [0 : slice_thickness : height - slice_thickness]) {
        // current twist angle for this specific height
        current_twist = z * degrees_per_mm;
        
        // dynamic spike depth for this specific height
        // linearly increases from 0 to spike_depth over the transition zone, then stays constant
        current_depth = (z > transition_height) ? (spike_depth * ( (height-z) / transition_length)) : spike_depth;
        
        // extrude and position this specific thin slice
        translate([0, 0, z])
        rotate([0, 0, current_twist])
        linear_extrude(height = slice_thickness, convexity = 10) {
            difference() {
                // outer radius
                circle(r = (z > marker_height) ? outer_radius + 0.1 : marker_outer_radius + 0.1);
                
                // inner spiked radius
                spiked_circle(inner_radius, current_depth, spike_power);
            }
        }
    }
}

module clean_tube(){
    intersection(){
        tube();
        union(){
            cylinder(r=outer_radius, h=height);
            cylinder(r=marker_outer_radius, h=marker_height);
        }

    }

}

// make a 4 spiked circle
module spiked_circle(R, A, power) {
    polygon(points = [
        for (i = [0 : $fn-1]) 
            let(
                theta = i * 360 / $fn,
                r = R - A * pow(cos(2 * theta), power),
                x = r * cos(theta),
                y = r * sin(theta)
            )
            [x, y]
    ]);
}


// Curved radial text module wrapped around the outer wall
module marker_text(str_val, radius, rotation, font, size, font_spacing, depth) {
    num_chars = len(str_val);
    
    // Calculate arc angle per character based on average letter width (approx 0.6 * font_size)
    char_width_approx = size * font_spacing;
    step_angle = (char_width_approx / radius) * (180 / PI); 
    
    start_angle = -(num_chars - 1) * step_angle / 2; // Center string at angle 0

    for (i = [0 : num_chars - 1]) {
        angle = start_angle + (i * step_angle);
        
        rotate([0, 0, angle + rotation])
            // Embed 0.2mm into wall for manifold geometry

            translate([radius - 0.2, 0, (marker_height / 2) - (char_width_approx/2)])
                rotate([90, 0, 90])
                    linear_extrude(height = depth + text_extend_depth)
                        text(
                            str(str_val[i]), 
                            size = size, 
                            halign = "center", 
                            valign = "baseline", 
                            font = font
                        );
    }
}

// --- RENDER SELECTION ---

union()
{
    color("Orange")
        clean_tube();

    color("White")
    {
        intersection(){
            cylinder(r = marker_outer_radius, h = marker_height);
            union(){
                marker_text(GIT_VERSION, marker_outer_radius, 90, "Consolas", 3.5, 0.7, 0);
                marker_text("spudtek", marker_outer_radius, 270, "Liberation Sans:style=Bold", 6.4, 0.75, 0);
            }
        }
    }
}

