# SlicingDice Official Ruby Client (v2.0.2)
### Build Status: [![CircleCI](https://circleci.com/gh/SlicingDice/slicingdice-ruby.svg?style=svg)](https://circleci.com/gh/SlicingDice/slicingdice-ruby)

Official Ruby client for [SlicingDice](http://www.slicingdice.com/), Data Warehouse and Analytics Database as a Service.  

[SlicingDice](http://www.slicingdice.com/) is a serverless, API-based, easy-to-use and really cost-effective alternative to Amazon Redshift and Google BigQuery.

## Documentation

If you are new to SlicingDice, check our [quickstart guide](https://docs.slicingdice.com/docs/quickstart-guide) and learn to use it in 15 minutes.

Please refer to the [SlicingDice official documentation](https://docs.slicingdice.com/) for more information on [how to create a database](https://docs.slicingdice.com/docs/how-to-create-a-database), [how to insert data](https://docs.slicingdice.com/docs/how-to-insert-data), [how to make queries](https://docs.slicingdice.com/docs/how-to-make-queries), [how to create columns](https://docs.slicingdice.com/docs/how-to-create-columns), [SlicingDice restrictions](https://docs.slicingdice.com/docs/current-restrictions) and [API details](https://docs.slicingdice.com/docs/api-details).

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
client = SlicingDice.new(master_key: "API_KEY")

# Inserting data
insert_data = {
    "user50@slicingdice.com" => {
        "age" => 22
    },
    "auto-create" => ["dimension", "column"]
}
client.insert(insert_data)

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

`SlicingDice` encapsulates logic for sending requests to the API. Its methods are thin layers around the [API endpoints](https://docs.slicingdice.com/docs/api-details), so their parameters and return values are JSON-like `Hash` objects with the same syntax as the [API endpoints](https://docs.slicingdice.com/docs/api-details)

### Attributes

* `keys (String)` - [API key](https://docs.slicingdice.com/docs/api-keys) to authenticate requests with the SlicingDice API.

### Constructor

`initialize(master_key: nil, custom_key: nil, read_key: nil, write_key: nil, timeout: 60, use_ssl: true)`
* `master_key (String)` - [API key](https://docs.slicingdice.com/docs/api-keys) to authenticate requests with the SlicingDice API.
* `custom_key (String)` - [API key](https://docs.slicingdice.com/docs/api-keys) to authenticate requests with the SlicingDice API.
* `read_key (String)` - [API key](https://docs.slicingdice.com/docs/api-keys) to authenticate requests with the SlicingDice API.
* `write_key (String)` - [API key](https://docs.slicingdice.com/docs/api-keys) to authenticate requests with the SlicingDice API.
* `use_ssl (Bool)` - Define if the requests verify SSL for HTTPS requests.
* `timeout (Fixnum)` - Amount of time, in seconds, to wait for results for each request.

### `get_database()`
Get information about current database. This method corresponds to a `GET` request at `/database`.

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY")

puts client.get_database()
```

#### Output example

```json
{
    "name": "Database 1",
    "description": "My first database",
    "dimensions": [
    	"default",
        "users"
    ],
    "updated-at": "2017-05-19T14:27:47.417415",
    "created-at": "2017-05-12T02:23:34.231418"
}
```

### `get_columns()`
Get all created columns, both active and inactive ones. This method corresponds to a [GET request at /column](https://docs.slicingdice.com/docs/how-to-list-edit-or-delete-columns).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY")
puts client.get_columns()
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

### `create_column(json_data)`
Create a new column. This method corresponds to a [POST request at /column](https://docs.slicingdice.com/docs/how-to-create-columns#section-creating-columns-using-column-endpoint).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY")
column = {
  "name" => "Year",
  "api-name" => "year",
  "type" => "integer",
  "description" => "Year of manufacturing",
  "storage" => "latest-value"
}
puts client.create_column(column)
```

#### Output example

```json
{
    "status": "success",
    "api-name": "year"
}
```

### `insert(json_data)`
Insert data to existing entities or create new entities, if necessary. This method corresponds to a [POST request at /insert](https://docs.slicingdice.com/docs/how-to-insert-data).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY")
insert_data = {
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
  },
  "auto-create" => ["dimension", "column"]
}
puts client.insert(insert_data)
```

#### Output example

```json
{
    "status": "success",
    "inserted-entities": 4,
    "inserted-columns": 10,
    "took": 0.023
}
```

### `exists_entity(ids, dimension)`
Verify which entities exist in a dimension (uses `default` dimension if not provided) given a list of entity IDs. This method corresponds to a [POST request at /query/exists/entity](https://docs.slicingdice.com/docs/exists).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY")
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
Count the number of inserted entities in the whole database. This method corresponds to a [POST request at /query/count/entity/total](https://docs.slicingdice.com/docs/total).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY")

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

### `count_entity_total(dimensions)`
Count the total number of inserted entities in the given dimensions. This method corresponds to a [POST request at /query/count/entity/total](https://docs.slicingdice.com/docs/total#section-counting-specific-tables).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY")

dimensions = ["default"]

puts client.count_entity_total(dimensions)
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
Count the number of entities matching the given query. This method corresponds to a [POST request at /query/count/entity](https://docs.slicingdice.com/docs/count-entities).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY")
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
Count the number of occurrences for time-series events matching the given query. This method corresponds to a [POST request at /query/count/event](https://docs.slicingdice.com/docs/count-events).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY")
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
Return the top values for entities matching the given query. This method corresponds to a [POST request at /query/top_values](https://docs.slicingdice.com/docs/top-values).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY")
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
Return the aggregation of all columns in the given query. This method corresponds to a [POST request at /query/aggregation](https://docs.slicingdice.com/docs/aggregations).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY")
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
Get all saved queries. This method corresponds to a [GET request at /query/saved](https://docs.slicingdice.com/docs/saved-queries).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY")
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
Create a saved query at SlicingDice. This method corresponds to a [POST request at /query/saved](https://docs.slicingdice.com/docs/saved-queries).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY")
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
Update an existing saved query at SlicingDice. This method corresponds to a [PUT request at /query/saved/QUERY_NAME](https://docs.slicingdice.com/docs/saved-queries).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY")
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
Executed a saved query at SlicingDice. This method corresponds to a [GET request at /query/saved/QUERY_NAME](https://docs.slicingdice.com/docs/saved-queries).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY")
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
Delete a saved query at SlicingDice. This method corresponds to a [DELETE request at /query/saved/QUERY_NAME](https://docs.slicingdice.com/docs/saved-queries).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY")
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
Retrieve inserted values for entities matching the given query. This method corresponds to a [POST request at /data_extraction/result](https://docs.slicingdice.com/docs/result-extraction).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY")
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
  "columns" => ["car-model", "year"],
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
Retrieve inserted values as well as their relevance for entities matching the given query. This method corresponds to a [POST request at /data_extraction/score](https://docs.slicingdice.com/docs/score-extraction).

#### Request example

```ruby
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY")
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
  "columns" => ["car-model", "year"],
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

### `sql(query)`
Retrieve inserted values using a SQL syntax. This method corresponds to a POST request at /query/sql.

#### Request example

```go
require 'rbslicer'
client = SlicingDice.new(master_key: "API_KEY")
query = "SELECT COUNT(*) FROM default WHERE age BETWEEN 0 AND 49"

puts client.sql(query)
```

#### Output example

```json
{
   "took":0.063,
   "result":[
       {"COUNT": 3}
   ],
   "count":1,
   "status":"success"
}
```

## License

[MIT](https://opensource.org/licenses/MIT)
