require File.dirname(__FILE__) + '/spec_helper.rb'

describe Tickler::TracTaskAdapter do

  describe 'open_connection' do
    before(:each) do
      @adapter = Tickler::TracTaskAdapter.new
      @url = "http://some/trac"
      @username = 'my_username'
      @password = 'my_password'
      @adapter.stub!(:username).and_return(@username)
      @adapter.stub!(:password).and_return(@password)
      @adapter.stub!(:url).and_return(@url)

      @host = 'some.host'
      @path = 'some/path'
      @uri = mock(URI, :host => @host,
                       :path => @path)
                       
      URI.stub!(:parse).and_return(@uri)
    end

    it "parses the url" do
      URI.should_receive(:parse).with(@url).
        and_return(@uri)
      @adapter.open_connection
    end

    it "opens a connection" do
      XMLRPC::Client.should_receive(:new3).
        with(:host => @host,
             :path => @path + '/login/xmlrpc',
             :user => @username,
             :password => @password,
             :use_ssl => false)
      @adapter.open_connection
    end
  end

  describe 'interface' do
    before(:each) do
      @adapter = Tickler::TracTaskAdapter.new
      @connection = mock(XMLRPC::Client)
      @adapter.stub!(:connection).
        and_return(@connection)
    end

    describe 'save_ticket' do
      it "calls 'ticket.create' on the connection" do
        @connection.should_receive(:call).
          with('ticket.create', "My Ticket's Title", "", {})
        @adapter.save_ticket(mock(Tickler::Ticket, :attributes => 
          { :title => "My Ticket's Title" }))
      end
    end

    describe 'save_milestone' do
      it "calls 'ticket.milestone.create' on the connection" do
        @connection.should_receive(:call).
          with('ticket.milestone.create', "My Milestone's Title", {})
        @adapter.save_milestone(mock(Tickler::Milestone, :attributes => 
          { :title => "My Milestone's Title" }))
      end
    end
  end


end

