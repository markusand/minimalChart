public static class CoordinateSystem {

    protected static PVector toCartesian(float R, float angle) {
        return new PVector(R * cos(angle), R * sin(angle));
    }
    
    protected static PVector toPolar(PVector point) {
        return new PVector(point.mag(), atan2(point.y, point.x));
    }
    
    protected static PVector toPolarUnsigned(PVector point) {
        return new PVector(point.mag(), (atan2(point.y, point.x) + TWO_PI) % TWO_PI );
    }
    
}