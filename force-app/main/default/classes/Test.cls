public class Test {
    public static void testMethod1() {
        String objectType = 'Account';
        List<sObject> data = new List<sObject>();
        
        Type t = Type.forName('Schema.' + objectType);
        if (t != null) {
            SObject obj;
            for (Integer i = 0; i < 5; i++) {
                obj = (SObject)t.newInstance();
                obj.put('Name', 'csdcsdcs');
                data.add(obj);
            }
        }
        System.debug('data: ' + data);
        insert data;
        // You can now work with the list of dynamically created objects
        // ...
    }
}