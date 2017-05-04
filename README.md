# SlicingDice Official Ruby Client (v1.0)
### Build Status: [![CircleCI](https://circleci.com/gh/SlicingDice/slicingdice-ruby.svg?style=svg)](https://circleci.com/gh/SlicingDice/slicingdice-ruby)

Official Ruby client for [SlicingDice](http://www.slicingdice.com/), Data Warehouse and Analytics Database as a Service.  

[SlicingDice](http://www.slicingdice.com/) is a serverless, API-based, easy-to-use and really cost-effective alternative to Amazon Redshift and Google BigQuery.

## Documentation

If you are new to SlicingDice, check our [quickstart guide](http://panel.slicingdice.com/docs/#quickstart-guide) and learn to use it in 15 minutes.

Please refer to the [SlicingDice official documentation](http://panel.slicingdice.com/docs/) for more information on [analytics databases](http://panel.slicingdice.com/docs/#analytics-concepts), [data modeling](http://panel.slicingdice.com/docs/#data-modeling), [indexing](http://panel.slicingdice.com/docs/#data-indexing), [querying](http://panel.slicingdice.com/docs/#data-querying), [limitations](http://panel.slicingdice.com/docs/#current-slicingdice-limitations) and [API details](http://panel.slicingdice.com/docs/#api-details).

## Tests and Examples

Whether you want to test the client installation or simply check more examples on how the client works, take a look at [tests and examples directory](tests_and_examples/).

## Installing

In order to install the Ruby client, you only need to use [`gem`](https://rubygems.org/).

```bash
$ curl -s https://packagecloud.io/install/repositories/slicingdice/clients/script.gem.sh | bash
$ gem install rbslicer
```

## Usage

The following code snippet is an example of how to add and query data
using the SlicingDice ruby client. We entry data informing
'user50@slicingdice.com' has age 22 and then query the database for all
users between 20 and 40 years old. If this is the first record ever entered
into the system, the answer should be a list whose only element is
'user50@slicingdice.com'.

```ruby
require 'rbslicer'

# Configure the client
client = SlicingDice.new(master_key: "API_KEY", uses_test_endpoint: true)

# Indexing data
index_data = {
    "user50@slicingdice.com" => {
        "age" => 22
    }
}
auto_create_fields = true
client.index(index_data, auto_create_fields)

# Querying data
query_data = {
    "query-name" => "users-between-20-and-40",
    "query" => [
        {
            "age" => {
                "range" => [
                    20,
                    40
                ]
            }
        }
    ]
}
puts client.count_entity(query_data)
```

## Reference

`SlicingDice` encapsulates logic for sending requests to the API. Its methods are thin layers around the [API endpoints](http://panel.slicingdice.com/docs/#api-details-api-endpoints), so their parameters and return values are JSON-like `Hash` objects with the same syntax as the [API endpoints](http://panel.slicingdice.com/docs/#api-details-api-endpoints)

### Attributes

* `keys (String)` - [API key](http://panel.slicingdice.com/docs/#api-details-api-connection-api-keys) to authenticate requests with the SlicingDice API.

### Constructor

`initialize(master_key: nil, custom_key: nil, read_key: nil, write_key: nil, timeout: 60, use_ssl: true, uses_test_endpoint: false)`
* `master_key (String)` - [API key](#api-details-api-connection-api-keys) to authenticate requests with the SlicingDice API.
* `custom_key (String)` - [API key](#api-details-api-connection-api-keys) to authenticate requests with the SlicingDice API.
* `read_key (String)` - [API key](#api-details-api-connection-api-keys) to authenticate requests with the SlicingDice API.
* `write_key (String)` - [API key](#api-details-api-connection-api-keys) to authenticate requests with the SlicingDice API.
* `use_ssl (Bool)` - Define if the requests verify SSL for HTTPS requests.
* `timeout (Fixnum)` - Amount of time, in seconds, to wait for results for each request.
* `uses_test_endpoint (Bool)` - If false the client will send requests to production end-point, otherwise to tests end-point.

### `get_projects()`
Get all created projects, both active and inactive ones. This method corresponds to a [GET request at /project](http://panel.slicingdice.com/docs/#api-details-api-endpoints-get-project).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY", uses_test_endpoint: false)

puts client.get_projects()
```

#### Output example

```json
{
    "active": [
        {
            "name": "Project 1",
            "description": "My first project",
            "data-expiration": 30,
            "created-at": "2016-04-05T10:20:30Z"
        }
    ],
    "inactive": [
        {
            "name": "Project 2",
            "description": "My second project",
            "data-expiration": 90,
            "created-at": "2016-04-05T10:20:30Z"
        }
    ]
}
```

### `get_fields()`
Get all created fields, both active and inactive ones. This method corresponds to a [GET request at /field](http://panel.slicingdice.com/docs/#api-details-api-endpoints-get-field).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY", uses_test_endpoint: false)
puts client.get_fields()
```

#### Output example

```json
{
    "active": [
        {
          "name": "Model",
          "api-name": "car-model",
          "description": "Car models from dealerships",
          "type": "string",
          "category": "general",
          "cardinality": "high",
          "storage": "latest-value"
        }
    ],
    "inactive": [
        {
          "name": "Year",
          "api-name": "car-year",
          "description": "Year of manufacture",
          "type": "integer",
          "category": "general",
          "storage": "latest-value"
        }
    ]
}
```

### `create_field(json_data)`
Create a new field. This method corresponds to a [POST request at /field](http://panel.slicingdice.com/docs/#api-details-api-endpoints-post-field).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY", uses_test_endpoint: false)
field = {
  "name" => "Year",
  "api-name" => "year",
  "type" => "integer",
  "description" => "Year of manufacturing",
  "storage" => "latest-value"
}
puts client.create_field(field)
```

#### Output example

```json
{
    "status": "success",
    "api-name": "year"
}
```

### `index(json_data)`
Index data to existing entities or create new entities, if necessary. This method corresponds to a [POST request at /index](http://panel.slicingdice.com/docs/#api-details-api-endpoints-post-index).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY", uses_test_endpoint: false)
index_data = {
  "user1@slicingdice.com" => {
    "car-model" => "Ford Ka",
    "year" => 2016
  },
  "user2@slicingdice.com" => {
    "car-model" => "Honda Fit",
    "year" => 2016
  },
  "user3@slicingdice.com" => {
    "car-model" => "Toyota Corolla",
    "year" => 2010,
    "test-drives" => [
      {
        "value" => "NY",
        "date" => "2016-08-17T13:23:47+00:00"
      }, {
        "value" => "NY",
        "date" => "2016-08-17T13:23:47+00:00"
      }, {
        "value" => "CA",
        "date" => "2016-04-05T10:20:30Z"
      }
    ]
  },
  "user4@slicingdice.com" => {
    "car-model" => "Ford Ka",
    "year" => 2005,
    "test-drives" => {
      "value" => "NY",
      "date" => "2016-08-17T13:23:47+00:00"
    }
  }
}
puts client.index(index_data)
```

#### Output example

```json
{
    "status": "success",
    "indexed-entities": 4,
    "indexed-fields": 10,
    "took": 0.023
}
```

### `exists_entity(ids)`
Verify which entities exist in a project given a list of entity IDs. This method corresponds to a [POST request at /query/exists/entity](http://panel.slicingdice.com/docs/#api-details-api-endpoints-post-query-exists-entity).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY", uses_test_endpoint: false)
ids = [
  "user1@slicingdice.com",
  "user2@slicingdice.com",
  "user3@slicingdice.com"
]
puts client.exists_entity(ids)
```

#### Output example

```json
{
    "status": "success",
    "exists": [
        "user1@slicingdice.com",
        "user2@slicingdice.com"
    ],
    "not-exists": [
        "user3@slicingdice.com"
    ],
    "took": 0.103
}
```

### `count_entity_total()`
Count the number of indexed entities. This method corresponds to a [GET request at /query/count/entity/total](http://panel.slicingdice.com/docs/#api-details-api-endpoints-get-query-count-entity-total).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY", uses_test_endpoint: false)
puts client.count_entity_total()
```

#### Output example

```json
{
    "status": "success",
    "result": {
        "total": 42
    },
    "took": 0.103
}
```

### `count_entity(json_data)`
Count the number of entities matching the given query. This method corresponds to a [POST request at /query/count/entity](http://panel.slicingdice.com/docs/#api-details-api-endpoints-post-query-count-entity).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY", uses_test_endpoint: false)
query = [
    {
        'query-name' => 'corolla-or-fit',
        'query' => [
            {
                'car-model' => {
                    'equals' => 'toyota corolla'
                }
            },
            'or',
            {
                'car-model' => {
                    'equals' => 'honda fit'
                }
            }
        ],
        'bypass-cache' => false
    },
    {
        'query-name' => 'ford-ka',
        'query' => [
            {
                'car-model' => {
                    'equals' => 'ford ka'
                }
            }
        ],
        'bypass-cache' => false
    }
]
print client.count_entity(query)
```

#### Output example

```json
{
   "result":{
      "ford-ka":2,
      "corolla-or-fit":2
   },
   "took":0.083,
   "status":"success"
}
```

### `count_event(json_data)`
Count the number of occurrences for time-series events matching the given query. This method corresponds to a [POST request at /query/count/event](http://panel.slicingdice.com/docs/#api-details-api-endpoints-post-query-count-event).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY", uses_test_endpoint: false)
query = [
    {
        'query-name' => 'test-drives-in-ny',
        'query' => [
            {
                'test-drives' => {
                    'equals' => 'NY',
                    'between' => [
                        '2016-08-16T00:00:00Z',
                        '2016-08-18T00:00:00Z'
                    ]
                }
            }
        ],
        'bypass-cache' => true
    },
    {
        'query-name' => 'test-drives-in-ca',
        'query' => [
            {
                'test-drives' => {
                    'equals' => 'CA',
                    'between' => [
                        '2016-04-04T00:00:00Z',
                        '2016-04-06T00:00:00Z'
                    ]
                }
            }
        ],
        'bypass-cache' => true
    }
]
puts client.count_event(query)
```

#### Output example

```json
{
   "result":{
      "test-drives-in-ny":3,
      "test-drives-in-ca":0
   },
   "took":0.063,
   "status":"success"
}
```

### `top_values(json_data)`
Return the top values for entities matching the given query. This method corresponds to a [POST request at /query/top_values](http://panel.slicingdice.com/docs/#api-details-api-endpoints-post-query-top-values).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY", uses_test_endpoint: false)
query = {
  "car-year" => {
    "year" => 2
  },
  "car models" => {
    "car-model" => 3
  }
}
puts client.top_values(query)
```

#### Output example

```json
{
   "result":{
      "car models":{
         "car-model":[
            {
               "quantity":2,
               "value":"ford ka"
            },
            {
               "quantity":1,
               "value":"honda fit"
            },
            {
               "quantity":1,
               "value":"toyota corolla"
            }
         ]
      },
      "car-year":{
         "year":[
            {
               "quantity":2,
               "value":"2016"
            },
            {
               "quantity":1,
               "value":"2010"
            }
         ]
      }
   },
   "took":0.034,
   "status":"success"
}
```

### `aggregation(json_data)`
Return the aggregation of all fields in the given query. This method corresponds to a [POST request at /query/aggregation](http://panel.slicingdice.com/docs/#api-details-api-endpoints-post-query-aggregation).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY", uses_test_endpoint: false)
query = {
  "query" => [
    {
      "year" => 2
    },
    {
      "car-model" => 2,
      "equals" => [
        "honda fit",
        "toyota corolla"
      ]
    }
  ]
}
puts client.aggregation(query)
```

#### Output example

```json
{
   "result":{
      "year":[
         {
            "quantity":2,
            "value":"2016",
            "car-model":[
               {
                  "quantity":1,
                  "value":"honda fit"
               }
            ]
         },
         {
            "quantity":1,
            "value":"2005"
         }
      ]
   },
   "took":0.079,
   "status":"success"
}
```

### `get_saved_queries()`
Get all saved queries. This method corresponds to a [GET request at /query/saved](http://panel.slicingdice.com/docs/#api-details-api-endpoints-get-query-saved).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY", uses_test_endpoint: false)
puts client.get_saved_queries()
```

#### Output example

```json
{
    "status": "success",
    "saved-queries": [
        {
            "name": "users-in-ny-or-from-ca",
            "type": "count/entity",
            "query": [
                {
                    "state": {
                        "equals": "NY"
                    }
                },
                "or",
                {
                    "state-origin": {
                        "equals": "CA"
                    }
                }
            ],
            "cache-period": 100
        }, {
            "name": "users-from-ca",
            "type": "count/entity",
            "query": [
                {
                    "state": {
                        "equals": "NY"
                    }
                }
            ],
            "cache-period": 60
        }
    ],
    "took": 0.103
}
```

### `create_saved_query(json_data)`
Create a saved query at SlicingDice. This method corresponds to a [POST request at /query/saved](http://panel.slicingdice.com/docs/#api-details-api-endpoints-post-query-saved).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY", uses_test_endpoint: false)
query = {
  "name" => "my-saved-query",
  "type" => "count/entity",
  "query" => [
    {
      "car-model" => {
        "equals" => "honda fit"
      }
    },
    "or",
    {
      "car-model" => {
        "equals" => "toyota corolla"
      }
    }
  ],
  "cache-period" => 100
}
puts client.create_saved_query(query)
```

#### Output example

```json
{
   "took":0.053,
   "query":[
      {
         "car-model":{
            "equals":"honda fit"
         }
      },
      "or",
      {
         "car-model":{
            "equals":"toyota corolla"
         }
      }
   ],
   "name":"my-saved-query",
   "type":"count/entity",
   "cache-period":100,
   "status":"success"
}
```

### `update_saved_query(query_name, json_data)`
Update an existing saved query at SlicingDice. This method corresponds to a [PUT request at /query/saved/QUERY_NAME](http://panel.slicingdice.com/docs/#api-details-api-endpoints-put-query-saved-query-name).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY", uses_test_endpoint: false)
new_query = {
  "type" => "count/entity",
  "query" => [
    {
      "car-model" => {
        "equals" => "ford ka"
      }
    },
    "or",
    {
      "car-model" => {
        "equals" => "toyota corolla"
      }
    }
  ],
  "cache-period" => 100
}
puts client.update_saved_query("my-saved-query", new_query)
```

#### Output example

```json
{
   "took":0.037,
   "query":[
      {
         "car-model":{
            "equals":"ford ka"
         }
      },
      "or",
      {
         "car-model":{
            "equals":"toyota corolla"
         }
      }
   ],
   "type":"count/entity",
   "cache-period":100,
   "status":"success"
}
```

### `get_saved_query(query_name)`
Executed a saved query at SlicingDice. This method corresponds to a [GET request at /query/saved/QUERY_NAME](http://panel.slicingdice.com/docs/#api-details-api-endpoints-get-query-saved-query-name).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY", uses_test_endpoint: false)
puts client.get_saved_query("my-saved-query")
```

#### Output example

```json
{
   "result":{
      "query":2
   },
   "took":0.035,
   "query":[
      {
         "car-model":{
            "equals":"honda fit"
         }
      },
      "or",
      {
         "car-model":{
            "equals":"toyota corolla"
         }
      }
   ],
   "type":"count/entity",
   "status":"success"
}
```

### `delete_saved_query(query_name)`
Delete a saved query at SlicingDice. This method corresponds to a [DELETE request at /query/saved/QUERY_NAME](http://panel.slicingdice.com/docs/#api-details-api-endpoints-delete-query-saved-query-name).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY", uses_test_endpoint: false)
puts client.delete_saved_query("my-saved-query")
```

#### Output example

```json

{
   "took":0.029,
   "query":[
      {
         "car-model":{
            "equals":"honda fit"
         }
      },
      "or",
      {
         "car-model":{
            "equals":"toyota corolla"
         }
      }
   ],
   "type":"count/entity",
   "cache-period":100,
   "status":"success",
   "deleted-query":"my-saved-query"
}
```

### `result(json_data)`
Retrieve indexed values for entities matching the given query. This method corresponds to a [POST request at /data_extraction/result](http://panel.slicingdice.com/docs/#api-details-api-endpoints-post-data-extraction-result).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY", uses_test_endpoint: false)
query = {
  "query" => [
    {
      "car-model" => {
        "equals" => "ford ka"
      }
    },
    "or",
    {
      "car-model" => {
        "equals" => "toyota corolla"
      }
    }
  ],
  "fields" => ["car-model", "year"],
  "limit" => 2
}
puts client.result(query)
```

#### Output example

```json
{
   "took":0.113,
   "next-page":null,
   "data":{
      "customer5@mycustomer.com":{
         "year":"2005",
         "car-model":"ford ka"
      },
      "user1@slicingdice.com":{
         "year":"2016",
         "car-model":"ford ka"
      }
   },
   "page":1,
   "status":"success"
}
```

### `score(json_data)`
Retrieve indexed values as well as their relevance for entities matching the given query. This method corresponds to a [POST request at /data_extraction/score](http://panel.slicingdice.com/docs/#api-details-api-endpoints-post-data-extraction-score).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY", uses_test_endpoint: false)
query = {
  "query" => [
    {
      "car-model" => {
        "equals" => "ford ka"
      }
    },
    "or",
    {
      "car-model" => {
        "equals" => "toyota corolla"
      }
    }
  ],
  "fields" => ["car-model", "year"],
  "limit" => 2
}

puts client.score(query)
```

#### Output example

```json
{
   "took":0.063,
   "next-page":null,
   "data":{
      "user3@slicingdice.com":{
         "score":1,
         "year":"2010",
         "car-model":"toyota corolla"
      },
      "user2@slicingdice.com":{
         "score":1,
         "year":"2016",
         "car-model":"honda fit"
      }
   },
   "page":1,
   "status":"success"
}
```

## License

[MIT](https://opensource.org/licenses/MIT)
