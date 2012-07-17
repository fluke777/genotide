module Genotide

  class Piece

    attr_accessor :pieces, :accepts, :subscribtion

    def initialize(options={})
      @accepts = options[:accepts]
      @pieces = []
      # @subscribtion = ActiveSupport::Notifications.subscribe("#{accepts}_full") do |*args|
      #   puts "#{accepts} is full"
      #   child = get(accepts, :last)
      #   while (child.respond_to?(:accepts) && !child.accepts.nil?) do
      #     child.unsubscribe
      #     child = child.get(child.accepts, :last)
      #   end
      # 
      #   event = ActiveSupport::Notifications::Event.new(*args)
      # 
      #   piece = event.payload[:piece]
      #   binding.pry if Date.new(2011, 5, 30) == piece
      #   if !is_full?(piece)
      #     add_sub_piece.add(piece)
      #   else
      #     ActiveSupport::Notifications.instrument("#{self.class}_full", {:piece => piece})
      #   end
      # end
    end

    def unsubscribe
      ActiveSupport::Notifications.unsubscribe(@subscribtion)
    end

    def max_number_of_pieces
      fail "implement in subclass"
    end

    def is_full?(piece)
      return false if max_number_of_pieces().nil?
      pieces.count == max_number_of_pieces() && pieces.
    end

    def add(piece)
      # if piece.class == accepts
      #   
      # else
      #   
      # end
    end

    def add_sub_piece
      puts "----- adding #{accepts} ------"
      new_piece = accepts.send(:new)
      pieces << new_piece
      pieces.last
    end

    def get_level(klass)
      if self.class == klass
        [self]
      else
        pieces.reduce([]) do |memo, piece|
          if piece.respond_to? :get_level
            memo.concat(piece.get_level(klass))
          else
            memo.push(piece)
          end
          memo
        end
      end
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

  end

end