# -*- coding: utf-8 -*- #

module Rouge
  module Lexers
    class QbScript < RegexLexer
      desc "Script source for GH3 game scripts"
      tag 'qbscript'
      filenames '*.qbs'

      mimetypes 'text/x-gh3-qbscript'

      def initialize(opts={})
        super(opts)
      end

      def self.analyze_text(text)
        return 0
      end

      def builtins
        @builtins ||= []
      end

      state :root do
        rule %r(//.*$), Comment::Single
        rule %r(/[*].*?[*]/)m, Comment::Multiline

        rule %r((?i)(\d*\.\d+|\d+\.\d*)(e[+-]?\d+)?'), Num::Float
        rule %r((?i)\d+e[+-]?\d+), Num::Float
        rule %r((?i)0x[0-9a-fA-F]*), Num::Hex
        rule %r(\d+), Num::Integer

        rule %r(\n), Text
        rule %r([^\S\n]), Text

        rule %r((break|else|elseif|if|repeat|return|random|useheap|switch|case|default|<\.\.\.>)\b)i, Keyword

        rule %r(\{(?=[A-Za-z]+\s+(_|[A-Za-z][A-Za-z0-9_]*)\s*=\s*[^;]+;)), Punctuation, :qbstruct
        rule %r((==|!=|<=|>=|&&|\|\||[=+\-*/%^<>!])), Operator
        rule %r([\[\]\{\}\(\)\.,:;]), Punctuation

        rule %r(_), Name
        rule %r([A-Za-z][A-Za-z0-9_]*), Name
        rule %r($[0-9a-fA-F]{8}), Name

        rule %r('), Str::Single, :escape_sqs
        rule %r("), Str::Double, :escape_dqs
      end

      state :qbstruct do
        rule %r((int|float|vector2|vector3|string|wstring|struct|array|qbkey|qbkeyref|stringptr|stringqs)\b)i, Keyword
        rule %r(\}), Punctuation, :pop!
        mixin :root
      end

      state :escape_sqs do
        mixin :string_escape
        mixin :sqs
      end

      state :escape_dqs do
        mixin :string_escape
        mixin :dqs
      end

      state :string_escape do
        rule %r(\\([abfnrtv\\"']|\d{1,3})), Str::Escape
      end

      state :sqs do
        rule %r('), Str::Single, :pop!
        rule %r([^']+), Str::Single
      end

      state :dqs do
        rule %r("), Str::Double, :pop!
        rule %r([^"]+), Str::Double
      end
    end
  end
end
