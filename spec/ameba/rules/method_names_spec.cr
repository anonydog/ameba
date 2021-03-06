require "../../spec_helper"

module Ameba
  subject = Rules::MethodNames.new

  private def it_reports_method_name(content, expected)
    it "reports method name #{expected}" do
      s = Source.new content
      Rules::MethodNames.new.catch(s).should_not be_valid
      s.errors.first.message.should contain expected
    end
  end

  describe Rules::MethodNames do
    it "passes if method names are underscore-cased" do
      s = Source.new %(
        class Person
          def first_name
          end

          def date_of_birth
          end

          def homepage_url
          end

          def valid?
          end

          def name
          end
        end
      )
      subject.catch(s).should be_valid
    end

    it_reports_method_name %(def firstName; end), "first_name"
    it_reports_method_name %(def date_of_Birth; end), "date_of_birth"
    it_reports_method_name %(def homepageURL; end), "homepage_url"

    it "reports rule, pos and message" do
      s = Source.new %(
        def bad_Name
        end
      )
      subject.catch(s).should_not be_valid
      error = s.errors.first
      error.rule.should_not be_nil
      error.pos.should eq 2
      error.message.should eq(
        "Method name should be underscore-cased: bad_name, not bad_Name"
      )
    end
  end
end
