(function ($) {
  jQuery.expr[':'].Contains = function (a, i, m) {
    return (a.textContent || a.innerText || "").toUpperCase().indexOf(m[3].toUpperCase()) >= 0;
  };
  // First condition
  function firstCond() {
    $('input').val("");
    $('#listSearch .ui-listview-item').hide();
	};

	function unselect() {
		$('#listSearch').find('.selected').removeClass('selected');
		$('#listSearch').find('.active').removeClass('active');
	}
	// Accending sort
	function asc_sort(a, b) {
		return ($(b).text()) < ($(a).text()) ? 1 : -1;    
	}
	// Decending sort
	function dec_sort(a, b) {
		return ($(b).text()) > ($(a).text()) ? 1 : -1;    
	}
	// Remove duplicate
	function removeDup(a) {
		var seen = {};
		$(a).each(function () {
			var txt = $(this).text();
				if (seen[txt]) {
					$(this).remove();
        } else {
					seen[txt] = true;
        }
		});
	}

  function isValidUrl(url) {
    var urlRegex = /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/
    return urlRegex.test(url);
  }

  function visitLink(a) {
    Utils.run_command('x-www-browser ' + a);
  }

  function runTerminal(a) {
    Utils.run_command('gnome-terminal -e "' + a + '"');
  }

	var typingTimeout;
	function listFilter(header, list) { 
	  // Header is any element, list is an unordered list
    // Create and add the filter form to the header
    var form = $("<div>").attr({"class":"filterform"});
    var input = $("<input>").attr({"class":"filterinput","type":"text","id":"searchinput","placeholder":"Type to search..."});
    var runin = $('<div>').attr({'class':'runin'});
    $(form).append(input).appendTo(header);
    $(form).append(runin).appendTo(header);
   
	  // Arrow navigation
   

    $(input)
		.click( function () {firstCond();unselect();})
		.keyup( function (e) {
		  var $item = $('#listSearch a span:visible').not(':has(:empty)');
			var o = {38: 'up',40: 'bottom',37: 'prev',39: 'next'}
			var dir = o[e.which];
		  var $active = $('.active'),
		  i = $item.index($active);
			
			if (e.which === 13) {
				var filter = $(this).val();
        if (filter.indexOf('!r') > -1 && filter.length === 2) {
          return runTerminal('pkill manokwari');
				}

		    $('span.active').parent().addClass('selected');
        var p = $active.parent();
				if (p.hasClass('runin-item-text')) {
					var r = p.attr('runin');
					if (p.parent().hasClass('url')) {
						visitLink(r);
					} else if (p.parent().hasClass('search')) {
						var a = "https://www.google.com/search?q="+r;
						visitLink(a);
					} else if (p.parent().hasClass('wiki')) {
						var a = "https://en.wikipedia.org/wiki/"+r;
						visitLink(a);
					} else {
						runTerminal(r);
					}
				} else {
          var a = $active.parent().attr('desktop');
					Utils.run_desktop(a);
				}

				firstCond();
				unselect();
		  } else if (e.which === 38 || e.which === 40 ) {
				var p = dir === 'up' ? (i - 1) : (i + 1);
				unselect();
	      $item.eq(p).addClass('active');
	      $(list).find(".active").parent().parent().addClass('selected');
			} else if (
			// Disable left, right, shift, control, alt, tab, menu
      e.which === 37 || 
      e.which === 39 || 
      e.which === 16 || 
      e.which === 17 || 
      e.which === 18 || 
      e.which === 9 || 
      e.which === 93) {
				return;
			} else {
				var filter = $(this).val();
				$(list).find(".ui-listview-item").hide();
				if (filter && filter != " " && filter != "" && filter.length > 0) {
				  clearTimeout(typingTimeout);
					typingTimeout = setTimeout(function () {
						$(list).hide();				
	
						// The query executed immediatelly for each keypress, this will cause performance issue
						// Give some delay while typing
	
						// This finds all links in a list that contain the input,
						// And hide the ones not containing the input while showing the ones that do
						$(list).find("a:not(:Contains(" + filter + "))").parent().hide();
						$(list).find("a:Contains(" + filter + ")").parent().show();
						$(list).fadeIn();
						
						unselect();
										
						$(list).find('a span:visible').first().addClass('active');
						$(list).find(".active").parent().parent().addClass('selected');
					
            // runin
            $('.runin-item').remove();
            if (isValidUrl(filter)) {
              var runinUrl = $("<div class='ui-listview-item runin-item url'><a href='#' class='runin-item-text' runin='"+filter+"'><img src='img/logo_globe.png'><span>Open URL: "+filter+"</span></a>");
              $(list).append(runinUrl);
            } else {
							var runinCommand = $("<div class='ui-listview-item runin-item command'><a href='#' class='runin-item-text' runin='"+filter+"'><img src='img/logo_command.png'><span>Run: "+filter+"</span></a>");
              var runinSearch = $("<div class='ui-listview-item runin-item search'><a href='#' class='runin-item-text' runin='"+filter+"'><img src='img/logo_google.png'><span>Search: "+filter+"</span></a>");
              var runinWiki = $("<div class='ui-listview-item runin-item wiki'><a href='#' class='runin-item-text' runin='"+filter+"'><img src='img/logo_wikipedia.png'><span>Wikipedia: "+filter+"</span></a>");
              $(list).append(runinCommand).append(runinSearch).append(runinWiki);
            }
            $('.runin-item').click(function(e){
              var p = $(e.target).closest('a')
              var r = p.attr('runin');
              if (p.parent().hasClass('url')) {
                visitLink(r);
              } else if (p.parent().hasClass('search')) {
                var a = "https://www.google.com/search?q="+r;
                visitLink(a);
              } else if (p.parent().hasClass('wiki')) {
                var a = "https://en.wikipedia.org/wiki/"+r;
                visitLink(a);
              } else {
                runTerminal(r);
              }
              firstCond();
              unselect();
            })
					}, 500);
				} else {
					$(list).find(".ui-listview-item").hide();
				}
				return false;
			}
		    
		  if (!$active.length) {
		    $item.first().addClass('active');
		    return;
		  }
		});
  }
  // On DOM ready
	$(document).ready(function () {
		var header = $('#header'),
				listSearch = $('#listSearch'),
				listSearch_child = $('#listSearch .ui-listview-item');	
		$(document).keydown(function () {$("input").focus();});
		listFilter(header, listSearch);
		listSearch_child.sort(asc_sort).appendTo(listSearch);
		listSearch_child.mouseup(function () {
      firstCond();
    });
		removeDup(listSearch_child);
		$("#listApplications").click(function () { 
      firstCond();
    });
	});
}) (jQuery);																																								
