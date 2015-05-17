require 'rubygems'
require 'sinatra'

set :sessions, true

SUITS = ["Hearts", "Diamonds", "Spades", "Clubs"]
CARDS = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "ACE", "KING", "QUEEN", 
"JACK"]
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

  def card_to_image(card)
    image_name = (card[0].downcase)+"_"+(card[1].to_i == 0 ? card[1].downcase : 
      card[1])+".jpg"
  end

  def new_round
      @show_hit_or_stay_buttons = false 
      @show_play_again_buttons = true
  end 

  def display_win_lose_tie_msg(msg, win_lose_tie)
    if win_lose_tie == "win"
      @success = "<strong>#{session[:player_name]} WINS!<strong> #{msg}"
      new_round
    elsif win_lose_tie == "lose"
      @error = "<strong>#{session[:player_name]} loses..<strong> #{msg}"
      new_round
    else 
      @success = "<strong>#{session[:player_name]} has tied with dealer 
      </strong> with a score of #{msg}"
      new_round
    end 
  end 

end 

before do
  @show_hit_or_stay_buttons = true 
  @show_play_again_buttons = false  
end 

get "/" do 
  if session[:player_name]
    redirect "/game"
  else  
    session[:total_bet] = 500 
    erb :set_name 
  end 
end 

get "/set_name" do
  session[:total_bet] = 500 
  erb :set_name
end 

post "/set_name" do
  if params[:player_name].empty?
    @error = "Please enter a valid name..." 
    halt erb :set_name
  end 
  session[:player_name] = params[:player_name]
  redirect "/bet"
end  

get "/bet" do
  erb :make_bet
end 

post "/bet" do 
  if params[:player_bet].empty? || params[:player_bet].to_i <= 0 
    @error = "Don't be cheap...place a bet" 
    halt erb :make_bet
  elsif session[:total_bet] <= 0 
    redirect "/game_over"
  else 
  session[:player_bet] = params[:player_bet].to_i
  session[:total_bet] -= session[:player_bet]
  redirect "/game"
  end 
end 
get "/game" do
  session[:deck] = make_deck
  session[:player_hand] = []
  session[:dealer_hand] = []
  2.times do 
    session[:player_hand]<< session[:deck].pop
    session[:dealer_hand]<< session[:deck].pop
  end  
  session[:turn] = session[:player_name]
  session[:player_bet] = params[:player_bet].to_i
  session[:turn] = session[:player_name]
  erb :game 
end 

post "/game/player/hit" do
  session[:player_hand]<< session[:deck].pop
  current_hand_total= calculate_deck_total(session[:player_hand])
  
  if current_hand_total == BLACKJACK
    display_win_lose_tie_msg("#{session[:player_name]} has hit BLACKJACK", "win")
  elsif current_hand_total > BLACKJACK
    display_win_lose_tie_msg("#{session[:player_name]} has BUSTED", "lose")
  end
  erb :game 
end 

post "/game/player/stay" do
  @success = "#{session[:player_name]} has decided to stay"
  @show_hit_or_stay_buttons = false
  redirect "/game/dealer"
end 

get "/game/dealer" do
  @show_hit_or_stay_buttons = false 
  session[:turn] = "dealer"
  dealer_hand_total= calculate_deck_total(session[:dealer_hand])
  
  if dealer_hand_total == BLACKJACK
    display_win_lose_tie_msg("Dealer has hit BLACKJACK", "lose")
  elsif dealer_hand_total > BLACKJACK
    display_win_lose_tie_msg("Dealer has BUSTED", "win")
  elsif dealer_hand_total >= 17
    redirect "/game/dealer/compare"
  else
    @show_dealer_hit_button = true
  end  
  erb :game
end 

post "/game/dealer/hit" do
  session[:dealer_hand] << session[:deck].pop
  redirect "/game/dealer"
end 

get "/game/dealer/compare" do 
  @show_hit_or_stay_buttons = false
  player_total = calculate_deck_total(session[:player_hand])
  dealer_total = calculate_deck_total(session[:dealer_hand])

    if player_total > dealer_total
      scores = "#{session[:player_name]}'s score: 
      #{calculate_deck_total(session[:player_hand])} | Dealer score: 
      #{session[:dealer_hand]}"
      display_win_lose_tie_msg("#{score}","win")
    elsif player_total < dealer_total
      display_win_lose_tie_msg("#{score}","lose")
    else 
      display_win_lose_tie_msg("#{calculate_deck_total(session[:player_hand])}",
        "tie")
    end 
    erb :game 
end 


get "/game_over" do
  erb :game_over
end 

