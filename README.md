# -Binary-Turtle-Graphics
# RISC-V & x86 NASM Implementation of turtle graphics.
# Description
In the project I have created a command like version of the turtles graphics. Code accepts .bin file format with the commands in a binary form.
In computer graphics, turtle graphics are vector graphics using a relative cursor (the "turtle") upon a Cartesian plane. The turtle has three attributes: a location, an orientation (or direction), and a pen. The pen, too, has attributes: color, on/off (or up/down) state [2]. The turtle moves with commands that are relative to its own position, such as "move forward 10 spaces" and "turn left 90 degrees". The pen carried by the turtle can also be controlled, by enabling it or setting its color. 
 
# Turtle commands 
The length of all turtle commands is 16 or 32 bits. The first two bits define one of four commands (set position, set direction, move, set state). Unused bits in all commands are marked by the – character. They should not be taken into account when the command is decoded. 

# Set position command 
The set position command sets the new coordinates of the turtle. It consists of two words. The first word defines the command (bits 1-0) and Y (bits y5-y0) coordinate of the new position. The second word contains the X (bits x9-x0) coordinate of the new position. The point (0,0) is located in the bottom left corner of the image. 

# Table 1.The first word of the set position command. 

![image](https://user-images.githubusercontent.com/64479565/217650851-82c92958-239c-4e27-99ff-131229eaf7f3.png)

# Set direction command 
The set direction command sets the direction in which the turtle will move, when a move command is issued. The direction is defined by the d1, d0 bits.

![image](https://user-images.githubusercontent.com/64479565/217650914-eb1361e8-70e7-42f8-9eee-fc7052823139.png)
        
#Table 4. The description of the d1,d0 bits. 
![image](https://user-images.githubusercontent.com/64479565/217650963-631fbc99-0db3-45c0-a086-e4afb56f7e05.png)

# Move command 
The move command moves the turtle in direction specified by the d1-d0 bits. The movement distance is defined by the m9-m0 bits. If the destination point is located beyond the drawing area the turtle should stop at the edge of the drawing. It can’t leave the drawing area. The turtle leaves a visible trail when the pen is lowered (bit ud). The color of the trail is defined by the r3-r0, g3-g0, b3-b0 bits. 
![image](https://user-images.githubusercontent.com/64479565/217651082-d03b26cc-6b3f-4ab4-8f62-0f0095ec7a8d.png)

# Set pen state command 
The pen state command defines whether the pen is raised or lowered (bit ud) and the color of the trail. Bits r3-r0 are the most significant bits of the 8-bits red component of the color (remaining bits are set to zero). Bits g3-g0 are the most significant bits of the 8-bits green component of the color (remaining bits are set to zero). Bits b3-b0 are the most significant bits of the 8-bits blue component of the color (remaining bits are set to zero). 

![image](https://user-images.githubusercontent.com/64479565/217651216-44cbdfbd-0e13-4438-b43b-ece002d80247.png)

# input input.bin
16/32 bit binary commands in a following form.

# output output.bmp
600 x 50 image with the implemented changes.

        
