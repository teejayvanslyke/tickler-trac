$:.unshift(File.dirname(__FILE__)) unless
$:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'tickler'
require 'xmlrpc/client'

module Tickler
  class TracTaskAdapter < Tickler::TaskAdapter
    register_as :trac

    #=====================================================================# 
    # Configuration options from Ticklerfile
    def url(url=nil)
      @url ||= url
    end

    def username(username=nil)
      @username ||= username 
    end

    def password(password=nil)
      @password ||= password
    end

    def use_ssl?(use_ssl=false)
      @use_ssl = use_ssl 
    end
    #=====================================================================# 

    def save_ticket(ticket)
      connection.call('ticket.create', ticket.attributes[:title], "", {})
    end
    
    def save_milestone(milestone)
      connection.call('ticket.milestone.create', milestone.attributes[:title], {})
    end

    def load_ticket(id)
      result = connection.call('ticket.get', id)
      id = result[0]
      created_at = result[1]
      updated_at = result[2]
      attributes = result[3]
      title      = attributes['summary']

      Tickler::Ticket.new(attributes.merge(
                          :id => id, 
                          :title => title, 
                          :created_at => created_at,
                          :updated_at => updated_at))
    end

    def find_tickets(*args)
      if args.length == 1 && args[0].is_a?(Fixnum)
        load_ticket(args[0])
      else
        ids = connection.call('ticket.query', 'order=priority')
        result = []
        ids.each {|id| result << load_ticket(id)}
        return result
      end
    end

    def connection
      @connection ||= self.open_connection
    end

    def open_connection
        uri = URI.parse url
        @connection = XMLRPC::Client.new3(:host => uri.host, 
                                          :path => "#{uri.path}/login/xmlrpc", 
                                          :user => username, 
                                          :password => password, 
                                          :use_ssl => use_ssl?)
    end
  end
end

# list all methods supported by the trac api
#def list_methods
#  send_query('system.listMethods')
#end

#def custom(*args)
#  send_query(*args)
#end

##def get_by_milestone(milestone)
# send_query('ticket.query', "milestone=#{milestone.strip}")
#end

# returns method help
#def method_help(method)
#  send_query('system.methodHelp', method)
#end

# Returns an array of ticket ids
# Valid order types include:
#      def get_tickets(count, order = :priority)
#        extract_account_info
#        order = :priority unless columns.include?(order)
#        send_query('ticket.query', "order=#{order.to_s}")[0,count].collect{ |id| id }
#      end
