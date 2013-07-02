// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery-1.8
//= require jquery_ujs
//= require_directory .
//= require zeroclipboard
$(function(){



    $('#clients_list').niceScroll({cursorcolor:"#0087A9",cursorwidth:"8px"});

    $('#promotions_list').niceScroll({cursorcolor:"#0087A9",cursorwidth:"8px"});
    $('#conversions_list').niceScroll({cursorcolor:"#0087A9",cursorwidth:"8px"});
    $("#promotion_tables").niceScroll({cursorcolor:"#0087A9",cursorwidth:"8px"});
    $("#scroll_flexigrid").niceScroll({cursorcolor:"#0087A9",cursorwidth:"8px"});

   // $("#promotions_scroll").niceScroll({cursorcolor:"#0087A9",cursorwidth:"8px",horizrailenabled:"false"});

});

function index_of(haystack, needle) {
    for (var i = 0, l = haystack.length; i < l; ++i) {
        if( haystack[i].value === needle ) {
           return i;   
        }
    }
    return -1;
}


function reloadFlex(obj, urlAction, id, current_active, cname, maxlength) {
	$(obj)
    .flexOptions({
        url: urlAction,
        newp: 1
    }).flexReload();
    $(current_active).removeClass('current');
    $(id).addClass('current');
    var txt = '';
    if ($(id).text().length > maxlength)
    	txt = $(id).text().substring(0, maxlength) + '...';
    else{
    	txt = $(id).text();
    }
    $(cname).text(txt);
    $(cname).parent("div").attr("title",$(id).attr("title"));
}
function ajaxCommon(urlAction, id, current_active, cname,arr_inner) {
    //($this).preventDefault();
    location.href = urlAction;
    return;
    if (prevent == true){
    	$("#change").click(function(){
			var array_inner = arr_inner.split(',');
    		$("#dvloader").css('display','');
    		$.ajax({
        		type: "GET",
        		url: urlAction,
        		dataType: "html"
    		}).done(function( data  ) {
            	for (i=0;i<array_inner.length;i++){
            		var inner_data = $(data).find(array_inner[i]);
            		$(array_inner[i]).html(inner_data.children());
            	}
            	$("#dvloader").css('display','none');
				$('input#keywords').quicksearch('div#clients_list tr', {
	        		"selector": "a.client_name_search"
				});
				$('input#keywords').quicksearch('div#promotions_list tr', {
					"selector": "a.promotion_name"
				});
				$(current_active).removeClass('active');
    			$(id).addClass('active');
        	});
        	prevent = false;
        	$('#prevent_change').colorbox.close();
        	$("#popup_prevent").remove();
		});
		$("#cancel_change").click(function(){
			$('#prevent_change').colorbox.close();
		});
		$.colorbox({
			width: "30%",
			inline: true,
			escKey: false,
			overlayClose: false,
			href: "#prevent_change"
		})
    }else{
    	var array_inner = arr_inner.split(',');
    		$("#dvloader").css('display','');
    		$.ajax({
        		type: "GET",
        		url: urlAction,
        		dataType: "html"
    		}).done(function( data  ) {
    			
            	for (i=0;i<array_inner.length;i++){
            		var inner_data = $(data).find(array_inner[i]);
            		$(array_inner[i]).html(inner_data.children());
            	}
            	$("#dvloader").css('display','none');
				$('input#keywords').quicksearch('div#clients_list tr', {
	        		"selector": "a.client_name_search"
				});
				$('input#keywords').quicksearch('div#promotions_list tr', {
					"selector": "a.promotion_name"
				});
				$(current_active).removeClass('active');
    			$(id).addClass('active');
        	});
    }
}
function reloadFlex1(obj, urlAction) {
    $(obj)
    .flexOptions({
        url: urlAction,
        newp: 1
    }).flexReload();
}
function draw_chart(data_left, data_right, left, right, categories){
    var min = new Date().getTime();
    var max = min + 50 * 500;
    this.categories = categories;
    if(this.categories.length > 32)
      custom_tickInterval = Math.ceil(this.categories.length/32);
    else
        custom_tickInterval = 1;
    chart = new Highcharts.Chart({ // 以下、chartオブジェクトに渡す引数
		chart: {
			renderTo: 'sample-chart', // どの要素にグラフを描画するかを指定
			type: 'line', // グラフの種類を指定
            zoomType: 'xy'
		},
		credits: {//右下リンクの消去
            enabled: false
        },
		title: {
			text:false
			},
		subtitle: {
			text:false
		},
		xAxis: { // x軸の値を指定
            categories: this.categories,
            lineWidth:0,
            labels: {
                rotation: -45,
                formatter: function() {
                	return this.value.substring(5);
				},
				align: 'right'
            },
          tickInterval: custom_tickInterval
		},
        plotOptions: {
            series: {
                lineWidth: 1.5
            }
        },
		legend: {
            labelFormatter: function(){
            	name = this.name;
				tmp = name.split("_");
				if ($.cookie("locale") == "ja")
		    	{
			    	if (tmp[1] == "CV"){
			    		name = tmp[0] + "_totalCV";
			    	}
			    	if (tmp[1] == "CV(first)"){
			    		name = tmp[0] + "_初回CV";
			    	}
			    	if (tmp[1] == "CV(repeat)"){
			    		name = tmp[0] + "_リピートCV";
			    	}
			    }
			    return name;
            }
		},
		yAxis: [{
			min: 0,
			title: {
            	text: null
			},
            labels: {
                formatter: function() {
                	return Highcharts.numberFormat(this.value, 0);
				}
			}
		},{
			min: 0,
			title: {
            	text: null
            },
            labels: {
                formatter: function() {
                	return Highcharts.numberFormat(this.value, 0);
				}
			},
			opposite: true
		}],
		tooltip: { // マウスオーバーした際に表示する文書を指定
            share: true,
			formatter: function() {
				name = this.series.name;
				tmp = name.split("_");
				if ($.cookie("locale") == "ja")
		    	{
			    	if (tmp[1] == "CV"){
			    		name = tmp[0] + "_totalCV";
			    	}
			    	if (tmp[1] == "CV(first)"){
			    		name = tmp[0] + "_初回CV";
			    	}
			    	if (tmp[1] == "CV(repeat)"){
			    		name = tmp[0] + "_リピートCV";
			    	}
			    }
				date = this.x;
				if ($.cookie("locale") == "en"){
					text = date.substring(0,4);
					date = date.substring(5) + "/" +text;
				}
				return '<b>'+ name +'</b><br/>'+
				date +': '+ graphNumberFormat(this.y, this.series.name);
			}
		},
		series: [{
				name: left,
				data: data_left,
				color: "#32CF32"
			},{ // データ系列を指定
				name: right,
				data: data_right,
				yAxis: 1,
				color: "#FF1493"
			}]
		});
}
function graphNumberFormat(val, name) {
    var reportType = name;
    if (reportType === 'CTR') {
        return val + '%';
    }
    if (reportType === 'COST' || reportType === 'CPC') {
		return '¥' + val;
    }
	reportType = reportType.split("_");
	if (reportType[1] === "CVR" || reportType[1] === "ROAS" || reportType[1] === "ROI")
		return val + '%';
	
	if (reportType[1] === 'CPA' || reportType[1] === 'SALES' || reportType[1] === "PROFIT") {
		return '¥' + val;
    }

    return val;
}
function sub_ja(str){
	if (str.length > 14) return str.substring(0,13) + "..."
	else return str;
}
