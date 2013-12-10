# Copyright (c) 2013 Mael Clerambault <mael@clerambault.fr>
# 
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.


require 'httparty'
require 'openssl'

class Bitstamp
  VERSION = "0.1"
  API_URL = 'https://www.bitstamp.net/api/'.freeze
  class APIError < StandardError; end
  
  def initialize(client_id = "", api_key = "", secret = "")
    @client_id, @api_key, @secret = client_id, api_key, secret
    @nonce = Time.now.to_i
  end

  def public_request(m, args)
    HTTParty.get(
      API_URL + m.to_s + '/',
      :query => args
    ).parsed_response
  end

  def private_request(m, args)
    HTTParty.post(
      API_URL + m.to_s + '/',
      :body => auth_params.merge(args)
    ).parsed_response
  end
  
  def self.api_method(m, options = {})
    options[:conv] ||= DEFAULT_CONV
    options[:conv].each {|c, fields| options[:conv][c] = [fields] unless fields.respond_to? :each }
    if options[:pub]
      define_method(m) do |args = {}|
        convert(public_request(m, args), options[:conv])
      end
    else
      define_method(m) do |args = {}|
        convert(private_request(m, args), options[:conv])
      end
    end
  end

  rational = lambda {|r| Rational(r)}
  fee = lambda {|r| Rational(r)/100}
  timeat = lambda {|t| Time.at(t.to_i)}
  datetime = lambda {|t| Time.utc *t.split(/[ :-]/)}
  type = lambda {|t| t == 0 ? "buy" : "sell"}
  order_book = lambda {|list|
    list.map {|price, amount| [Rational(price), Rational(amount)]}
  }
  
  DEFAULT_CONV = {
    rational => %w(price amount usd btc btc_usd
      btc_reserved fee btc_available usd_reserved btc_balance usd_balance usd_available
      high last bid volume low ask),
    datetime => :datetime,
    timeat => %w(date timestamp),
    type => %w(type),
    fee => %w(fee)
  }

  # Public Data Functions
  api_method :ticker, :pub => true
  api_method :order_book, :pub => true, :conv => {timeat => :timestamp, order_book => %w(bids asks)}
  api_method :transactions, :pub => true
  
  # Private Functions
  api_method :balance
  api_method :user_transactions
  api_method :open_orders
  api_method :cancel_order
  api_method :buy
  api_method :sell
  api_method :check_code
  api_method :redeem_code
  api_method :withdrawal_requests
  api_method :bitcoin_withdrawal
  api_method :bitcoin_deposit_address
  api_method :unconfirmed_btc
  api_method :ripple_withdrawal
  api_method :ripple_address

  private
  def auth_params
    nonce = (@nonce += 1).to_s
    message = nonce + @client_id + @api_key
    sha256 = OpenSSL::Digest::SHA256.new
    signature = OpenSSL::HMAC.digest(sha256, @secret, message).unpack("H*")[0].upcase
    { 'key' => @api_key, 'nonce' => nonce, 'signature' => signature }
  end
  
  def convert(h, conversion)
    raise APIError.new(h["error"]) if h.is_a?(Hash) && h["error"]
    
    h_list = h.is_a?(Array) ? h : [h]
    conversion.each do |c, fields|
      h_list.each do |h_s|
        next unless h_s.is_a? Hash
        
        fields.each {|f|
          f = f.to_s
          next if not h_s[f.to_s]
          h_s[f.to_s] = c.call(h_s[f.to_s])
        }
      end
    end
    
    h
  end
end

