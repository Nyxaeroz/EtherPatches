PImage input;
PImage output;

// THESE SHOULD MATCH THE DIMENSIONS OF THE CANVAS
// MAKE SURE ITS LARGE ENOUGH FOR THE IMAGE YOU'RE PATCHING
int w = 1000;
int h = 2000;

// parameters that set the sizes of the windows that check if we're still in the same blob
// adjust these if your results are unsatisfactory (I've had good results with h=5 and v=20 or h=20 and v=20)
int hpass_window = 5;
int vpass_window = 20;

void setup() {
  // SIZE OF THE CANVAS -- IT SHOULD MATCH w AND h
  size(4000,2000);
  
  // LOAD YOUR IMAGE HERE
  input = loadImage("example.png");
  image(input, 0, 0);
  w = input.width;
  h = input.height;
  print("input image width: " + w + " input image height: " + h + "\n");
  output = createImage(w,h,RGB);

  // THIS IS WHERE THE MAGIC HAPPENS
  clear_text(w,0);
 
  // instead, of the vertical pass, you could use the rectangle placement below to leave some interesting black artefacts
  //clear_text_with_rects();

}


//============================//
//                            //
//  MAIN CLEARING FUNCTIONS   //
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
      color cur = get(x,y);
      if ( cc(cur,#FFFFFF) ) { cur_marker = #FFFFFF; }
      else if ( !cc(cur,cur_marker) && !is_marker_present(cur_marker, x, y, hpass_window) ) { cur_marker = cur; }
      set(x+x_off,y+y_off,cur_marker);
      output.set(x,y,cur_marker);
    }
  }
  
  // vertical pass over the colored blobs (over output of horizontal pass)
  for (int x = 0; x < w; x++ ) {
    color cur_marker = #FFFFFF;
    for (int y = 0; y < h; y++) {
      color cur = get(x+x_off,y);
      if ( cc(cur,#FFFFFF) ) { cur_marker = #FFFFFF; }
      else if ( !cc(cur,cur_marker) && !is_marker_present_down(cur_marker, w+x, y, vpass_window) ) { cur_marker = cur;}
      set(x+x_off,y+y_off,cur_marker);
      output.set(x,y,cur_marker);
    }
  }
  
  
}


void clear_text_with_rects() {
  noStroke();
  int rec_size = 15;
  for (int y = 0; y < h; y+=rec_size) {
    for (int x = 0; x < w; x+=rec_size ) {
      color cur = get(w+x,y);
        if (brightness(cur) < 254 && cur != #000000) {    
          fill(cur);
          rect(w+x,y,rec_size,rec_size);
      }
    }
  }
  rec_size = 5;
  for (int y = 0; y < h; y+=rec_size) {
    for (int x = 0; x < w; x+=rec_size ) {
      color cur = get(w+x,y);
        if (brightness(cur) < 254 && cur != #000000) {    
          fill(cur);
          rect(w+x,y,rec_size,rec_size);
      }
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
    color c = get(x+i, y);
    if ( cc(c, m) || cc(c, #FFFFFF) || x+i >= w) { return true; }
  }
  return false;
}
boolean is_marker_present_down(color m, int x, int y, int n) {
  for (int i = 1; i < n + 1; i++) {
    color c = get(x, y+i);
    if ( cc(c, m) || cc(c, #FFFFFF) || y+i >= h) { return true; }
  }
  return false;
}

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


void draw() {
  //image(img, 0, 0);
}
