$(document).ready(function () {
    $(".inline").colorbox({inline: true, width: "635", height: "550" });

    $(".newTable04").flexigrid({
        url: "<%= get_urls_list_url_settings_path %>?promotion_id=" + $("#promotion_id").val() + "&account_id=" + $("#account_id").val() + "&media_id=" + $("#media_id").val(),
        dataType: 'json',
        editOption: true,
        deleteOption: true,
        onSuccess: function () {
            tableResize();
        },
        resizable: false,
        striped: true,
        colModel: [
            {display: 'edit_button', name: 'edit_button', width: 'auto', sortable: false, align: 'center'},
            {display: 'ad_id', name: 'ad_id', width: 'auto', sortable: false, align: 'center'},
            {display: 'campaign_name', name: 'campaign_name', width: 'auto', sortable: false, align: 'center'},
            {display: 'group_name', name: 'group_name', width: 'auto', sortable: false, align: 'center'},
            {display: 'ad_name', name: 'ad_name', width: 'auto', sortable: false, align: 'center'},
            {display: 'url', name: 'url', width: 'auto', sortable: false, align: 'center'},
            {display: 'copy', name: 'copy', width: 'auto', sortable: false, align: 'center'},
            {display: 'delete_check', name: 'delete_check', width: 'auto', sortable: false, align: 'center'}
        ],
        usepager: true,
        title: 'Url List',
        useRp: true,
        id: 1,
        promotion_id: 1,
        media_id: 1,
        account_id: 1,
        rp: 10,
        showTableToggleBtn: true,
        height: 250
    });


    var tab = {
        init: function(){
            var tabs = this.setup.tabs;
            var pages = this.setup.pages;

            for(i=0; i<pages.length; i++) {
                if(i !== 0) pages[i].style.display = 'none';
                tabs[i].onclick = function(){ tab.showpage(this); return false; };
            }
        },

        showpage: function(obj){
            var tabs = this.setup.tabs;
            var pages = this.setup.pages;
            var num;

            for(num=0; num<tabs.length; num++) {
                if(tabs[num] === obj) break;
            }

            for(var i=0; i<pages.length; i++) {
                if(i == num) {
                    pages[num].style.display = 'block';
                    tabs[num].className = 'present';
                }
                else{
                    pages[i].style.display = 'none';
                    tabs[i].className = null;
                }
            }
        }
    }
    function formatDate(year, month, day) {
        if (year < 2000) {
            year = parseInt(year) + 1900;
        }
        if (month.length == 1) {
            month = "0" + parseInt(month);
        }
        if (day.length == 1) {
            day = "0" + parseInt(day);
        }
        return year + "/" + month + "/" + day;
    }

    $('#datepick').daterangepicker({
        onDone: function () {
            var term = $('#datepick').val();
            var d = term.split(' - ');
            var f = (d[0]).split('/');
            var t = (d[1]).split('/');
            $.cookie("s", formatDate(f[0], f[1], f[2]), {
                path: '/'
            });
            $.cookie("e", formatDate(t[0], t[1], t[2]), {
                path: '/'
            });

            reloadFlex1(".newTable04", "<%= get_urls_list_url_settings_path %>?promotion_id=" + $("#promotion_id").val() + "&account_id=" + $("#account_id").val() + "&media_id=" + $("#media_id").val());
        }
    });
// <![CDATA[
    tab.setup = {
        tabs: document.getElementById('tab').getElementsByTagName('li'),

        pages: [
            document.getElementById('page1'),
            document.getElementById('page2'),
            document.getElementById('page3')
        ]
    } //オブジェクトをセット
    tab.init(); //起動！

// ]]>
})