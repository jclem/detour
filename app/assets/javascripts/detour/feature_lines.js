$(function() {
  $('.feature-lines').each(function() {
    var lines  = $(this).data('lines').split(','),
        prefix = $(this).data('prefix');

    $(this).popover({
      html     : true,
      content  : function() { return lineList(prefix, lines) },
      placement: 'bottom'
    });
  });

  function lineList(prefix, lines) {
    var str = '<ul>';

    lines.forEach(function(line) {
      line = '<li><a href="' + prefix + line + '">' + line + '</a></li>';
      str += line;
    });

    return str;
  }
});
