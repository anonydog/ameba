require "../../spec_helper"

module Ameba::Rules
  subject = UnlessElse.new

  describe UnlessElse do
    it "passes if unless hasn't else" do
      s = Source.new %(
        unless something
          :ok
        end
      )
      subject.catch(s).should be_valid
    end

    it "fails if unless has else" do
      s = Source.new %(
        unless something
          :one
        else
          :two
        end
      )
      subject.catch(s).should_not be_valid
    end

    it "reports rule, pos and message" do
      s = Source.new %(
        unless something
          :one
        else
          :two
        end
      )
      subject.catch(s).should_not be_valid

      error = s.errors.first
      error.should_not be_nil
      error.rule.should_not be_nil
      error.pos.should eq 2
      error.message.should eq "Favour if over unless with else"
    end
  end
end
