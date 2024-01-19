class Box {

  PVector pos;
  float r;

  Box (float x, float y, float z, float r_) {
    pos = new PVector(x, y, z);
    r = r_;
  }

  ArrayList<Box> generate() {
    ArrayList<Box> boxes = new ArrayList<Box>();
    for (int x = -1; x <2; x++) {
      for (int y = -1; y <2; y++) {
        for (int z = -1; z <2; z++) {
          int sum = abs(x) + abs(y) + abs(z);
          float newR = r/3;
          if (sum > 1) {
            Box b = new Box(pos.x+x*newR, pos.y+y*newR, pos.z+z*newR, newR);
            boxes.add(b);
          }
        }
      }
    }
    return boxes;
  }

  void show() {
    pushMatrix();
    translate(pos.x*(sep*sepM), pos.y*(sep*sepM), pos.z*(sep*sepM));
    noFill();
    strokeWeight(2);
    if (iterations == 0) {
      stroke(255);
    } else {
      float rValue = map(pos.x, -boxWidth/2, boxWidth/2, 10, 255);
      float gValue = map(pos.y, -boxWidth/2, boxWidth/2, 10, 255);
      float bValue = map(pos.z, -boxWidth/2, boxWidth/2, 10, 255);
      stroke(rValue, gValue, bValue, 255);
    }
    box(r);
    popMatrix();
  }
}
