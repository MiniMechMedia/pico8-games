
* Start with 2D rendering
	* Naive draw square
		- Draw square +/-1^2
		- Oops where is it
	* World to Screen coordinates
		- Cool there we go
		- Sliders for translation? Probs easier to see when hardcoded
		- We can have the camera zoom in or out, and move around the scene
			- Can interpret it as moving the square or moving the camera. More obvious when there are multiple objects in the scene
* Let's go to 3D
	* Create cube data structure
	* Simplest thing we can do with the z coordinate - throw it away!
	* Draw cube
		- uh oh! Still a square?
		- orthographic projection
	* Draw cube with perspective
		- perspective projection
* Let's fill it in
	* Algorithm is to loop through pixels and test if inside
* Now let's rotate
	* Oops, we are clipping incorrectly
* Now let's sort by depth
* Now let's use flat shading

* Appendix
	* Girard shading
		- non uniform
	* Phong shading
		- less sensitive to vertices
	* Shadows??
		- Take into account other faces
	* Ray tracing
		- Take into account other faces as a light source
		- Example of holding up a brightly colored folder and it illuminating my face
		

When to rotate?

	* Draw cube with rotation, orthographic

Future Work
* Math
* More colors (dithering)


TODO
* Should be able to slow it down with flip()?
* Should be able to draw on the screen - rectangles + freehand
* Only transition when holding x