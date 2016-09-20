public static class CoordinateSystem {

    protected static PVector toCartesian(float R, float angle) {
        return new PVector(R * cos(angle), R * sin(angle));
    }
    
    protected static PVector toPolar(PVector point) {
        float R = point.mag();
        return new PVector(R, atan2(point.y, point.x));
    }
    
    protected static PVector toPolarUnsigned(PVector point) {
        PVector polarPoint = toPolar(point);
        polarPoint.y = (polarPoint.y + TWO_PI) % TWO_PI;
        return polarPoint;
    }
    
}