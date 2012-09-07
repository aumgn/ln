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
		          button.attr("disabled", "disabled");
		          button.append("<img src=\"/img/working.gif\"/>");
		          $.ajax({
		              url: '/' + row.attr('data-link-name'),
		              type: 'put',
		              data: {
			               url: url
		              },
		              success: function(errors, txt, xhr) {
			               button.find("img").remove();
			               button.removeAttr("disabled");
			               if (errors.length == 0) {
			                   old_container.attr("href", url);
			                   old_container.html(url);
			                   url_container.replaceWith(old_container);
			               } else {
			                   for (var i = 0; i < errors.length; i++) {
				                    alert(errors[i]);
			                   }
			               }
		              },
		              error: function() {
			               button.find("img").remove();
			               button.removeAttr("disabled");
			               alert("An error occured !");
		              }
		          });
	         }
	     }
    });

    $('button.reset').click(function() {
        button = $(this);
	     row = button.parents('[data-link-name]');
	     button.append('<img src="/img/working.gif">');
	     button.attr("disabled", "disabled");
        clicks = row.find(".clicks");
        if (clicks.html != "0") {
		      $.ajax({
		          url: '/' + row.attr('data-link-name'),
		          type: 'put',
		          data: {
			           reset: "1"
		          },
		          success: function(errors, txt, xhr) {
			           button.find("img").remove();
			           button.removeAttr("disabled");
			           if (errors.length == 0) {
			               clicks.html("0");
			           } else {
			               for (var i = 0; i < errors.length; i++) {
				                alert(errors[i]);
			               }
			           }
		          },
		          error: function() {
			           button.find("img").remove();
			           button.removeAttr("disabled");
			           alert("An error occured !");
		          }
		      });
        }
    });

    $('button.delete').click(function() {
	     button = $(this);
	     row = button.parents('[data-link-name]');
	     button.append('<img src="/img/working.gif">');
	     button.attr("disabled", "disabled");
	     $.ajax({
	         url: '/' + row.attr('data-link-name'),
	         type: 'delete',
	         success: function(errors) {
		          if (errors.length == 0) {
		              button.removeAttr("disabled");
		              row.remove();
		          } else {
		              for (var i = 0; i < errors.length; i++) {
			               alert(errors[i]);
		              }
		          }
	         },
	         error: function() {
		          button.find("img").remove();
		          button.removeAttr("disabled");
		          alert("An error occured !");
	         }
	     });
    });

});
