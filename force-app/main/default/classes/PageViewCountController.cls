/* Following Apex Class return the number of page views by segregating between record pages and generic pages.The class creates Custom 
Big Object Tracking_Page_View__b records which gives us the number of views of a page
Class Created By:
Gokul Pillai
Sourabh Rajapure
Nakul Punse*/
public with sharing class PageViewCountController {

    @AuraEnabled
    public static Decimal viewCount(Id recordId, String URl){
        
       	List<SObject> recordsList;

        // get object name
        String objectName = recordId.getSobjectType().getDescribe().getName();
        
        String query = 'SELECT Id, Name, Page_Views__c FROM ' + objectName + ' WHERE ID =: recordId';
        recordsList = Database.query(query);
        System.debug('Query: ' + recordsList);
        
        // get record name
        String recordName = (String)Database.query(query)[0].get('Name');
        System.debug('Record Name ' + recordName);
        
        // get record page views
        Decimal pageviews = (Decimal)Database.query(query)[0].get('Page_Views__c');
        System.debug('Page View ' + pageviews);

        // get day of the week from Date 
        DateTime currentDateTime = DateTime.Now();
        String dayOfTheWeek = currentDateTime.format('EEEE');

        // creating track page records
        if (URL.contains('vermonttestcommunity')){
                System.debug('Inside Condition');

                Tracking_Page_View__b tp = new Tracking_Page_View__b (Record_Page_Viewed_Time__c = DateTime.now(), User__c = UserInfo.getUserId(), Object__c = objectName,
                Record_Name__c = recordName, Record_Id__c = recordId, Type__c = 'Community', Page_URL__c = URl, Page_Name__c = objectName + ' Community Record Page',
                Day_of_the_Week__c = dayOfTheWeek);                
                Database.insertImmediate(tp);
        }

        else {  
                Tracking_Page_View__b tp = new Tracking_Page_View__b (Record_Page_Viewed_Time__c = DateTime.now(), User__c = UserInfo.getUserId(), Object__c = objectName,
                Record_Name__c = recordName, Record_Id__c = recordId, Type__c = 'Salesforce', Page_Name__c = objectName + ' Record Page', 
                Day_of_the_Week__c = dayOfTheWeek);
                Database.insertImmediate(tp);
        }

        if(pageviews == null){
            pageviews = 0;
        }

        //incrementing the page view count
        pageviews = pageviews + 1;
        System.debug('Page Views: '+ pageviews);
    
        List<SObject> objectlist = new List<SObject>();
       
        //Iterating through the SObject records and assigning the page view count
        for(SObject obj: recordsList){
           if(!recordsList.isEmpty()) 
           obj.put('Page_Views__c', pageviews);
           System.debug(obj.get('Page_Views__c'));
           objectlist.add(obj);
       }
   	    update objectlist;
        
        //Querying the page view count and storing it in a variable
        String queryPageView = 'SELECT Id, Name, Page_Views__c FROM ' + objectName + ' WHERE ID =: recordId';
        Decimal recordPageViews = (Decimal)Database.query(queryPageView)[0].get('Page_Views__c');

        return recordPageViews;
    }


    @AuraEnabled
    public static Decimal GenericPageViewCount(String URL) {
        // get day of the week from Date 
        DateTime currentDateTime = DateTime.Now();
        String dayOfTheWeek = currentDateTime.format('EEEE');

        //Striping the page name from the URL
            Decimal pagecount; 
            String pageName = URL.substringAfter('/s/');
            System.debug('Page Name'+ pageName);
            if(pageName =='test-record-page'){
                 
                pageName = 'Test Page';
                //Creating Tracking Page Views Record
                Tracking_Page_View__b tp = new Tracking_Page_View__b(Record_Page_Viewed_Time__c = DateTime.now(),Page_Name__c = 'Test Page',
                                                                    Page_URL__c = URL,
                                                                      User__c = UserInfo.getUserId(),
                                                                      Day_of_the_Week__c = dayOfTheWeek, Type__c = 'Community'); 
                                
                Database.insertImmediate(tp);  
                
                //Updating the count using custom setting
                Generic_Pages_Count__c mc = Generic_Pages_Count__c.getValues('Generic Count');
                mc.Page_View__c = mc.Page_View__c + 1;
                pagecount = mc.Page_View__c;
                update mc;
                            
                }
            else if(pageName==''){
                pageName = 'Home Page';
                //Creating Tracking Page Views Record
                Tracking_Page_View__b tp = new Tracking_Page_View__b(Record_Page_Viewed_Time__c = DateTime.now(),Page_Name__c = 'Home Page',
                                                                    Page_URL__c = URL,User__c = UserInfo.getUserId(),
                                                                    Day_of_the_Week__c = dayOfTheWeek, Type__c = 'Community');                
                Database.insertImmediate(tp);
                
                //Updating the count using custom setting
                Generic_Pages_Count__c mc = Generic_Pages_Count__c.getValues('Generic Count');
                mc.Home_Page_View__c = mc.Home_Page_View__c + 1;
                pagecount = mc.Home_Page_View__c;
                update mc;
            }
    
            Decimal pageViewCount = pagecount;
            return pageViewCount;    
    }


}