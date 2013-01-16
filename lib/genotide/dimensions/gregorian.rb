module Genotide
  module GregorianTimeDimension

    class Month < Genotide::Piece

      def initialize
        super(:accepts => Date)
      end

      def is_full?
        if pieces.empty?
          false
        else
          date = get(Date, :last)
          date == date.end_of_month
        end
      end


    end


    # class Week < Piece
    # 
    #   def initialize
    #     super(:accepts => Date)
    #     # @max_days = rand(2) == 0 ? 4 : 8
    #   end
    # 
    #   def max_number_of_pieces
    #     7
    #   end
    # 
    # end

    class Quarter < Piece

      def initialize
        super(:accepts => Month)
      end

      def is_full?
        if pieces.empty?
          false
        else
          date = get(Date, :last)
          date == date.end_of_quarter
        end
      end

    end


    class Year < Piece

      def initialize
        super(:accepts => Quarter)
      end

      def max_number_of_pieces
        4
      end

    end

    class BroadcastTimeDimension < Piece

      def initialize
        super(:accepts => Year)
      end

      def max_number_of_pieces
        nil
      end

    end

  end
end