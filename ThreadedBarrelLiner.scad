// --- CONFIGURABLE PARAMETERS ---
$fn = 100;          // Smoothness of the circle (number of fragments)
height = 205;       // Total height of the tube (X height) including marker
outer_radius = 41.1/2;  // sleeve outside diameter / 2
inner_radius = 35/2;    // sleeve inside diameter / 2
spike_depth = 3;    // How deep the spikes go inward (at maximum)
marker_height = 10; // How long the marker is at the end of the barrel
marker_outer_radius = 48/2;

// -- advanced --
degrees_per_mm = 0.75;  // spike degrees to twist for every 1mm of height
spike_power = 300;  // Higher number = narrower/pointier needles
spike_transition_factor = 0.33; // What percentage of the tube will have transitional ribs
slices_per_mm = 2;

// --- CALCULATION FOR TRANSITION ---
transition_height = height * spike_transition_factor;
marker_start_height = height - marker_height;
slices = height * slices_per_mm;
slice_thickness = height / slices; 

module tube(){
    // form tube using individual stacked slices every slice_thickness mm (z)
    for (z = [0 : slice_thickness : height - slice_thickness]) {
        // current twist angle for this specific height
        current_twist = z * degrees_per_mm;
        
        // dynamic spike depth for this specific height
        // linearly increases from 0 to spike_depth over the transition zone, then stays constant
        current_depth = (z < transition_height) ? (spike_depth * (z / transition_height)) : spike_depth;
        
        // extrude and position this specific thin slice
        translate([0, 0, z])
        rotate([0, 0, current_twist])
        linear_extrude(height = slice_thickness, convexity = 10) {
            difference() {
                // outer radius
                circle(r = (z < marker_start_height) ? outer_radius : marker_outer_radius);
                
                // inner spiked radius
                spiked_circle(inner_radius, current_depth, spike_power);
            }
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

tube();
