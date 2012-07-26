/*
 * YUI Extensions 0.33 RC2
 * Copyright(c) 2006, Jack Slocum.
 */


YAHOO.ext.View=function(container,tpl,dataModel,config){this.el=getEl(container,true);this.nodes=this.el.dom.childNodes;if(typeof tpl=='string'){tpl=new YAHOO.ext.Template(tpl);}
tpl.compile();this.tpl=tpl;this.setDataModel(dataModel);var CE=YAHOO.util.CustomEvent;this.events={'click':new CE('click'),'dblclick':new CE('dblclick'),'contextmenu':new CE('contextmenu'),'selectionchange':new CE('selectionchange')};this.el.mon("click",this.onClick,this,true);this.el.mon("dblclick",this.onDblClick,this,true);this.el.mon("contextmenu",this.onContextMenu,this,true);this.selectedClass='ydataview-selected';this.selections=[];this.lastSelection=null;this.jsonRoot=null;YAHOO.ext.util.Config.apply(this,config);if(this.renderUpdates||this.jsonRoot){var um=this.el.getUpdateManager();um.setRenderer(this);}};YAHOO.extendX(YAHOO.ext.View,YAHOO.ext.util.Observable,{getEl:function(){return this.el;},render:function(el,response){this.clearSelections();this.el.update('');var o;try{o=YAHOO.ext.util.JSON.decode(response.responseText);if(this.jsonRoot){o=eval('o.'+this.jsonRoot);}}catch(e){}
if(o&&o.length){this.html=[];for(var i=0,len=o.length;i<len;i++){this.renderEach(o[i]);}
this.el.update(this.html.join(''));this.html=null;this.nodes=this.el.dom.childNodes;this.updateIndexes(0);}},refresh:function(){this.clearSelections();this.el.update('');this.html=[];this.dataModel.each(this.renderEach,this);this.el.update(this.html.join(''));this.html=null;this.nodes=this.el.dom.childNodes;this.updateIndexes(0);},prepareData:function(data,index){return data;},renderEach:function(data){this.html[this.html.length]=this.tpl.applyTemplate(this.prepareData(data));},refreshNode:function(index){this.refreshNodes(index,index);},refreshNodes:function(dm,startIndex,endIndex){this.clearSelections();var dm=this.dataModel;var ns=this.nodes;for(var i=startIndex;i<=endIndex;i++){var d=this.prepareData(dm.getRow(i),i);if(i<ns.length-1){var old=ns[i];this.tpl.insertBefore(old,d);this.el.dom.removeChild(old);}else{this.tpl.append(this.el.dom,d);}}
this.updateIndexes(startIndex,endIndex);},deleteNodes:function(dm,startIndex,endIndex){this.clearSelections();if(startIndex==0&&endIndex>=this.nodes.length-1){this.el.update('');}else{var el=this.el.dom;for(var i=startIndex;i<=endIndex;i++){el.removeChild(this.nodes[startIndex]);}
this.updateIndexes(startIndex);}},insertNodes:function(dm,startIndex,endIndex){if(this.nodes.length==0){this.refresh();}else{this.clearSelections();var t=this.tpl;var before=this.nodes[startIndex];var dm=this.dataModel;if(before){for(var i=startIndex;i<=endIndex;i++){t.insertBefore(before,this.prepareData(dm.getRow(i),i));}}else{var el=this.el.dom;for(var i=startIndex;i<=endIndex;i++){t.append(el,this.prepareData(dm.getRow(i),i));}}
this.updateIndexes(startIndex);}},updateIndexes:function(dm,startIndex,endIndex){var ns=this.nodes;startIndex=startIndex||0;endIndex=endIndex||ns.length-1;for(var i=startIndex;i<=endIndex;i++){ns[i].nodeIndex=i;}},setDataModel:function(dm){if(!dm)return;this.unplugDataModel(this.dataModel);this.dataModel=dm;dm.on('cellupdated',this.refreshNode,this,true);dm.on('datachanged',this.refresh,this,true);dm.on('rowsdeleted',this.deleteNodes,this,true);dm.on('rowsinserted',this.insertNodes,this,true);dm.on('rowsupdated',this.refreshNodes,this,true);dm.on('rowssorted',this.refresh,this,true);this.refresh();},unplugDataModel:function(dm){if(!dm)return;dm.removeListener('cellupdated',this.refreshNode,this);dm.removeListener('datachanged',this.refresh,this);dm.removeListener('rowsdeleted',this.deleteNodes,this);dm.removeListener('rowsinserted',this.insertNodes,this);dm.removeListener('rowsupdated',this.refreshNodes,this);dm.removeListener('rowssorted',this.refresh,this);this.dataModel=null;},findItemFromChild:function(node){var el=this.el.dom;if(!node||node.parentNode==el){return node;}
var p=node.parentNode;while(p&&p!=el){if(p.parentNode==el){return p;}
p=p.parentNode;}
return null;},onClick:function(e){var item=this.findItemFromChild(e.getTarget());if(item){var index=this.indexOf(item);this.onItemClick(item,index,e);this.fireEvent('click',this,index,item,e);}else{this.clearSelections();}},onContextMenu:function(e){var item=this.findItemFromChild(e.getTarget());if(item){this.fireEvent('contextmenu',this,this.indexOf(item),item,e);}},onDblClick:function(e){var item=this.findItemFromChild(e.getTarget());if(item){this.fireEvent('dblclick',this,this.indexOf(item),item,e);}},onItemClick:function(item,index,e){if(this.multiSelect||this.singleSelect){if(this.multiSelect&&e.shiftKey&&this.lastSelection){this.select(this.getNodes(this.indexOf(this.lastSelection),index),false);}else{this.select(item,this.multiSelect&&e.ctrlKey);this.lastSelection=item;}}},getSelectionCount:function(){return this.selections.length;},getSelectedNodes:function(){return this.selections;},getSelectedIndexes:function(){var indexes=[];for(var i=0,len=this.selections.length;i<len;i++){indexes.push(this.selections[i].nodeIndex);}
return indexes;},clearSelections:function(suppressEvent){if(this.multiSelect||this.singleSelect){YAHOO.util.Dom.removeClass(this.selections,this.selectedClass);this.selections=[];if(!suppressEvent){this.fireEvent('selectionchange',this,this.selections);}}},select:function(nodeInfo,keepExisting,suppressEvent){if(!keepExisting){this.clearSelections(true);}
if(nodeInfo instanceof Array){for(var i=0,len=nodeInfo.length;i<len;i++){this.select(nodeInfo[i],true,true);}}else{var node=this.getNode(nodeInfo);if(node){YAHOO.util.Dom.addClass(node,this.selectedClass);this.selections.push(node);}}
if(!suppressEvent){this.fireEvent('selectionchange',this,this.selections);}},getNode:function(nodeInfo){if(typeof nodeInfo=='object'){return nodeInfo;}else if(typeof nodeInfo=='string'){return document.getElementById(nodeInfo);}else if(typeof nodeInfo=='number'){return this.nodes[nodeInfo];}
return null;},getNodes:function(start,end){var ns=this.nodes;startIndex=startIndex||0;endIndex=typeof endIndex=='undefined'?ns.length-1:endIndex;var nodes=[];for(var i=start;i<=end;i++){nodes.push(ns[i]);}
return nodes;},indexOf:function(node){node=this.getNode(node);if(typeof node.nodeIndex=='number'){return node.nodeIndex;}
var ns=this.nodes;for(var i=0,len=ns.length;i<len;i++){if(ns[i]==node){return i;}}
return-1;}});YAHOO.ext.JsonView=function(container,tpl,config){var cfg=config||{};cfg.renderUpdates=true;YAHOO.ext.JsonView.superclass.constructor.call(this,container,tpl,null,cfg);};YAHOO.extendX(YAHOO.ext.JsonView,YAHOO.ext.View,{load:function(){var um=this.el.getUpdateManager();um.update.apply(um,arguments);}});