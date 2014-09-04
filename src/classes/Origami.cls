public class Origami {
        private Boolean is_test;
        private Map<String, String> unchunked_records;
        private List<SObject> chunked_records;
        private Set<String> legal_filters = new Set<String>{'WHERE', 'LIMIT', 'ORDER BY'};
        private List<String> ordered_filters = new List<String>{'WHERE', 'LIMIT', 'ORDER BY'};

	public Origami(Boolean is_test) {
            this.is_test = is_test;
	}

        /*********************************
                PUBLIC FUNCTIONS 

        **********************************/

        //Query for records with no filters
        public List<SObject> query(String obj, List<String> fields){
            String joined_fields = this.join(fields, ', ');
            String query =String.format('SELECT {0} FROM {1}', new List<String>{joined_fields, obj});
            try{
                List<SObject> result = Database.query(query);
                return result;
            } catch(Exception e){
                system.debug(query);
                system.debug(e);
                return null;
            }
        }

        //Query for records with filters
        public List<SObject> query(String obj, List<String> fields, Map<String, String> filters){
            String joined_fields = this.join(fields, ', ');
            String query =String.format('SELECT {0} FROM {1}', new List<String>{joined_fields, obj});
            query = apply_filters(filters, query);
            try{
                List<SObject> result = Database.query(query);
                return result;
            } catch(Exception e){
                system.debug(e);
                return null;
            }
        }

        //Get a single record
        public SObject get(String obj, List<String> fields, Map<String, String> filters){
            filters.put('Limit', '1');
            return this.query(obj, fields, filters)[0];
        }

        /*********************************
                PRIVATE FUNCTIONS 

        **********************************/

        private String apply_filters(Map<String, String> filters, String query){
            for(String f : filters.keySet()){
                if(!legal_filters.contains(f.toUpperCase())){
                    throw new OrigamiExceptions.IllegalFilterException(f + ' is an not a valid filter');
                }
            }

            for(String f : ordered_filters){
                if(filters.containsKey(f)){
                    query+=f + filters.get(f);
                }
            }

            return query;
        }

        private String join(List<String> target,String delimiter){
            String result = '';
            for(String s : target){
                result += s + delimiter;
            }

            return result.removeEnd(delimiter);
        }
}
