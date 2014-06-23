function createCookie(name, value, days) {
	localStorage.setItem(name, value);
}

function readCookie(name) {
	return localStorage.getItem(name);
}

function toggleInherited(el) {
	var toggle = $(el).closest(".toggle");
	toggle.toggleClass("toggle-on");
	if (toggle.hasClass("toggle-on")) {
		$("img", toggle).attr("src", dox.rootPath + "triangle-opened.png");
	} else {
		$("img", toggle).attr("src", dox.rootPath + "triangle-closed.png");
	}
    return false;
}

function toggleCollapsed(el) {
	var toggle = $(el).closest(".expando");
	toggle.toggleClass("expanded");

	if (toggle.hasClass("expanded")) {
		$("img", toggle).first().attr("src", dox.rootPath + "triangle-opened.png");
	} else {
		$("img", toggle).first().attr("src", dox.rootPath + "triangle-closed.png");
	}
	updateTreeState();
    return false;
}

function updateTreeState(){
	var states = [];
	$("#nav .expando").each(function(i, e){
		states.push($(e).hasClass("expanded") ? 1 : 0);
	});
	var treeState = JSON.stringify(states);
	createCookie("treeState", treeState);
}

var filters = {};

function selectPlatform(e) {
	setPlatform($(e.target).parent().attr("data"));
}

function selectVersion(e) {
	setVersion($(e.target).parent().attr("data"));
}

function setPlatform(platform) {
	selectItem("platform", platform);
	
	var styles = ".platform { display:none }";
	var platforms = dox.platforms;

	for (var i = 0; i < platforms.length; i++)
	{
		var p = platforms[i];
		
		if (platform == "sys")
		{
			if (p != "flash" && p != "flash8" && p != "js")
			{
				styles += ".platform-" + p + " { display:inherit } ";
			}
		}
		else
		{
			if (platform == "all" || p == platform)
			{
				styles += ".platform-" + p + " { display:inherit } ";
			}
		}
	}
	
	if (platform != "flash" && platform != "flash8" && platform != "js")
	{
		styles += ".platform-sys { display:inherit } ";
	}

	$("#dynamicStylesheet").text(styles);
}

function setVersion(version) {
	selectItem("version", version);
}

function selectItem(filter, value)
{
	var dropdown = $("#select-" + filter);
	var item = $("li[data='"+value+"']", dropdown);
	var label = $("a", item).text();
	$(".dropdown-toggle", dropdown).html(label + '<b class="caret">');
	$("li.active", dropdown).removeClass("active");
	item.addClass("active");
	createCookie(filter, value);
}

$(document).ready(function(){
	$("#nav").html(navContent);
	var treeState = readCookie("treeState");

	$("#nav .expando").each(function(i, e){
		$("img", e).first().attr("src", dox.rootPath + "triangle-closed.png");
	});

	$(".treeLink").each(function() {
		this.href = this.href.replace("::rootPath::", dox.rootPath);
	});

	if (treeState != null)
	{
		var states = JSON.parse(treeState);
		$("#nav .expando").each(function(i, e){
			if (states[i]) {
				$(e).addClass("expanded");
				$("img", e).first().attr("src", dox.rootPath + "triangle-opened.png");
			}
		});
	}
	$("head").append("<style id='dynamicStylesheet'></style>");

	setPlatform(readCookie("platform") == null ? "all" : readCookie("platform"));
	setVersion(readCookie("version") == null ? "3_0" : readCookie("version"));

	$("#search").on("input", function(e){
		searchQuery(e.target.value);
	});

	$("#nav a").each(function () {
		if (this.href == location.href) {
			$(this.parentElement).addClass("active");
		}
	});

    // Because there is no CSS parent selector
    $("code.prettyprint").parents("pre").addClass("example");
});

function searchQuery(query) {
	query = query.toLowerCase();
	$("#searchForm").removeAttr("action");
	if (query == "") {
		$("#nav").removeClass("searching");
		$("#nav li").each(function(index, element){
			var e = $(element);
			e.css("display", "");
		});
		return;
	}
	
	console.log("Searching: "+query);

	var searchSet = false;
	
	$("#nav").addClass("searching");
	$("#nav li").each(function(index, element){
		var e = $(element);
		if (!e.hasClass("expando")) {
			var content = e.attr("data_path").toLowerCase();
			var match = searchMatch(content, query);
			if (match && !searchSet) {
				var url = dox.rootPath + e.attr("data_path").split(".").join("/") + ".html";
				$("#searchForm").attr("action", url);
				searchSet = true;
			}
			e.css("display", match ? "" : "none");
		}
	});
	
}

function searchMatch(text, query) {
	// I should be working at Google.
	return text.indexOf(query) > -1;
}
