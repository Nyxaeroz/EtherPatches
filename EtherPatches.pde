import java.io.File;

PImage input;
PImage output;

// THESE SHOULD MATCH THE DIMENSIONS OF THE CANVAS
// MAKE SURE ITS LARGE ENOUGH FOR THE IMAGE YOU'RE PATCHING
int w = 2*1920;
int h = 1080;

// parameters that set the sizes of the windows that check if we're still in the same blob
// adjust these if your results are unsatisfactory (I've had good results with h=5 and v=20 or h=20 and v=20)
int hpass_window = 5;
int vpass_window = 20;

// variable for batch conversion
boolean batch = true;
String input_dir = "input";
String output_dir = "output";

// when not using batch conversion, specify filename here:
String filename = "example.png";

// flag for displaying input and output
boolean display = false;

void setup() {
  // SIZE OF THE CANVAS -- not relevant for conversion
  size(2000,200);
  
  if (batch) batch_conversion();
  else {
    single_file_conversion(filename); 
    output.save(sketchPath() + "/output/PATCHED-" + filename);
  }
 
  if (display) { 
    image(input,0,0);
    image(output,w,0);
  }
  

}

void batch_conversion () {
  print("now starting batch conversion!\n");
  
  File dir = new File(sketchPath() + "/" + input_dir);
  print("using directory: " + dir + "\n");
  
  File[] files = dir.listFiles();
  print("nr of files: " + files.length + "\n");

  for( int i=0; i < files.length; i++ ){ 
    String path = files[i].getAbsolutePath();

    // verify file extension
    if( path.toLowerCase().endsWith(".jpg") || path.toLowerCase().endsWith(".png") ) {
      input = loadImage( path );
      w = input.width;  
      h = input.height;
      print("image " + i + " dimensions: " + w + "x" + h + "\n");
      
      output = createImage(w,h,RGB); 
      single_file_conversion(path);
      output.save(path.replace("\\input\\", "\\output\\PATCHED-"));
      print("saved to:", path.replace("\\input\\", "\\output\\PATCHED-"), "\n\n");
      
   }
 }
}


void single_file_conversion (String name) {
  input = loadImage(name);
  w = input.width;
  h = input.height;
  print("input image width: " + w + " input image height: " + h + "\n");
  output = createImage(w,h,RGB);

  // THIS IS WHERE THE MAGIC HAPPENS
  clear_text(w,0);
}


//============================//
//                            //
//  MAIN CLEARING FUNCTION    //
//                            //
//============================//

// function to clear text within blocks (using a horizontal and vertical pass)
// int x, y: starting position of new image displayed on canvas
void clear_text(int x_off, int y_off) {
  // horizontal pass over the colored blobs
  // should only let some edge cases through (like lines within a colored blob that start with a black pixel)
  for (int y = 0; y < h; y++) {
    color cur_marker = #FFFFFF;
    for (int x = 0; x < w; x++ ) {
      color cur = input.get(x,y);
      if ( cc(cur,#FFFFFF) ) { cur_marker = #FFFFFF; }
      else if ( !cc(cur,cur_marker) && !is_marker_present(cur_marker, x, y, hpass_window) ) { cur_marker = cur; }
      output.set(x,y,cur_marker);
    }
  }
  
  // vertical pass over the colored blobs (over output of horizontal pass)
  for (int x = 0; x < w; x++ ) {
    color cur_marker = #FFFFFF;
    for (int y = 0; y < h; y++) {
      color cur = output.get(x,y);
      if ( cc(cur,#FFFFFF) ) { cur_marker = #FFFFFF; }
      else if ( !cc(cur,cur_marker) && !is_marker_present_down(cur_marker, x, y, vpass_window) ) { cur_marker = cur;}
      output.set(x,y,cur_marker);
    }
  } 
}

//============================//
//                            //
//     HELPER FUNCTIONS       //
//                            //
//============================//


// compare colors function
// returns true iff the r, g and b valuess of colorrs c1 and c2 are equal
boolean cc(color c1, color c2) {
  if (red(c1) != red(c2)) return false;
  if (blue(c1) != blue(c2)) return false;
  if (green(c1) != green(c2)) return false;
  return true;
}

// color m: color to check for
// x, y: starting position
// n: number of neighbors to check to the right of x,y
boolean is_marker_present(color m, int x, int y, int n) {
  for (int i = 1; i < n + 1; i++) {
    color c = input.get(x+i, y);
    if ( cc(c, m) || cc(c, #FFFFFF) || x+i >= w) { return true; }
  }
  return false;
}
boolean is_marker_present_down(color m, int x, int y, int n) {
  for (int i = 1; i < n + 1; i++) {
    color c = output.get(x, y+i);
    if ( cc(c, m) || cc(c, #FFFFFF) || y+i >= h) { return true; }
  }
  return false;
}


//============================//
//                            //
//     INPUT AND OUTPUT       //
//                            //
//============================//


void keyReleased() {
  if (key == 's') {
     savePNG();
  }
}

// automatic name generation, including palette and iteration number
void savePNG() {
    // loop to choose unique file name
    int i = 0;
    File new_comp;
    do {
      i++;
      new_comp = new File(sketchPath() + "/patches/" + i + ".png");
      println(sketchPath() + "/patches/" + i + ".png exists?" + new_comp.exists());
    } while (new_comp.exists());
    
    output.save(sketchPath() + "/patches/" + i + ".png"); 
}


//============================//
//                            //
//          DRAWING           //
//                            //
//============================//
