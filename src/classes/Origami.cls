public class Origami {
        public List<SObject> created_records;

        private Boolean is_test;

        //chunked/unchunkled collections for dml flushing functionality
        private Map<String, List<SObject>> unchunked_records_create;
        private List<SObject> chunked_records_create;

        private Set<String> legal_filters = new Set<String>{'WHERE', 'LIMIT', 'ORDER BY'};
        private List<String> ordered_filters = new List<String>{'WHERE', 'LIMIT', 'ORDER BY'};

	public Origami(Boolean is_test) {
            this.is_test = is_test;
            this.unchunked_records_create = new Map<String, List<SObject>>();
            this.chunked_records_create = new List<SObject>();

            this.created_records = new List<SObject>();
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

        public SObject create(String obj, Map<String, Object> fields){
            Schema.SObjectType new_type = Schema.getGlobalDescribe().get(obj);
            SObject new_rec = (SObject)new_type.newSObject();
            
            for(String fn : fields.keySet()){
                new_rec.put(fn, fields.get(fn));
            }

            if(!this.unchunked_records_create.containsKey(obj)){
                this.unchunked_records_create.put(obj, new List<Sobject>());
            }

            this.unchunked_records_create.get(obj).add(new_rec);

            return new_rec;
        }

        public Map<String, List<SObject>> flush(){
            Map<String, List<SObject>> results = new Map<String, List<SObject>>{'created' => new List<SObject>(), 'updated' => new List<SObject>()};
            Integer x = 0;

            for(String type : this.unchunked_records_create.keySet()){
                if(x==10){
                    results.get('created').addAll(this.chunked_records_create);
                    insert this.chunked_records_create;
                    this.chunked_records_create.clear();
                    x = 0;
                }

                this.chunked_records_create.addAll(this.unchunked_records_create.get(type));
                this.unchunked_records_create.remove(type);
                x++;

                if(this.unchunked_records_create.size() ==  0){
                    insert this.chunked_records_create;
                    results.get('created').addAll(this.chunked_records_create);
                    this.chunked_records_create.clear();
                    x = 0;
                }
            }

            return results;
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
