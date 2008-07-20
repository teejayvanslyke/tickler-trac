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

    describe "load_ticket" do
      before(:each) do
        @connection.stub!(:call).
          with('ticket.get', 324).
          and_return([324, 123, 123, {'summary' => 'actually the title',
                                     'description' => 'my ticket'}])
      end

      it "loads the attributes" do
        @connection.should_receive(:call).
          with('ticket.get', 324).
          and_return([324, 123, 123, {'summary' => 'actually the title',
                                     'description' => 'my ticket'}])

        @adapter.load_ticket(324)
      end

      it "creates a new Tickler::Ticket instance" do
        result = @adapter.load_ticket(324)
        result.should be_instance_of(Tickler::Ticket)
        result.title.should == 'actually the title'
        result.id.should == 324
      end
    end

    describe "find_tickets" do

      describe ":all" do

        describe "no options" do

          it "finds all tickets" do
            @connection.should_receive(:call).
              with('ticket.query', 'order=priority').
              and_return([123, 456])

            @adapter.should_receive(:load_ticket).twice

            @adapter.find_tickets(:all)
          end

        end

        describe "with attribute filters" do

        end

      end

      describe ":first" do
        
      end

      describe "ID" do

        it "loads the ticket" do
          @ticket = mock(Tickler::Ticket)

          @adapter.should_receive(:load_ticket).
            with(234).
            and_return(@ticket)

          @adapter.find_tickets(234).should == @ticket
        end

      end

    end

  end


end

