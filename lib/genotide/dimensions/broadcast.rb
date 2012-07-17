module Genotide
  module BroadcastTimeDimension

    class Week < Genotide::Piece
    
      def initialize
        super(:accepts => Date)
      end
    
      def max_number_of_pieces
        7
      end
    
    end

    class Month < Genotide::Piece

      def initialize
        super(:accepts => Week)
      end

      def is_full?(piece)
        if pieces.empty?
          false
        else
          bow = piece.beginning_of_week
          eow = piece.end_of_week
          if piece == bow && eow.month != bow.month
            true
          end
        end
      end
    end

    class Quarter < Genotide::Piece

      def initialize
        super(:accepts => Month)
      end

      def max_number_of_pieces
        3
      end

    end

    class Year < Genotide::Piece

      def initialize
        super(:accepts => Quarter)
      end

      def max_number_of_pieces
        4
      end

    end

    class BroadcastTimeDimension < Genotide::Piece

      def initialize
        super(:accepts => Year)
      end

      def max_number_of_pieces
        nil
      end

    end

    def self.generate
      td = BroadcastTimeDimension.new
    
      (Date.new(2010,12,27)..Date.new(2012,12,7)).each do |date|
        td.add(date)
      end
      td
    end
  end
end