# -Binary-Turtle-Graphics
RISC-V & x86 NASM Implementation of turtle graphics.
Description
In the project I have created a command like version of the turtles graphics. Code accepts .bin file format with the commands in a binary form.
In computer graphics, turtle graphics are vector graphics using a relative cursor (the "turtle") upon a Cartesian plane. The turtle has three attributes: a location, an orientation (or direction), and a pen. The pen, too, has attributes: color, on/off (or up/down) state [2]. The turtle moves with commands that are relative to its own position, such as "move forward 10 spaces" and "turn left 90 degrees". The pen carried by the turtle can also be controlled, by enabling it or setting its color. 
 
Turtle commands 
The length of all turtle commands is 16 or 32 bits. The first two bits define one of four commands (set position, set direction, move, set state). Unused bits in all commands are marked by the – character. They should not be taken into account when the command is decoded. 

Set position command 
The set position command sets the new coordinates of the turtle. It consists of two words. The first word defines the command (bits 1-0) and Y (bits y5-y0) coordinate of the new position. The second word contains the X (bits x9-x0) coordinate of the new position. The point (0,0) is located in the bottom left corner of the image. 

Table 1.The first word of the set position command. 

bit no. |15 | 14| 13| 12| 11| 10| 9| 8|
        | - | - | - | - | - | - | -| -|
bit no. | 7 | 6 | 5 | 4 | 3 | 2 | 1| 0|
        |y5 | y4| y3| y2| y1| y0| 1| 1|
        
Table 2. The second word of the set position command

bit no. |15 | 14| 13| 12| 11| 10| 9| 8|
        | - | - | - | - | - | - |x9|x8|
bit no. | 7 | 6 | 5 | 4 | 3 | 2 | 1| 0|
        |x7 | x6| x5| x4| x3| x2|x1|x0|

Set direction command 
The set direction command sets the direction in which the turtle will move, when a move command is issued. The direction is defined by the d1, d0 bits.

Table 3. The set direction command. 
bit no. |15 | 14| 13| 12| 11| 10| 9| 8|
        | d1| d0| - | - | - | - | -| -|
bit no. | 7 | 6 | 5 | 4 | 3 | 2 | 1| 0|
        | - | - | - | - | - | - | 1| 0|
        
Table 4. The description of the d1,d0 bits. 
![image](https://user-images.githubusercontent.com/64479565/217650523-41ce8d0e-ef59-413e-83ce-ccce240a2efb.png)

input input.bin
16/32 bit binary commands in a following form.

output output.bmp
600 x 50 image with the implemented changes.

        
