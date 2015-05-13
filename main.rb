require 'rubygems'
require 'sinatra'

set :sessions, true

SUITS = ["Hearts", "Diamonds", "Spades", "Clubs"]
CARDS = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "ACE", "KING", "QUEEN", "JACK"]
BLACKJACK = 21
  
helpers do 
 
  def make_deck
    deck = SUITS.product(CARDS)
    deck.shuffle!
  end 
 
  def calculate_deck_total(player_hand)
    card_values = player_hand.map{|card_value| card_value[1]}
    total = 0 
    card_values.each do |card_value| 
      if card_value == "ACE"
        total+= 11
      elsif card_value.to_i == 0 #For suits ie Jester, Queen
        total+= 10
      else 
        total+= card_value.to_i
      end
    end
    #adjust for Aces
    card_values.select{|card| card == "ACE"}.count.times do 
      total-=10 if total > BLACKJACK
    end 
   total  
  end 

  # def display_cards(player_hand)
  #   card_values.
  # end 
  def card_to_image(card)
    image_name = (card[0].downcase)+"_"+(card[1].to_i == 0 ? card[1].downcase : 
      card[1])+".jpg"
  end

end 

get "/" do 
  erb :set_name 
end 

post "/set_name" do 
  session[:player_name] = params[:player_name]
  session[:deck] = make_deck
  session[:player_hand] = []
  session[:dealer_hand] = []
  2.times do 
    session[:player_hand]<< session[:deck].pop
    session[:dealer_hand]<< session[:deck].pop
  end  
  session[:total_bet] = 500
  redirect "/bet"
end  

get "/bet" do
  erb :make_bet
end 

post "/game" do 
  session[:player_bet] = params[:player_bet].to_i
  if session[:current_turn] == "player"
    erb :player_turn 
  end 
  # elsif session[:current_turn] == "dealer"
  #   erb :dealer_turn
  # elsif session[:current_turn] == "compare_hands" 
  #   erb :compare_hands 
  # end 

end 

get "/game_over" do
  #inset some randomness here
end 
