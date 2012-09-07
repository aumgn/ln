$(document).ready(function() {

    $('button.update').click(function() {
	button = $(this);
	row = button.parents('[data-link-name]');
	url_container = row.find('.url');
	if (url_container.is('a')) {
	    url = url_container.html();
	    url_container.replaceWith('<input class="url" name="url" value="' + url + '"/>');
	    input = row.find('.url');
	    input.data('old-container', url_container.clone());
	} else {
	    old_container = url_container.data('old-container');
	    old_url = old_container.attr("href");
	    url = url_container.val();
	    if (url == old_url) {
		url_container.replaceWith(old_container);
	    } else {
		button.append("<img src=\"/img/working.gif\"/>");
		$.ajax({
		    url: '/' + row.attr('data-link-name'),
		    type: 'put',
		    data: {
			url: url
		    },
		    success: function() {
			button.find("img").remove();
			old_container.attr("href", url);
			old_container.html(url);
			url_container.replaceWith(old_container);
		    }
		});
	    }
	}
    });

    $('button.delete').click(function() {
	button = $(this);
	row = button.parents('[data-link-name]');
	button.append('<img src="/img/working.gif">');
	$.ajax({
	    url: '/' + row.attr('data-link-name'),
	    type: 'delete',
	    success: function() {
		row.remove();
	    }
	});
    });

});
