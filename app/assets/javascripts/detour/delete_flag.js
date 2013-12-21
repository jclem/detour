$(function () {
  $('.delete-flag').on('click', function (e) {
    var href    = $(e.currentTarget).data('path'),
        id      = $(e.currentTarget).closest('td').next().text(),
        $modal  = $('#delete-flag'),
        $id     = $modal.find('.flaggable-identifier'),
        $link   = $modal.find('a');

    $link.attr('href', href);
    $id.text(id.trim());
    $modal.modal('show');
  });
});
