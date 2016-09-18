public class Set {

    private String name;
    private String unit;
    private color tint;
    
    private ArrayList<Datum> data = new ArrayList();
    private Datum minX = null;
    private Datum maxX = null;
    private Datum minY = null;
    private Datum maxY = null;
    
    
    /*
    * Constructor for dataset
    * @param name Name of dataset
    * @param unit Unit for all values in dataset
    * @param tint Color of dataset
    */
    Set(String name, String units, color tint) {
        this.name = name;
        this.unit = units;
        this.tint = tint;
    }
    
    
    /*
    * Check is set is empty
    * @return true if set is empty, false if contains any datum
    */
    public boolean isEmpty() {
        return size() == 0;
    }
    
    /*
    * Add new value in dataset, and update min/max boundaries
    * @param values Value(s) to add in dataset
    */
    public void add(Datum... newData) {
        for(Datum d : newData) {
            this.data.add(d);
            if( minY == null || d.getY() < minY.getY() ) minY = d;
            if( maxY == null || d.getY() > maxY.getY() ) maxY = d;
            if( minX == null || d.getX() < minX.getX() ) minX = d;
            if( maxX == null || d.getX() > maxX.getX() ) maxX = d;
        }
    }
    
    
    /*
    * Get minimum Datum in set
    * @return value from dataset in index, or 0 if index is outside
    */
    public Datum getMin() {
        return minY;
    }
    
    
    /*
    * Get value from dataset
    * @param i Index of value to get
    * @return value from dataset in index, or 0 if index is outside
    */
    public Datum getMax() {
        return maxY;
    }
    
    
    /*
    * Get the first datum from dataset in x value
    * @param x value in x-index
    * @return datum from dataset in x value, or null if not datum existing
    */
    public Datum getData(int x) {
        for(Datum d : data) {
            if( d.getX() == x ) return d;
        }
        return null;
    }
    
    
    /*
    * Get the datum in i index 
    * @param i index
    * @return datum from dataset in i index, null if index out of bounds
    */
    public Datum get(int i) {
        if( i >= 0 && i < size() ) return data.get(i);
        return null;
    }
    
    /*
    * Get the datum in i index 
    * @param i index
    * @return datum from dataset in i index, null if index out of bounds
    */
    public ArrayList<Datum> getAll() {
        return data;
    }
    
    
    /*
    * Get first datum in dataset 
    * @return first datum
    */
    public Datum getFirst() {
        return minX;
    }
    
    
    /*
    * Get last datum in dataset 
    * @return last datum
    */
    public Datum getLast() {
        return maxX;
    }
    
    
    /*
    * Get the size of the dataset values array
    * @return size of dataset
    */
    public int size() {
        return data.size();
    }
    
    
    /*
    * Clear all set values to initial state
    */
    public void clear() {
        data = new ArrayList();
        minX = maxX = minY = maxY = null;
    }
    
    
    public color getColor() {
        return tint;
    }
    
}