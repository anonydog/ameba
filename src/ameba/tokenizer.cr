require "compiler/crystal/syntax/*"

module Ameba
  class Tokenizer
    def initialize(source)
      @lexer = Crystal::Lexer.new source.content
      @lexer.count_whitespace = true
      @lexer.comments_enabled = true
      @lexer.wants_raw = true
      @lexer.filename = source.path
    end

    def run(&block : Crystal::Token -> _)
      run_normal_state @lexer, &block
      true
    rescue e : Crystal::SyntaxException
      # puts e
      false
    end

    private def run_normal_state(lexer, break_on_rcurly = false,
                                 &block : Crystal::Token -> _)
      while true
        token = @lexer.next_token
        block.call token

        case token.type
        when :DELIMITER_START
          run_delimiter_state lexer, token, &block
        when :STRING_ARRAY_START, :SYMBOL_ARRAY_START
          run_array_state lexer, token, &block
        when :EOF
          break
        when :"}"
          break if break_on_rcurly
        end
      end
    end

    private def run_delimiter_state(lexer, token, &block : Crystal::Token -> _)
      while true
        token = @lexer.next_string_token(token.delimiter_state)
        block.call token

        case token.type
        when :DELIMITER_END
          break
        when :INTERPOLATION_START
          run_normal_state lexer, break_on_rcurly: true, &block
        when :EOF
          break
        end
      end
    end

    private def run_array_state(lexer, token, &block : Crystal::Token -> _)
      while true
        lexer.next_string_array_token
        block.call token

        case token.type
        when :STRING_ARRAY_END
          break
        when :EOF
          break
        end
      end
    end
  end
end
