// JavaScript Document
$(function(){

 $(".nav li:not(.current) a").each(function(){
  var a = $(this);
  var img = a.find("img");
  var src_off = img.attr("src");
  var src_on = src_off.replace(/^(.+)_off(\.[^\.]+)$/,"$1_on$2");

  $("<img />").attr("src",src_on);

  a.bind("mouseenter focus", function(){
		img.attr("src", src_on);
		});

  a.bind("mouseleave blur", function(){
		img.attr("src", src_off);
		});
	});
});

 //current表示
$(function() {
  if ($('.nav li').hasClass('current')) {
 $(".nav li.current a img").attr("src",$(".nav li.current a img").attr("src").replace(/^(.+)_off(\.[^\.]+)$/,"$1_current$2"));
  }
});