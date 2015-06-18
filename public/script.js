$(document).ready(function(){
  player_hits();
  player_stays();
  dealers_next_card();
});

function player_hits(){
  
  $(document).on('click', 'form#hit_action input', function() {
      $.ajax({
      type: 'POST',
      url: '/game/player/hit'
      }).done(function(page){
        $('#game').replaceWith(page);
      });

      return false; 
  });

};

function player_stays(){

  $(document).on('click', 'form#stay_action input', function() {
      $.ajax({
      type: 'POST',
      url: '/game/player/stay'
      }).done(function(page){
        $('#game').replaceWith(page);
      });

      return false; 
  });

};

function dealers_next_card(){

  $(document).on('click', 'form#display_dealer_next_card input', function() {
      $.ajax({
      type: 'POST',
      url: '/game/dealer/hit'
      }).done(function(page){
        $('#game').replaceWith(page);
      });

      return false; 
  });

};
