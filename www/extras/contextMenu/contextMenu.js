var ie5=document.all&&document.getElementById
var contextMenu_items = new Array();

if (contextMenu_old == undefined)
{
  var contextMenu_old = (document.onclick) ? document.onclick : function () {};
  document.onclick= function () {contextMenu_old();contextMenu_hide();};
}

function contextMenu_renderLeftClick(menuId,e) {
	contextMenu_hide(e);
	contextMenu_show(menuId,e);
	e.cancelBubble=true;
	e.returnValue=false;
	return false;
} 


function contextMenu_show(menuId,e){
	var menuobj=document.getElementById(menuId)
	var posx = 0;
	var posy = 0;
	var yoffset = 0;
	var xoffset = 0;
var firedobj = ie5?e.srcElement:e.target;
    while (firedobj!=null && firedobj.tagName!="HTML"){
                //this is a hack, need to revisit
                if (firedobj.tagName == "DIV") {
                xoffset+=firedobj.offsetLeft;
                yoffset+=firedobj.offsetTop;}
            firedobj=firedobj.offsetParent;
   }
    var el = (document.documentElement && document.documentElement.scrollTop)
        ? document.documentElement : document.body;
               posx = e.clientX - xoffset + (ie5? el.scrollLeft : window.pageXOffset);
               posy = e.clientY - yoffset + (ie5? el.scrollTop : window.pageYOffset);
	menuobj.style.left=posx + "px";
	menuobj.style.top=posy + "px";
      menuobj.style.visibility="visible"
	return false
}

function contextMenu_hide(){
	for (i=0;i<contextMenu_items.length;i++) {
		document.getElementById("contextMenu_"+contextMenu_items[i]+"_menu").style.visibility="hidden"
	}
	return false;
}

function contextMenu_createWithImage(imagePath, id, name, addContext){
	contextMenu_items.push(id);
	this.id = id;
	this.name = name;
	this.addContext = addContext;
	this.type = "image";
	this.imagePath=imagePath;
	this.linkLabels = new Array();
	this.linkUrls = new Array();
	this.draw = contextMenu_draw;
	this.print = contextMenu_print;
	this.addLink = contextMenu_addLink;
}

function contextMenu_createWithLink(id, name){
	contextMenu_items.push(id);
	this.id = id;
	this.name = name;
	this.type = "link";
	this.linkLabels = new Array();
	this.linkUrls = new Array();
	this.draw = contextMenu_draw;
	this.print = contextMenu_print;
	this.addLink = contextMenu_addLink;
}

function contextMenu_draw(){
	var output = "";
	output += '<div id="contextMenu_' + this.id + '_menu" class="contextMenu_skin">';
	for (i=0;i<this.linkUrls.length;i++) {
		output += "<a style=\"color: black;\" href=\"" + this.linkUrls[i] + "\">" + this.linkLabels[i] + "</a><br />";
	}
	output += '</div>';
	if (this.type == "image") {
                if (this.addContext)
                        output += '<p class="toolbarIcon" style="display: inline; vertical-align: middle;"><a href="javascript:void(0)">';
                output += '<img src="' + this.imagePath + '" id="contextMenu_' + this.id + '_2" onclick="return contextMenu_renderLeftClick(\'contextMenu_' + this.id + '_menu\',event)" alt="' + this.name + '" title="' + this.name + '" align="absmiddle" ';
                if (this.addContext)
                        output += 'style="border: 0px none; vertical-align: middle;"';
                output += ' />';
                if (this.addContext)
                        output += '</a></p>';
	} else {
		output += '<a href="#" id="contextMenu_' + this.id + '" onclick="return contextMenu_renderLeftClick(\'contextMenu_' + this.id + '_menu\',event)">' + this.name + '</a>';
	}
	return output;
}

function contextMenu_print(){
	document.write(this.draw());
}

function contextMenu_addLink(linkUrl,linkLabel){
	this.linkUrls.push(linkUrl);
	this.linkLabels.push(linkLabel);
}

