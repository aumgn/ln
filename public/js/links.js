$(document).ready(function() {
    $("button.delete").click(function() {
	button = $(this);
	button.parent().append("<img src=\"/img/working.gif\"/>");
	$.ajax({
	    url: '/' + button.attr("data-link-name"),
	    type: 'delete',
	    success: function() {
		button.parent().parent().remove();
	    }
	});
    });
});
