require 'genotide'

include Genotide
include Genotide::BroadcastTimeDimension 

describe Piece do
  
  before :each do
    
    week1 = Week.new
    week1.pieces = [
      Date(2011,1,1),
      Date(2011,1,2),
      Date(2011,1,3),
      Date(2011,1,4),
      Date(2011,1,5),
      Date(2011,1,6),
      Date(2011,1,7)
    ]
    
    week2 = Week.new
    week2.pieces = [
      Date(2011,1,8),
      Date(2011,1,9),
      Date(2011,1,10),
      Date(2011,1,11),
      Date(2011,1,12),
      Date(2011,1,13),
      Date(2011,1,14)
    ]
    
    week3 = Week.new
    week3.pieces = [
      Date(2011,1,15),
      Date(2011,1,16),
      Date(2011,1,17),
      Date(2011,1,18),
      Date(2011,1,19),
      Date(2011,1,20),
      Date(2011,1,21)
    ]
    
    week4 = Week.new
    week4.pieces = [
      Date(2011,1,22),
      Date(2011,1,23),
      Date(2011,1,24),
      Date(2011,1,25),
      Date(2011,1,26),
      Date(2011,1,27),
      Date(2011,1,28)
    ]
    
    @month = Month.new
    @month.pieces = [
      week1,
      week2,
      week3,
      week4
    ]

  end

  it "should say that a week is full" do
    
  end

end