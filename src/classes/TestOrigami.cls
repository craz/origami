@isTest
public class TestOrigami {

        /*********************************************************

            I strive to use mainly standard, low level and "manual" ways
            of setting up tests, as a lot of the dynamic and factory type
            behavior is at the heart of the origami module we are testing,
            and I prefer to seperate the two

        ***********************************************************/

    public static  testMethod void test_origami_unfiltered_query_std() {
        /* 
            Test a successful unfiltered query with a standard object 
        */ 

        Origami ori = new Origami(False);

        List<Account> accts = new List<Account>();
        for(Integer i=0; i<=5;i++){
            accts.add(new Account(Name='test' + i));
        }

        insert accts;

        String obj = 'Account';
        List<String> fields = new List<String>{'Name', 'Id'};

        List<Account> result = (List<Account>)ori.query(obj, fields);

        system.assertEquals(result.size(), 6);
    }

    public static testMethod void test_filtered_query_success_std() {
        /* 
            test a successful filtered query with a standard object 
        */

        Origami ori = new Origami(False);
        
        List<Account> accts = new List<Account>();
        for(Integer i=0; i<=5;i++){
            accts.add(new Account(Name='test'));
        }

        insert accts;

        String obj = 'Account';
        List<String> fields = new List<String>{'Name', 'Id', 'CreatedDate'};
        Map<String, String> filters = new Map<String, String>{'WHERE' => 'Name = "test"', 'ORDER BY' => 'CreatedDate',  'LIMIT' => '5'};

        List<Account> result = (List<Account>)ori.query(obj, fields, filters);

        system.assertEquals(result.size(), 5);

        for(Account a : result){
            system.assertEquals(a.Name, 'test');
        }
    }

    public static testMethod void test_filtered_query_illegal_filter() {
        /* 
            Test that a filter with an illegal keyword throws an IllegalFilterException
        */

        Origami ori = new Origami(False);
        
        List<Account> accts = new List<Account>();
        for(Integer i=0; i<=5;i++){
            accts.add(new Account(Name='test'));
        }

        insert accts;

        String obj = 'Account';
        List<String> fields = new List<String>{'Name', 'Id', 'CreatedDate'};
        Map<String, String> filters = new Map<String, String>{'WHERE' => 'Name = "test"', 'ORDERBY' => 'CreatedDate',  'LIMIT' => '5'};

        try{
            List<Account> result = (List<Account>)ori.query(obj, fields, filters);
        } catch(Exception e){
            system.assertEquals(e.getTypeName(), 'OrigamiExceptions.IllegalFilterException');
        }
    }

    public static testMethod void test_query_invalid_select_field_failure(){
        /*
            test an unsuccessful query caused by an invalid select field
        */

        Origami ori = new Origami(False);
        
        List<Account> accts = new List<Account>();
        for(Integer i=0; i<=5;i++){
            accts.add(new Account(Name='test'));
        }

        insert accts;

        String obj = 'Account';
        List<String> fields = new List<String>{'Name', 'Id', 'Bad_Field__c'};

        List<Account> result = (List<Account>)ori.query(obj, fields);

        system.assertEquals(result, null);

    }

    public static testMethod void test_query_invalid_from_object_failure(){
        /*
            test an unsuccessful query caused by an invalid from object 
        */

        Origami ori = new Origami(False);
        
        List<Account> accts = new List<Account>();
        for(Integer i=0; i<=5;i++){
            accts.add(new Account(Name='test'));
        }

        insert accts;

        String obj = 'FakeObject';
        List<String> fields = new List<String>{'Name', 'Id'};

        List<Account> result = (List<Account>)ori.query(obj, fields);

        system.assertEquals(result, null);
    }

    public static testMethod void test_get_unfiltered_success(){
        /* 
            test a successful get unfiltered
        */

        Origami ori = new Origami(False);

        List<Account> accts = new List<Account>();
        for(Integer i=0; i<=5;i++){
            accts.add(new Account(Name='test' + i));
        }

        insert accts;

        String obj = 'Account';
        List<String> fields = new List<String>{'Name', 'Id'};

        Account a = (Account)ori.get(obj, fields);
    }

    public static testMethod void test_get_filtered_success(){
        /* 
            test a successful get filtered
        */

        Origami ori = new Origami(False);

        List<Account> accts = new List<Account>();
        for(Integer i=0; i<=5;i++){
            accts.add(new Account(Name='test' + i));
        }

        insert accts;

        String obj = 'Account';
        List<String> fields = new List<String>{'Name', 'Id'};
        Map<String, String> filters = new Map<String, String>{'WHERE' => 'Name = "test1"'};

        Account a = (Account)ori.get(obj, fields, filters);

        system.assertEquals(a.Name, 'test1');
    }

    public static testMethod void test_create_single_record_success(){
        /*
            test a successful create and flush
        */

        Origami ori = new Origami(False);

        String obj = 'Account';
        Map<String, Object> fields = new Map<String, Object>{'Name' => 'test', 'AnnualRevenue' => 123.23};

        Account a = (Account)ori.create(obj, fields);

        system.assertEquals(a.Name, 'test');
        system.assertEquals(a.AnnualRevenue, 123.23);
        system.assertEquals(a.Id, null); //assert that the record was not inserted

        ori.flush();

        a = [SELECT Name, AnnualRevenue FROM Account LIMIT 1];

        system.assertEquals(a.Name, 'test');
        system.assertEquals(a.AnnualRevenue, 123.23);
    }

    public static testMethod void test_bulk_create_single_type_success(){
        /*
            test successful create and flush with bulk one object type
        */


        Origami ori = new Origami(False);

        for(Integer i=0; i<=5;i++){
            String obj = 'Account';
            Map<String, Object> fields = new Map<String, Object>{'Name' => 'test' + i};

            Account a = (Account)ori.create(obj, fields);        
        }

        ori.flush();

        List<Account> accts = [SELECT Id FROM Account];
        system.assertEquals(6, accts.size());
    }

}
