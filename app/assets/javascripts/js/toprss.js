google.load("feeds", "1");

function initialize() {
	
  var feedurl = "http://www.septeni-holdings.co.jp/cp.xml";
  var feed = new google.feeds.Feed(feedurl);
  feed.setNumEntries(7);
  feed.load(dispfeed);

  function dispfeed(result){
    if (!result.error){
      var container = document.getElementById("feed");
      var htmlstr = "";
      /*htmlstr += '<h2><a href="' + result.feed.link + '">' + result.feed.title + '</a></h2>';
      htmlstr += "<p>" + result.feed.description + "</p>";*/

    // htmlstr += "<ul>";
      for (var i = 0; i < result.feed.entries.length; i++) {
        var entry = result.feed.entries[i];
				
				var is_publicities = /publicities/.test(entry.link);
				if (result.feed.entries.length == i+1)
                    htmlstr += "<ul class=" + (is_publicities ? 'last-child' : 'last-child') + ">" + (is_publicities ? "" : "<a href='" + entry.link + "' target=_blank>");
                else
                    htmlstr += "<ul class=" + (is_publicities ? 'txtlist2' : 'txtlist') + ">" + (is_publicities ? "" : "<a href='" + entry.link + "' target=_blank>");
				
				 var strdate = createDateString(entry.publishedDate);
				  var test = createDateString(entry.author);
					
					var categorie = entry.categories[i];
				 
        htmlstr += "<li class=listdate>" + strdate + "</li>";
				
        htmlstr += '<li class=listtit>' + entry.title + '</li>' + (is_publicities ? '' : '</a>');

       
        htmlstr += "</ul>"
      }
     // htmlstr += "</ul>";

       container.innerHTML = htmlstr;
    }else{
       alert(result.error.code + ":" + result.error.message);
    }
  }
}

function createDateString(publishedDate){
  var pdate = new Date(publishedDate);

  var pday = pdate.getDate();
  var pmonth = pdate.getMonth() + 1;
  var pyear = pdate.getFullYear();
  var phour = pdate.getHours();
  var pminute = pdate.getMinutes();
  var psecond = pdate.getSeconds();
  var strdate = pyear + "/" + pmonth + "/" + pday;

  return strdate;
}

google.setOnLoadCallback(initialize);
