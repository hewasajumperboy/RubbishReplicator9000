
lm8uu_length = 24;
lm8luu_length = 45;
height = 27;

retaining_hole_offset = 5;
retaining_hole_diam = 3.5;
retaining_hole_countersink_diam = 7;
retaining_hole_countersink_depth = 2;
retaining_hole_nuttrap_depth = 4.1;

block_width = 22;
barrel_diam = 24;
barrel_offset = 12;
gap_width = 10;
lm8uu_diam = 15.5;

mount_width = 37;
mount_height = 3.5;
mount_hole_spacing = 28.4;
mount_hole_diam = 3.2;
mount_screwhead_clearance_diam = 5.5;

corner_round_diam = 7;
emboss_heart_height = 0.6;
DEBUG = 0;

if (true)
{   
    rotate([90 * (1-DEBUG), 0, -90 * (1-DEBUG)])
    lm8uu_holder();
}

module lm8uu_holder()
{
    bearing_holder(length = lm8uu_length);
}

module lm8luu_holder()
{
    bearing_holder(length = lm8luu_length);
}

module bearing_holder2(length = lm8uu_length)
{
        union()
        {
            // main block
            translate([0, 0, height/2])
            cube([block_width, length, height], center=true);

            translate([0, 0, barrel_offset])
            translate([0, -0.05/2, 0])
            rotate([90, 0, 0])
            cylinder(d=barrel_diam, h=length-0.05, center=true, $fn=28);
        }
}

module bearing_holder(length = lm8uu_length)
{
    // mount plate
    color("greenyellow") difference()
    {
        translate([0, 0, mount_height/2])
        cube([mount_width, length, mount_height], center=true);
        
        // mount holes
        for(i=[-1, 1])
            translate([mount_hole_spacing/2*i, 0, 0])
            cylinder(d=mount_hole_diam, h=50, $fn=32, center=true);
        
        // remove the mount plate above the hole, we don't need it
        translate([0, 50, 0])
        translate([0, mount_hole_diam/2+3.3, 0])
        cube([100, 100, 100], center=true);
        
        // cut the corner at the bottom
        for(i=[-1, 1])
            translate([mount_hole_spacing/2*i, 0, mount_height/2])
            translate([7*i, -length/2, 0])
            rotate([0, 0, -35*i])
            cube([10, 10, mount_height+2], center=true);
    }
    
    color("greenyellow") difference()
    {
        union()
        {
            // main block
            translate([0, 0, height/2])
            cube([block_width, length, height], center=true);

            // barrel
            difference()
            {
                translate([0, 0, barrel_offset])
                rotate([90, 0, 0])
                // need the tiny epsilon to avoid manifold errors in stl
                cylinder(d=barrel_diam, h=length-0.01, center=true, $fn=28);
                
                // cut everything lower than the mountplate
                translate([0, 0, -50])
                translate([0, 0, mount_height])
                cube([100, 100, 100], center=true);
                
                // make clearance for the heads of the mounting screws to be inserted
                for(i=[-1, 1])
                    translate([mount_hole_spacing/2*i, 0, 0])
                    cylinder(d=mount_screwhead_clearance_diam, h=height*2+1, $fn=32, center=true);
            }
        }
        
        // square cutout at top
        translate([0, 0, height/2+height/4])
        cube([gap_width, length+1, height/2+0.1], center=true);
        
        // hollow out barrel
        translate([0, 0, barrel_offset])
        rotate([90, 0, 0])
        cylinder(d=lm8uu_diam, h=length+0.1, center=true, $fn=25);
        
        // retaining hole for squeezing lm8uu
        translate([0, 0, height])
        translate([0, 0, -retaining_hole_offset])
        {
            rotate([0, 90, 0])
            cylinder(d=retaining_hole_diam, h=block_width+1, $fn=32, center=true);
            
            // countersinking for retaining hole screwhead on one side
            translate([block_width/2, 0, 0])
            translate([0.1, 0, 0])     // epsilon
            rotate([0, 0, 180])
            rotate([0, 90, 0])
            cylinder(d=retaining_hole_countersink_diam, h=retaining_hole_countersink_depth+0.1, $fn=32);
            
            // nut trap on the other side
            translate([-block_width/2, 0, 0])
            translate([-0.1, 0, 0])     // epsilon
            rotate([0, 90, 0])
            rotate([0, 0, 360/6/2])
            cylinder(r=5.5 / cos(180 / 6) / 2 + 0.2, h=retaining_hole_nuttrap_depth+0.1, $fn=6, center=true);
        }
        
        // rounded corners
        for(i=[-1,1])
        {
            translate([0, 0, height])
            translate([0, 0, -corner_round_diam/2])
            translate([0, length/2 * i, 0])
            translate([0, -corner_round_diam/2 * i, 0])
            rounded_corner(diam = corner_round_diam, side = i);
        }
    }
    
    // hearts on top of bearing
    for(i=[-1,1])
    {
        translate([0, length/2, 0])
        translate([0, emboss_heart_height/2, 0])
        translate([0, 0, height])
        translate([block_width/2*i, 0, 0])
        translate([-(block_width-gap_width)/4*i, 0, 0])
        translate([0, 0, -6])
        {
            //%cube([3, 3, 3], center=true);
            
            translate([-2.1, 0, -2.5])
            rotate([90, 0, 0])
            color(DEBUG ? "blueviolet" : "greenyellow")
            linear_extrude(height=emboss_heart_height, center=true)
            scale([0.075, 0.075, 1])
            import("heart.dxf", center=true);
        }
    }
}

module rounded_corner(diam, side)
{
    difference()
    {
        cube([500, diam+0.1, diam+0.1], center=true);
        
        rotate([0, 90, 0])
        cylinder(d=diam, h=501, $fn=32, center=true);
        
        // cut off the bottom half
        translate([0, 0, -diam/2])
        cube([502, diam+1, diam], center=true);
        
        // cut off either the left or right side depending on side variable
        translate([0, diam/2 * -side, 0])
        cube([502, diam, diam+1], center=true);
    }
}
