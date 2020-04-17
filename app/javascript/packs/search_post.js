var loadData = require('packs/load_data');

$(document).ready(function() {
  var page = 1;
  var search = $('#search').val();
  var url = '/searches';
  loadData(url, { page: page, search: search });

  $('#load-more').on('click', function(){
      page++;
      loadData(url, { page: page, search: search });
  });
});
