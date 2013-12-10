bitstamp
========

[Bitstamp API](https://www.bitstamp.net/api/) in ruby.
The source code is available on : <http://github.com/hanklords/bitstamp>

Usage
-----------

### Simple

```ruby
require "bitstamp"

bitstamp = Bitstamp.new
p bitstamp.ticker
```

### Authenticated

 ```ruby
require "bitstamp"

bitstamp = Bitstamp.new *%w{CLIENT_ID KEY SECRET}
p bitstamp.balance

# Sell order of 1BTC at 10000$
order = bitstamp.sell, :amount => 1, :price => 10000
p order
```
