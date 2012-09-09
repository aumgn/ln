function randomName(length) {
    var name = "";
    var charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    for (var i = 0; i < length; i++) {
        name += charset.charAt(Math.floor(Math.random() * charset.length));
    }
    return name;
}

$(document).ready(function() {

    // Preload image.
    $('<img href="/working.gif" />');

    $("#tabs .tab a").click(function(event) {
        event.preventDefault();
        $(this).tab('show');
    });

    $(".alert").alert();

    $("button.random").click(function(event) {
        event.preventDefault();
        $(this).prevAll("#name").val(randomName(8));
    });

    var alerterrortemplate = $(".alertstemplate .alert-error");
    function displayErrors(errors) {
        var alert = alerterrortemplate.clone();
        alert.append("<ul></ul>");
        var list = alert.find("ul");
		  for (var i = 0; i < errors.length; i++) {
            list.append(errors[i]);
		  }
        var alerts = $(".alerts");
        alerts.append(alert);
    }

    $('button.update').click(function() {
        var button = $(this);
	     var row = button.parents('[data-link-name]');
	     var url_container = row.find('.url');
	     if (url_container.is('a')) {
	         var url = url_container.html();
            var width = url_container.width();
	         url_container.replaceWith('<input class="url" name="url" value="' + url + '"/>');
	         var input = row.find('.url');
            input.css("width", width);
	         input.data('old-container', url_container.clone());
	     } else {
	         var old_container = url_container.data('old-container');
	         var old_url = old_container.attr("href");
	         var url = url_container.val();
	         if (url == old_url) {
		          url_container.replaceWith(old_container);
	         } else {
		          button.attr("disabled", "disabled");
                var icon = button.find("i");
                var iconclass = icon.attr("class");
                icon.attr("class", "icon-working");
		          $.ajax({
		              url: '/' + row.attr('data-link-name'),
		              type: 'put',
		              data: {
			               url: url
		              },
		              success: function(errors, txt, xhr) {
			               button.removeAttr("disabled");
			               icon.attr("class", iconclass);
			               if (errors.length == 0) {
			                   old_container.attr("href", url);
			                   old_container.html(url);
			                   url_container.replaceWith(old_container);
			               } else {
                            displayErrors(errors);
			               }
		              },
		              error: function() {
			               button.removeAttr("disabled");
			               icon.attr("class", iconclass);
		                  displayErrors([ "An unexpected error occured !" ]);
		              }
		          });
	         }
	     }
    });

    $('button.reset').click(function() {
        var button = $(this);
	     var row = button.parents('[data-link-name]');
        var clicks = row.find(".clicks");
        if (clicks.html != "0") {
	         button.attr("disabled", "disabled");
            var icon = button.find("i");
            var iconclass = icon.attr("class");
            icon.attr("class", "icon-working");
		      $.ajax({
		          url: '/' + row.attr('data-link-name'),
		          type: 'put',
		          data: {
			           reset: "1"
		          },
		          success: function(errors, txt, xhr) {
			           button.removeAttr("disabled");
			           icon.attr("class", iconclass);
			           if (errors.length == 0) {
			               clicks.html("0");
			           } else {
                        displayErrors(errors);
			           }
		          },
		          error: function() {
			           button.removeAttr("disabled");
			           icon.attr("class", iconclass);
		              displayErrors([ "An unexpected error occured !" ]);
		          }
		      });
        }
    });

    $('button.delete').click(function() {
	     var button = $(this);
	     var row = button.parents('[data-link-name]');
	     button.attr("disabled", "disabled");
        var icon = button.find("i");
        var iconclass = icon.attr("class");
        icon.attr("class", "icon-working");
	     $.ajax({
	         url: '/' + row.attr('data-link-name'),
	         type: 'delete',
	         success: function(errors) {
		          if (errors.length == 0) {
		              row.remove();
		          } else {
                    displayErrors(errors);
		          }
	         },
	         error: function() {
		          button.removeAttr("disabled");
			       icon.attr("class", iconclass);
		          displayErrors([ "An unexpected error occured !" ]);
	         }
	     });
    });

});
