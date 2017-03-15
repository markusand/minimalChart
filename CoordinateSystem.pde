/**
* Changes between coordinate systems, from certesian to polar and viceversa
* @author    Marc Vilella
*/
public static class CoordinateSystem {

    /**
    * Convert polar coordinate point to a cartesian coordinate point. Polar point is defined by a radius and
    * an angle, while cartesian point is defined by horizontal and vertical positions
    * @param R        the polar radius
    * @param angle    the polar angle in radians
    * @return         the cartesian coordinates
    */
    protected static PVector toCartesian(float R, float angle) {
        return new PVector(R * cos(angle), R * sin(angle));
    }
    
    
    /**
    * Convert cartesian coordinate point to a polar coordinate point. Cartesian point is defined by horizontal
    * and vertical positions, while polar point is defined by a radius and an angle. Polar angle is returned in
    * radians from -PI to PI
    * @param point    the cartesian coordinates
    * @return         the polar coordinates
    */
    protected static PVector toPolar(PVector point) {
        return new PVector(point.mag(), atan2(point.y, point.x));
    }
    
    
    /**
    * Convert cartesian coordinate point to a polar coordinate point. Cartesian point is defined by horizontal
    * and vertical positions, while polar point is defined by a radius and an angle. Polar angle is returned in
    * radians from 0 to TWO_PI
    * @param point    the cartesian coordinates
    * @return         the polar coordinates
    */
    protected static PVector toPolarUnsigned(PVector point) {
        return new PVector(point.mag(), (atan2(point.y, point.x) + TWO_PI) % TWO_PI );
    }
    
}