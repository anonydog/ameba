require "../../spec_helper"

module Ameba::Rules
  subject = TrailingWhitespace.new

  describe TrailingWhitespace do
    it "passes if all lines do not have trailing whitespace" do
      source = Source.new "no-whispace"
      subject.catch(source).should be_valid
    end

    it "fails if there is a line with trailing whitespace" do
      source = Source.new "whitespace at the end "
      subject.catch(source).should_not be_valid
    end

    it "reports rule, pos and message" do
      source = Source.new "a = 1\n b = 2 "
      subject.catch(source).should_not be_valid

      error = source.errors.first
      error.rule.should_not be_nil
      error.pos.should eq 2
      error.message.should eq "Trailing whitespace detected"
    end
  end
end
