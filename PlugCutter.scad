// Parametric Potato Slug Cutter & Support-Free Plunger
// Units: millimeters (mm)

$fn = 90; // High resolution curves

// --- CORE TUBE DIMENSIONS ---
slug_diameter    = 35.0; // Target potato core inner diameter (mm)
wall_thickness   = 3.0;  // Tube wall thickness (mm)
cutter_height    = 70.0; // Main cylinder height (mm)
tube_bevel_h     = 6.0;  // Height of main tube bottom bevel (mm)
clearance        = 0.4;  // Fit clearance for plunger inside cutter bore (mm)

// --- RIB & GUSSET PARAMETERS ---
rib_thickness    = 3.0;  // Thickness of slicing rib & plunger gusset (mm)
rib_gap          = 12.0; // Clearance gap between cylinder & backplate (mm)
rib_z_bottom     = 6.0;  // Base height of cutter rib (clears tube bevel) (mm)
rib_bevel_h      = 6.0;  // Height of cutter rib bottom V-bevel (mm)
rib_reach_pct    = 0.80; // Configurable plunger rib reach percentage (0.80 = 80%)

// --- MOUNTING PLATE & TOP DECK PARAMETERS ---
cutter_mount_w   = 41.0; // Overall width of cutter backing plate (2 * outer_r) (mm)
mount_thickness  = 4.0;  // Thickness of back mounting wall (mm)
top_deck_h       = 3.0;  // Thickness of top deck plate (mm)
plunger_mount_h  = 45.0; // Height of upward-extending plunger mount (mm)
screw_dia        = 4.5;  // M4 screw clearance hole (mm)
cutter_screw_x   = 26.0; // Horizontal screw spacing for cutter plate (mm)
plunger_screw_x  = 22.0; // Horizontal screw spacing for plunger plate (mm)

// --- DERIVED GEOMETRY ---
outer_r          = (slug_diameter / 2) + wall_thickness; // 20.5 mm
inner_r          = slug_diameter / 2;                    // 17.5 mm
plunger_r        = inner_r - clearance;                  // 17.1 mm
plunger_mount_w  = plunger_r * 2;                        // 34.2 mm (Matches plunger diameter)
plunger_height   = cutter_height + 5.0;                  // 75.0 mm
plate_y_front    = outer_r + rib_gap;                    // 32.5 mm
plate_y_back     = plate_y_front + mount_thickness;      // 36.5 mm

// Plunger gusset front reach calculation (based on plunger_r)
total_span       = plate_y_front + plunger_r;
rib_front_y      = plate_y_front - (total_span * rib_reach_pct);

// --- PART SELECTION ---
// Options: "both", "cutter", or "plunger"
part = "both";

if (part == "cutter" || part == "both") {
    potato_cutter();
}

if (part == "plunger" || part == "both") {
    // Offset along X for display when viewing both parts together
    offset_x = (part == "both") ? (cutter_mount_w + 20) : 0;
    translate([offset_x, 0, 0])
        potato_plunger();
}

// --- MODULE DEFINITIONS ---

module potato_cutter() {
    difference() {
        union() {
            // 1. MAIN CUTTER CYLINDER
            cylinder(r = outer_r, h = cutter_height);

            // 2. FLAT CONNECTING RIB WITH MATCHING BEVEL
            translate([-rib_thickness / 2, outer_r - 0.2, rib_z_bottom + rib_bevel_h])
                cube([rib_thickness, rib_gap + 0.4, cutter_height - (rib_z_bottom + rib_bevel_h)]);

            hull() {
                translate([-rib_thickness / 2, outer_r - 0.2, rib_z_bottom + rib_bevel_h - 0.01])
                    cube([rib_thickness, rib_gap + 0.4, 0.01]);

                translate([-0.005, outer_r - 0.2, rib_z_bottom])
                    cube([0.01, rib_gap + 0.4, 0.01]);
            }

            // 3. BACK MOUNTING PLATE
            translate([-cutter_mount_w / 2, plate_y_front, rib_z_bottom])
                cube([cutter_mount_w, mount_thickness, cutter_height - rib_z_bottom]);

            // 4. TOP HORIZONTAL BRACING DECK
            translate([-cutter_mount_w / 2, 0, cutter_height - top_deck_h])
                cube([cutter_mount_w, plate_y_back, top_deck_h]);
        }

        // --- SUBTRACTIONS ---

        // Full Through-Bore (35mm core)
        translate([0, 0, -5])
            cylinder(r = inner_r, h = cutter_height + 10);

        // Circular Outer Cutting Bevel
        translate([0, 0, -0.1])
            difference() {
                cylinder(r = outer_r + 1, h = tube_bevel_h + 0.1);
                cylinder(r1 = inner_r, r2 = outer_r, h = tube_bevel_h + 0.1);
            }

        // Mounting Screw Holes (2 pairs of M4 holes)
        for (x_pos = [-cutter_screw_x / 2, cutter_screw_x / 2]) {
            for (z_pos = [cutter_height - top_deck_h - 10, rib_z_bottom + 15]) {
                translate([x_pos, plate_y_back + 1, z_pos])
                    rotate([90, 0, 0])
                        cylinder(d = screw_dia, h = mount_thickness + 2);
            }
        }
    }
}

module potato_plunger() {
    difference() {
        union() {
            // 1. SOLID PLUNGER SHAFT
            cylinder(r = plunger_r, h = plunger_height);

            // 2. UNIFORM TOP DECK (Width equals plunger_r * 2)
            translate([0, 0, plunger_height - top_deck_h]) {
                cylinder(r = plunger_r, h = top_deck_h);

                // Straight rectangular extension back to mounting plate
                translate([-plunger_r, 0, 0])
                    cube([plunger_mount_w, plate_y_back, top_deck_h]);
            }

            // 3. UPWARD EXTENDING BACK MOUNTING PLATE (34.2mm wide)
            translate([-plunger_mount_w / 2, plate_y_front, plunger_height - top_deck_h])
                cube([plunger_mount_w, mount_thickness, plunger_mount_h + top_deck_h]);

            // 4. TRIANGULAR REINFORCING RIB
            translate([0, 0, plunger_height])
                rotate([90, 0, 90])
                    linear_extrude(height = rib_thickness, center = true)
                        polygon(points = [
                            [rib_front_y, 0],                        // Front tip
                            [plate_y_front + 0.2, 0],                // Back deck corner
                            [plate_y_front + 0.2, plunger_mount_h - 5.0] // Top mount corner
                        ]);
        }

        // --- SUBTRACTIONS ---

        // Bottom Lead-in Chamfer for smooth bore entry
        translate([0, 0, -0.1])
            difference() {
                cylinder(r = plunger_r + 1, h = 2.0);
                cylinder(r1 = plunger_r - 1.5, r2 = plunger_r, h = 2.1);
            }

        // Mounting Screw Holes (2 pairs of M4 holes spaced 22mm apart)
        for (x_pos = [-plunger_screw_x / 2, plunger_screw_x / 2]) {
            for (z_pos = [plunger_height + 12, plunger_height + plunger_mount_h - 10]) {
                translate([x_pos, plate_y_back + 1, z_pos])
                    rotate([90, 0, 0])
                        cylinder(d = screw_dia, h = mount_thickness + 2);
            }
        }
    }
}