public class Lines extends Chart {
    
    Lines(int x, int y, int width, int height) {
        super(x, y, width, height);
    }
    
    protected void drawSet(FloatList stack, Set set) {
        PVector prevPos = null;
        for(int i = 0; i < set.size(); i++) {
            Datum d = set.get(i);
            Float stackValue = stack.size() > 0 ? stack.get(i) : minY.getY();
            PVector pos = new PVector(
                map(d.getX(), minX.getX(), maxX.getX(), 0, size.x),
                map(stackValue + d.getY(), minY.getY(), maxY.getY(), size.y, 0)
            );
            
            if(prevPos != null) {
                stroke(set.getColor()); strokeWeight(1);
                line(prevPos.x, prevPos.y, pos.x, pos.y);
            }
            fill(set.getColor()); noStroke();
            ellipse(pos.x, pos.y, 5, 5);
            prevPos = pos;
        }
    }
    
}



public class Area extends Chart {
    
    Area(int x, int y, int width, int height) {
        super(x, y, width, height);
    }
    
    protected void drawSet(FloatList stack, Set set) {
        PVector prevPos = null;
        for(Datum d : set.getAll()) {
            PVector pos = new PVector(
                map(d.getX(), minX.getX(), maxX.getX(), 0, size.x),
                map(d.getY(), minY.getY(), maxY.getY(), size.y, 0)
            );
            if(prevPos != null) {
                beginShape();
                    fill(set.getColor(), 100); noStroke();
                    vertex(prevPos.x, size.y);
                    vertex(prevPos.x, prevPos.y);
                    vertex(pos.x, pos.y);
                    vertex(pos.x, size.y);
                endShape(CLOSE);
                noFill(); stroke(set.getColor()); strokeWeight(1);
                line(prevPos.x, prevPos.y, pos.x, pos.y);
            }
            prevPos = pos;
        }
    }
    
}