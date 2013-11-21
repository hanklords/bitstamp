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
```
