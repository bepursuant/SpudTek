$fn = 300;

inside_diameter = 41;
rim_diameter = 44.1;
rim_height = 2;

split_width = 1;

total_height = 30;

hole_diameter = 2.6;
hole_clearance_diameter = 6;

cut_radius = 7;



module plug()
{
    difference()
    {
    
        union()
        {
            // body
            cylinder(h = total_height, r = inside_diameter/2);
            
            // rim
            cylinder(h = rim_height, r = rim_diameter/2);
            
            // cut
            //intersection(){
            
            //    rotate([90, 0, 0])
            //        cylinder(h = rim_diameter, r = cut_radius, center = true);
            
            //    translate([0, 0, total_height/2])
            //        cube([rim_diameter, rim_diameter, total_height], center=true);
            //}
        }
        
        // split
        translate([-(rim_diameter/2), -(split_width/2), rim_height])
            cube([rim_diameter, split_width, total_height]);
            
        // hole
        cylinder(h = total_height, r = hole_diameter/2);
        
        // hole head
        cylinder(h = rim_height, r = hole_clearance_diameter/2);
        
    }

    

}

plug();