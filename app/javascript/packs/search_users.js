var loadData = require('packs/load_data');

$(document).mouseup(function(e) {
  var container = $('div.search-box');
  if (!container.is(e.target) && container.has(e.target).length === 0) {
    $('div.search-box').removeClass('d-block');
  }
});

$(document).on('turbolinks:load', function() {
  var page = 1;
  var url = '/searches';
  var search;

  $('#search').keyup(function(){
    search =  $('#search').val()
    if(!search.startsWith('#')){
      $('.search-box').addClass('d-block');
      $('#users_result').empty();
      loadData(url, { page: page, search: search });
      }
  }).keydown(function(e){
    if ( event.which == 13 ) {
      if(!$('#search').val().startsWith('#')){
        return false;
      }
    }
  })

  $('#load-more').on('click', function(){
      page++;
      loadData(url, { page: page, search: search });
  });
});
