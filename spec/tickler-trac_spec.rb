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
      XMLRPC_Client.should_receive(:new3).
        with(:host => @host,
             :path => @path + '/login/xmlrpc',
             :user => @username,
             :password => @password,
             :use_ssl => nil)
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

            @tickets = [ [:ticket1], [:ticket2] ]

            @connection.should_receive(:call).
              with('system.multicall', 
                   [
                   { 'methodName' => 'ticket.get',
                     'params'     => ['123'] },
                   { 'methodName' => 'ticket.get',
                     'params'     => ['456'] }
                    ] 
                  ).
                    and_return(@tickets)

            @adapter.should_receive(:create_ticket_from_xmlrpc).
              with(:ticket1)
            @adapter.should_receive(:create_ticket_from_xmlrpc).
              with(:ticket2)


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

    describe "find_milestones" do

      describe ":all" do

        describe "no options" do

          it "finds all milestones" do
            @connection.should_receive(:call).
              with('ticket.milestone.getAll').
              and_return([123, 456])

            @milestones = [ 
              {:name => 'Milestone1'}, 
              {:name => 'Milestone2'}
            ]

            @connection.should_receive(:call).
              with('system.multicall', 
                   [
                   { 'methodName' => 'ticket.milestone.get',
                     'params'     => ['123'] },
                   { 'methodName' => 'ticket.milestone.get',
                     'params'     => ['456'] }
                    ] 
                  ).
                    and_return(@milestones)

            @adapter.should_receive(:create_milestone_from_xmlrpc).
              with(@milestones[0])
            @adapter.should_receive(:create_milestone_from_xmlrpc).
              with(@milestones[1])


            result = @adapter.find_milestones(:all)
            result.length.should == 2
            result[0].title.should == 'Milestone1'
            result[1].title.should == 'Milestone2'
          end

        end

        describe "with attribute filters" do

        end

      end

      describe ":first" do
        
      end

      describe "ID" do

        it "loads the milestone" do
          @milestone = mock(Tickler::Milestone)

          @adapter.should_receive(:load_milestone).
            with(234).
            and_return(@milestone)

          @adapter.find_milestones(234).should == @milestone
        end

      end

    end

  end


end

