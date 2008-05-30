Array.prototype.contains = function(value) { return this.indexOf(value) != -1; }
var ondisplay = [];  
var ids = ['radio1', 'radio2', 'radio3', 'radio4', 'fivelive', 'sixmusic', 'radio7','onextra'];
var v = 0;
var limit = 25;
var counter = 0; 
function update() {
  	$(function() {
	//	$('#loading').show();
		$.getJSON("json/out.js", function(json) {
			for (var i=0; i < json.length; i++) {
			  if (ondisplay.contains("" + json[i] + "") == false) {
				 r = 	'<li id="lp_'+ v + '" style="display:none;"><span class="' + ids[json[i][0]] + '">' + ids[json[i][0]] + '</span> ' + json[i][1] + "</li>\n";
				 $('#river').prepend(r);
				 $('#river li:first').fadeIn("slow");
			 	 ondisplay.push("" + json[i] + "");
				 if (v >= limit) {
					s = v - limit;
				 	$('#lp_'+ s).fadeOut("slow");
					// pop out the last one
			 	 }
				 v++;
			  }
			}
		});	
		//	$('#loading').hide();	
	});	
}

function init() {
	update();
	t = setTimeout("init();",10000);
}




$(document).ready(function() {
	//hide dummy list.
	$('.dummy').hide();
	init();
});