module Genotide

  class Piece

    include Enumerable

    attr_accessor :pieces, :accepts, :subscribtion

    def initialize(options={})
      @accepts = options[:accepts]
      @pieces = []
      @cache = {}
    end

    def each
      pieces.each do |item|
        yield item
      end
    end

    def [](i)
      pieces[i]
    end

    def is_full?(piece)
      fail "implement in subclass"
    end

    def add(piece)
      return :full if is_full?(piece)
      if accepts == nil
        pieces.push(piece)
      else
        add_sub_piece if pieces.empty?
        result = pieces.last.add(piece)
        if result == :full
          add_sub_piece
          pieces.last.add(piece)
        end
      end
    end

    def add_sub_piece
      # puts "----- adding #{accepts} ------"
      new_piece = accepts.send(:new)
      pieces << new_piece
      # pieces.last
    end

    def get_all(klass, should_wrap=true)
      result = if self.class == klass
        [self]
      else
        pieces.reduce([]) do |memo, piece|
          if piece.respond_to? :get_all
            memo.concat(piece.get_all(klass, false))
          else
            memo.push(piece)
          end
          memo
        end
      end
      if should_wrap
        p = Piece.new
        p.accepts = klass
        p.pieces = result
        p
      else
        result
      end
    end

    def index(piece)
        klass = piece.class
        if @cache.has_key?(klass)
          @cache[klass]
        else
          @cache[klass] = get_all(klass)
        end
        result = @cache[klass].pieces.index(piece) + 1
    end

    def get(klass, selector)
      if self.class == klass
        self
      else
        if pieces.send(selector).respond_to?("get_#{selector}")
          pieces.send(selector).send("get_#{selector}", klass)
        else
          pieces.send selector
        end
      end
    end

    def get_first(klass)
      get(klass, :first)
    end

    def get_last(klass)
      get(klass, :last)
    end

    def to_s
      first = get_first(Date)
      last  = get_last(Date)
      "#{first} - #{last} -- #{last - first + 1}"
    end

    def get_chain
      if accepts.nil?
        []
      else
        [accepts].concat(pieces.last.get_chain)
      end
    end

    def display
      chain = get_chain
      lowest = chain.last
      get_all(lowest)
    end

  end

end