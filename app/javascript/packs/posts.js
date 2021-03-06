$(document).on('turbolinks:load', function() {
  $('body').on('keyup', '.instagram-card-input', function(event) {
    if ($(this).val() && event.keycode != 13)
      $(this)
        .parent()
        .find('input[type="submit"]')
        .removeAttr('disabled');
    else
      $(this)
        .parent()
        .find('input[type="submit"]')
        .attr('disabled', true);
  });

  $('body').on('click', '.reply .reply-btn', function() {
    var parent_id = $(this).attr('comment_id');
    var postElement = $(this).closest('.instagram-card');
    var post_id = postElement.attr('data_id');
    var username = $(this)
      .closest('.comment-wrapper')
      .find('.username')
      .text();
    $('#parent-comment-' + post_id).val(parent_id);
    $(postElement)
      .find('input#content-comment-' + post_id)
      .focus()
      .val('@' + username + ' ');
  });
});
