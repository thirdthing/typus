//= require typus/jquery-1.8.3-min
//= require jquery_ujs
//= require jquery.form
//= require js/bootstrap.min.js
//= require bootstrap.file-input
//= require bootstrap-lightbox.min
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
    $('.modal-body input[type=file]').bootstrapFileInput();
  });
});

$(document).ready(function() {
  $('.paperclip-lightbox-link').on('click', function(e) {
    $('#paperclip-lightbox .lightbox-content').html('<img src="' + $(this).data('image-url') + '">');
    $('#paperclip-lightbox').lightbox();
    return false;
  });
  
  $('input[type=file]').bootstrapFileInput();
  $('.file-input-wrapper').prepend('<i class="icon-plus"></i>');

  $('.position_actions a').on('click', function(e) {
    e.preventDefault();
    $link = $(this);
    $.getJSON($(this).attr('href'), function(data) {
      var $row = $link.closest('tr');
      var $tbody = $link.closest('tbody');
      var firstPosition = parseInt($tbody.find('.position_value:first').text().trim(), 10);
      if ($link.hasClass('top')) {
        $row.prependTo($tbody);
      }
      if ($link.hasClass('bottom')) {
        $row.appendTo($tbody);
      }
      if ($link.hasClass('up')) {
        $row.insertBefore($row.prev());
      }
      if ($link.hasClass('down')) {
        $row.insertAfter($row.next());
      }
      $tbody.find('.position_value').each(function(index) {
        $(this).text(index + firstPosition);
      });
      $tbody.find('.position_actions a').removeClass('hide');
      $tbody.find('tr:first a.top, tr:first a.up, tr:last a.bottom, tr:last a.down').addClass('hide');
    });
  });
  
});

