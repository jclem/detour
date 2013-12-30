$(document).on('hidden.bs.modal', '.modal', function () {
  $('.panel', this).remove();
});
