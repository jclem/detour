$(document).on('hidden.bs.modal', '.modal', function () {
  $('.panel', this).remove();
  $('form', this)[0].reset();
});
