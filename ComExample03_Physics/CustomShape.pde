// usually one would probably make a generic Shape class and subclass different types (circle, polygon), but that
// would mean at least 3 instead of 1 class, so for this tutorial it's a combi-class CustomShape for all types of shapes
// to save some space and keep the code as concise as possible I took a few shortcuts to prevent repeating the same code
import java.util.List;
import java.util.Arrays;

class CustomShape {
  // to hold the box2d body
  Body body;
  // to hold the Toxiclibs polygon shape
  Polygon2D toxiPoly;
  // custom color for each shape
  color col;
  // radius (also used to distinguish between circles and polygons in this combi-class
  float r;

  CustomShape(float x, float y, float r, BodyType type) {
    this.r = r;
    // create a body (polygon or circle based on the r)
    makeBody(x, y, type);
    // get a random color
    col = getRandomColor();
  }

  void makeBody(float x, float y, BodyType type) 
  {
    // define a dynamic body positioned at xy in box2d world coordinates,
    // create it and set the initial values for this box2d body's speed and angle
    BodyDef bd = new BodyDef();
    bd.type = type;
    bd.position.set(box2d.coordPixelsToWorld(new Vec2(x, y)));
    body = box2d.createBody(bd);
    body.setLinearVelocity(new Vec2(random(-8, 8), random(2, 8)));
    body.setAngularVelocity(random(-5, 5));

    // box2d polygon shape
    //PolygonShape sd = new PolygonShape();
    /* toxiPoly = new Polygon2D(Arrays.asList(new Vec2D(-r, r*1.5), 
     new Vec2D(r, r*1.5), 
     new Vec2D(r, -r*1.5), 
     new Vec2D(-r, -r*1.5)));*/

    if (r == -1) 
    {
      // box2d polygon shape
      PolygonShape sd = new PolygonShape();
      // toxiclibs polygon creator (triangle, square, etc)
      toxiPoly = new Circle(random(5, 20)).toPolygon2D(int(random(3, 6)));
      // place the toxiclibs polygon's vertices into a vec2d array
      Vec2[] vertices = new Vec2[toxiPoly.getNumPoints()];

      for (int i=0; i<vertices.length; i++) 
      {
        Vec2D v = toxiPoly.vertices.get(i);
        vertices[i] = box2d.vectorPixelsToWorld(new Vec2(v.x, v.y));
      }
      // put the vertices into the box2d shape
      sd.set(vertices, vertices.length);
      // create the fixture from the shape (deflect things based on the actual polygon shape)
      body.createFixture(sd, 1);
    }

    else 
    {
      // box2d circle shape of radius r
      CircleShape cs = new CircleShape();
      cs.m_radius = box2d.scalarPixelsToWorld(r);
      // tweak the circle's fixture def a little bit
      FixtureDef fd = new FixtureDef();
      fd.shape = cs;
      fd.density = 1;
      fd.friction = 0.01;
      fd.restitution = 0.3;
      // create the fixture from the shape's fixture def (deflect things based on the actual circle shape)
      body.createFixture(fd);
    }
  }




  // method to loosely move shapes outside a person's polygon
  // (alternatively you could allow or remove shapes inside a person's polygon)
  void update() 
  {
    // get the screen position from this shape (circle of polygon)
    Vec2 posScreen = box2d.getBodyPixelCoord(body);
    // turn it into a toxiclibs Vec2D
    Vec2D toxiScreen = new Vec2D(posScreen.x, posScreen.y);
    // check if this shape's position is inside the person's polygon
    boolean inBody = poly.containsPoint(toxiScreen);
    // if a shape is inside the person
    if (inBody) {
      // find the closest point on the polygon to the current position
      Vec2D closestPoint = toxiScreen;
      float closestDistance = 9999999;
      for (Vec2D v : poly.vertices) 
      {
        float distance = v.distanceTo(toxiScreen);
        if (distance < closestDistance) 
        {
          closestDistance = distance;
          closestPoint = v;
        }
      }
      // create a box2d position from the closest point on the polygon
      Vec2 contourPos = new Vec2(closestPoint.x, closestPoint.y);
      Vec2 posWorld = box2d.coordPixelsToWorld(contourPos);
      float angle = body.getAngle();
      // set the box2d body's position of this CustomShape to the new position (use the current angle)
      body.setTransform(posWorld, angle);
    }
  }

  // display the customShape
  void display() {
    // get the pixel coordinates of the body
    Vec2 pos = box2d.getBodyPixelCoord(body);
    pushMatrix();
    // translate to the position
    translate(pos.x, pos.y);
    noStroke();
    // use the shape's custom color
    fill(col);

    if (r == -1) {
      // rotate by the body's angle
      float a = body.getAngle();
      rotate(-a); // minus!
      gfx.polygon2D(toxiPoly);
    } 
    else {
      ellipse(0, 0, r*2, r*2);
    }

    popMatrix();
  }

  // if the shape moves off-screen, destroy the box2d body (important!)
  // and return true (which will lead to the removal of this CustomShape object)
  boolean done() {
    Vec2 posScreen = box2d.getBodyPixelCoord(body);
    boolean offscreen = posScreen.y > height;
    if (offscreen) {
      box2d.destroyBody(body);
      return true;
    }
    return false;
  }
}

