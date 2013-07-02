
//検索窓内の文字
jQuery(function($){
	var textBox1 = $('#keywords');
	
});
//アカウント登録ページの
//テキストボックス内の文字
jQuery(function($){
	var textBox1 = $('#id');
	textBox1.focus(function(){
		if(textBox1.val()==' ID：'){
			textBox1.val('');
		}
	}).blur(function(){
		if(textBox1.val()=='') {
			textBox1.val(' ID：');
		}
	});
});

//テキストボックス内の文字
jQuery(function($){
	var textBox1 = $('#pw');
	textBox1.focus(function(){
		if(textBox1.val()==' PW：'){
			textBox1.val('');
		}
	}).blur(function(){
		if(textBox1.val()=='') {
			textBox1.val(' PW：');
		}
	});
});
