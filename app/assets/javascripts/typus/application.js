//= require typus/jquery-1.8.3-min
//= require jquery_ujs
//= require jquery.form
//= require js/bootstrap.min.js
//= require bootstrap.file-input
//= require typus/jquery.application
//= require typus/custom

$(".ajax-modal").live('click', function() {
  var url = $(this).attr('url');
  var modal_id = $(this).attr('data-controls-modal');
  
  var this_action = $.trim($(this).text());
  $modal_header = $("#" + modal_id + " .modal-header h3");
  $modal_header.find('.action_name').remove();
  $modal_header.html('<span class="action_name">' + this_action + ' </span>' + $modal_header.html());
  
  $("#" + modal_id + " .modal-body").load(url, function(){
    $('.modal-body input[type=file]').removeClass('input-xxlarge').attr('title', 'Choose File').bootstrapFileInput();
  });
});

$(document).ready(function() {
  $('input[type=file]').bootstrapFileInput();
});
