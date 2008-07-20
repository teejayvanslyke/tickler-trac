require 'xmlrpc/client'

require 'net/https'
require 'openssl'
require 'pp'

class Net_HTTP < Net::HTTP
  def initialize(*args)
    super
    @ssl_context = OpenSSL::SSL::SSLContext.new
    @ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
end

class XMLRPC_Client < XMLRPC::Client
  def initialize(*args)
    super
    @http = Net_HTTP.new( @host, @port,
                                   @proxy_host,@proxy_port )
    @http.use_ssl = @use_ssl if @use_ssl
    @http.read_timeout = @timeout
    @http.open_timeout = @timeout
  end

end


