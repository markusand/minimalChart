/**
* Represent a set of datums, with information of the minimum and maximum values
* @author       Marc Vilella
*/
public class DataSet {

    public final String NAME;
    public final String UNITS;
    public final color COLOR;
    
    private ArrayList<Datum> data = new ArrayList();
    private HashMap<Integer, String> labels = new HashMap();
    private Datum minX = null;
    private Datum maxX = null;
    private Datum minY = null;
    private Datum maxY = null;
    
    
    /**
    * Create a dataset
    * @param name    the name of dataset
    * @param unit    the unit of dataset 
    * @param tint    the color of dataset
    */
    DataSet(String name, String units, color tint) {
        NAME = name;
        UNITS = units;
        COLOR = tint;
    }
    
    
    /**
    * Check whether set is empty
    * @return    true if set is empty, false if contains any datum
    */
    public boolean isEmpty() {
        return size() == 0;
    }
    
    
    /**
    * Add new value(s) to dataset, and update min/max boundaries
    * @param values    the value(s)
    */
    public void add(Datum... newData) {
        for(Datum d : newData) {
            data.add(d);
            
            if( minY == null || d.y < minY.y ) minY = d;
            if( maxY == null || d.y > maxY.y ) maxY = d;
            if( minX == null || d.x < minX.x ) minX = d;
            if( maxX == null || d.x > maxX.x ) maxX = d;
            
            if( !labels.containsKey(d.x) ) labels.put(d.x, d.LABEL);
            else if( !labels.get(d.x).equals(d.LABEL) ) labels.put(d.x, labels.get(d.x) + "\n" + d.LABEL );
        }
    }
    
    
    /**
    * Get the Datum in set with minimum y value
    * @return    the minimum datum
    */
    public Datum min() {
        return minY;
    }
    
    
    /**
    * Get the Datum in set with maximum y value
    * @return    the maximum datum
    */
    public Datum max() {
        return maxY;
    }
    
    
    /**
    * Get the first Datum that has a specific x value
    * @param x    the x value
    * @return     the datum, or null if no datum contains x value
    */
    public Datum getData(int x) {
        for(Datum d : data) {
            if( d.x == x ) return d;
        }
        return null;
    }
    
    
    /**
    * Get the datum in specified position 
    * @param i    the index position in dataset
    * @return     the datum in i position, null if index is out of bounds
    */
    public Datum get(int i) {
        if( i >= 0 && i < size() ) return data.get(i);
        return null;
    }
    
    
    /**
    * Get all the datums in dataset 
    * @return    the datums list
    */
    public ArrayList<Datum> data() {
        return data;
    }
    
    
    /**
    * Get first datum (the one with minimum x value) in dataset
    * @return    the first datum
    */
    public Datum first() {
        return minX;
    }
    
    
   /**
    * Get last datum (the one with maximum x value) in dataset
    * @return    the last datum
    */
    public Datum last() {
        return maxX;
    }
    
    
    /**
    * Get the number of datums in dataset
    * @return    the number of datums in set
    */
    public int size() {
        return data.size();
    }
    
    
    /*
    * Clear dataset
    */
    public void clear() {
        data = new ArrayList();
        minX = maxX = minY = maxY = null;
    }
    
    
    /**
    * Get all the labels in dataset
    * return    the labels
    */
    public HashMap<Integer, String> getLabels() {
        return labels;
    }
    
}