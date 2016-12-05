defmodule PingalServer.Elasticsearch do
    use Tirexs.Mapping
    import Tirexs.HTTP 
    import Tirexs.Bulk  
    import Tirexs.Search  
    import Tirexs.Percolator

    def map_thought do

        query = ~S(
            { 
             "settings": { 
                 "analysis": { 
                    tokenizer: {
                        thought_tokenizer: {
                            type: 'whitespace'
                        },
                     },
                     "filter": { 
                         "edge_ngram": { 
                             "type": "edgeNGram", 
                             "min_gram": 1, 
                             "max_gram": 15 
                            } 
                        }, 
                        "analyzer": { 
                            "autocomplete_analyzer": { 
                                "filter": [ "lowercase", "asciifolding", "edge_ngram" ], 
                                "tokenizer": "whitespace" 
                            },
                            shingle_analyzer: {
                                filter:    ['shingle', 'lowercase', 'asciifolding'],
                                tokenizer: 'whitespace'
                                
                            }, 
                        } 
                    }, 
                    "index": [] 
                }, 
                "mappings": { 
                    "thought": { 
                        "dynamic": "false", 
                        "properties": { 
                            "thought": { 
                                "type": "text", 
                                "fields": {
                                    "raw": { 
                                        "type":  "string",
                                        "index": "not_analyzed"
                                    },
                                    "autocomplete": { 
                                        "type": "string", 
                                        "analyzer": "autocomplete_analyzer" 
                                    },
                                    "english": { 
                                        "type":     "text",
                                        "analyzer": "english"
                                    }
                                } 
                            }, 
                            "category": { 
                                "type": "string",
                                "fields": {
                                    "raw": { 
                                        "type":  "string",
                                        "index": "not_analyzed"
                                    }
                                }  
                            }, 
                            "channel": { 
                                "type": "string",
                                "fields": {
                                    "raw": { 
                                        "type":  "string",
                                        "index": "not_analyzed"
                                    }
                                } 
                            }, 
                            "user_id": { 
                                "type": "string",
                                "fields": {
                                    "raw": { 
                                        "type":  "keyword"
                                    }
                                }  
                            }, 
                            "created_at": { "type": "date", format: "strict_date_optional_time||epoch_millis"}, 
                            "geom": { "type": "geo_point" }
                        } 
                    } 
                } 
            }
        ) 
        uri = "http://127.0.0.1:9200/thoughts"
        { :ok, 200, resp } = HTTP.post(uri <> "/_mappings", query)
        #     curl -X PUT -d query uri

        ############### Using Tirexs Macros #############
        # index = [index: "thoughts", type: "thought"]
        
        # settings do
        #    analysis do
        #        analyzer "autocomplete_analyzer",
        #        [
        #            filter: ["lowercase", "asciifolding", "edge_ngram"],
        #            tokenizer: "whitespace"
        #        ]
        ##        filter "edge_ngram", 
        #                [type: "edge_ngram", min_gram: 1, max_gram: 15]
        #    end
        # end

        # mappings dynamic: "false" do
        #    indexes "thought", type: "string", 
            #indexes "thought", type: "string", analyzer: "autocomplete_analyzer"
        #    indexes "category", type: "string"
        #    indexes "channel", type: "string"
        #    indexes "user_id", type: "string"
            #indexes "user_id", type: "string", index: "not_analyzed"
        #    indexes "created_at", type: "date", format: "strict_date_optional_time||epoch_millis"
        #    indexes "geom", type: "geo_point"
        # end

        # create_resource(index)
        ##################################

        # index

    end


    def bulk() do
        payload = ~S(
            { "index": { "_index": "thoughts", "_type": "thought", "_id": "1"}}
            { "title" : "My first thought"}
        )
        { :ok, 200, r } = HTTP.post("/_bulk", payload)
        # { :ok, 200, r } = Resources.bump(payload)._bulk({ [refresh: true] })
        # { :ok, 200, r } = Resources.bump(payload)._bulk()
        
        # payload = bulk do
        #    index [ index: "bear_test", type: "blog" ], [
        #        [id: 1, title: "My second blog post"]
                 # ...
        #    ]

            # update [ index: "bear_test", type: "blog"], [
            #   [
            #     doc: [id: 1, _retry_on_conflict: 3, title: "[updated] My first blog post"],
            #     fields: ["_source"],
            #   ]
            # ]
        # end

        # Tirexs.bump!(payload)._bulk()
            
    end

    def search(thought) do
        ############# debugging ###########
        # url  = Tirexs.HTTP.url("index/_search/")
        # json = HTTP.encode(query)
        # IO.puts "curl -X GET -d #{json} #{url}"
        ########### curl ##############  
        query = ~S'''
            {
                "query": {
                    "nested": {
                        "query": {
                            "bool": {
                                "must": [
                                    { "match": {
                                            "comments.author": {
                                                "query": "John"
                                            }
                                        }
                                    },
                                    { "match": {
                                        "comments.message": {
                                            "query": "cool"
                                            }
                                        }
                                    }
                                ]
                            }
                        },
                        "path": "comments"
                    }
                }
            }
        '''
       #    curl -X POST -d query http://127.0.0.1:9200/thoughts/_search
        { :ok, 200, r } = HTTP.post("/_search", payload)
         
    
       # find = search [index: "bear_test"] do
       #         query do
       #             nested [path: "comments"] do
       #                 query do
       #                     bool do
       #                         must do
       #                             match "comments.author",  "John"
       #                             match "comments.message", "cool"
       #                         end
       #                     end
       #                 end
       #             end
       #         end
       #     end

       # Tirexs.Query.create_resource(find)
    end


    def percolator() do    
        query = ~S({ "query": { "match": { "title": "blog" } } })
        uri = "http://127.0.0.1:9200/test/.percolator/1"        

        ############# debugging ###########
        #  curl -X PUT -d query uri
        # url  = Tirexs.HTTP.url("test/.percolator/1")
        # json = JSX.prettify!(JSX.encode!(Tirexs.Percolator.to_resource_json(query)))
        # IO.puts "\n# => curl -X PUT -d '#{json}' #{url}"
        ########### curl ##############
    

        query = percolator [index: bear_test, name: "1"] do
            query do
                term "field1", "value1"
            end
        end
        [percolator: query]
            
    end

    
    result = Tirexs.Query.create_resource(find_thought, settings)  
    IO.puts inspect result

end