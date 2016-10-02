private class Tooltip {
    
    private PVector pos;
    private String label;
    private color tint;
    
    
    Tooltip(ArrayList<Tooltip> tooltips, PVector pos, String label, color tint) {
        this.pos = pos.copy().sub(0, 14);
        this.label = label;
        this.tint = tint;
        for(Tooltip t : tooltips) {
            // Tooltips horizontal overlap
            if( abs( t.pos.x - this.pos.x ) < ( textWidth(this.label)) / 2 + ( textWidth(t.label) ) / 2 ) {  
                float dY = t.pos.y - this.pos.y;
                // Tooltips vertical overlap
                if( dY > -20 && dY < 20 ) this.pos.y -= ( dY == 0 ) ? 20 : Math.signum(dY) * ( 20 - abs(dY) + 1 );
            }
        }
    }
    
    
    public void draw() {
        fill(tint); noStroke(); rectMode(CENTER);
        rect(pos.x, pos.y, textWidth(label) + 10, 20, 3);
        fill(#FFFFFF); textAlign(CENTER, CENTER); textSize(9);
        text(label, pos.x, pos.y - 2);
    }
    
    
}