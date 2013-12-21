$(function () {
  $('.delete-feature').on('click', function (e) {
    var href    = $(e.currentTarget).data('path'),
        feature = $(e.currentTarget).closest('td').next().text(),
        $modal  = $('#delete-feature'),
        $name   = $modal.find('.feature-name'),
        $link   = $modal.find('a');

    $link.attr('href', href);
    $name.text(feature);
    $modal.modal('show');
  });
});
