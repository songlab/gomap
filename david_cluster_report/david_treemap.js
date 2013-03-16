var labelType, useGradients, nativeTextSupport, animate;

(function() {
  var ua = navigator.userAgent,
      iStuff = ua.match(/iPhone/i) || ua.match(/iPad/i),
      typeOfCanvas = typeof HTMLCanvasElement,
      nativeCanvasSupport = (typeOfCanvas == 'object' || typeOfCanvas == 'function'),
      textSupport = nativeCanvasSupport 
        && (typeof document.createElement('canvas').getContext('2d').fillText == 'function');
  //I'm setting this based on the fact that ExCanvas provides text support for IE
  //and that as of today iPhone/iPad current text support is lame
    labelType = (!nativeCanvasSupport || (textSupport && !iStuff))? 'Native' : 'HTML';
  nativeTextSupport = labelType == 'Native';
  useGradients = nativeCanvasSupport;
  animate = !(iStuff || !nativeCanvasSupport);
})();

var Log = {
  elem: false,
  write: function(text){
    if (!this.elem) 
      this.elem = document.getElementById('log');
    this.elem.innerHTML = text;
    this.elem.style.left = (500 - this.elem.offsetWidth / 2) + 'px';
  }
};


function init(){
  //init data
    var json = json_data;
  //end
  //init TreeMap
  var tm = new $jit.TM.Squarified({
    //where to inject the visualization
    injectInto: 'infovis',
    //show only one tree level
    levelsToShow: 1,
    //parent box title heights
    titleHeight: 0,
    //enable animations
    animate: animate,
    //box offsets
    offset: 1,
    //use canvas text
//    Label: {
//	type:labelType,
//      size: 20,
//      family: 'Tahoma, Verdana, Arial'
//    },
      NodeStyles: {  
	  enable: true,  
	  type: 'Native',  
	  stylesHover: {    
	      color: '#fcc'  
	  },  
	  duration: 600  
      },  
    //enable specific canvas styles
    //when rendering nodes
    Node: {
      CanvasStyles: {
        shadowBlur: 0,
        shadowColor: '#000'
      }
    },
    //Attach left and right click events
    Events: {
      enable: true,
      onClick: function(node) {
		  if(node) {
		      tm.enter(node);
		  }
      },
      onRightClick: function() {
        tm.out();
      },
      //change node styles and canvas styles
      //when hovering a node
      onMouseEnter: function(node, eventInfo) {
        if(node) {
          //add node selected styles and replot node
//          node.setCanvasStyle('shadowBlur', 20);
	  //node.setData('oldcolor',node.getData('color'));
          //node.setData('color', '#B22222');
//          tm.fx.plotNode(node, tm.canvas);
 //         tm.labels.plotLabel(tm.canvas, node);
        }
      },
      onMouseLeave: function(node) {
        if(node) {
	    //node.setData('color',node.getData('oldcolor'));
 //         node.removeCanvasStyle('shadowBlur');
 //         tm.plot();
        }
      }
    },
    //duration of the animations
    duration: 1000,
    //Enable tips
    Tips: {
      enable: true,
      type: 'Native',
      //add positioning offsets
      offsetX: 20,
      offsetY: -100,
      //implement the onShow method to
      //add content to the tooltip when a node
      //is hovered
      onShow: function(tip, node, isLeaf, domElement) {
        var html = "<div class=\"tip-title\">" + node.name 
          + "</div><div class=\"tip-text\">";
        var data = node.data;
	var nd=node._depth;
	if(data.score&&nd==1) {
	    html += "<p>Enrichment score: "+data.score+"</p>";
	}
	if(data.pval&&nd==2) {
	    html += "<p>P-value: "+data.pval+"</p>";
	}
	if(data.ont&&(nd==1||nd==2)) {
	    html += "<p>Ontology: "+data.ont+"</p>";
	}
	if(data.def&&(nd==1||nd==2)) {
	    html += "<p>Definition: "+data.def+"</p>";
	}
	if(data.go&&(nd==1||nd==2)) {
	    html += "<p>GO:"+data.go+"</p>";
	}
	if(data.fc&&nd==3) {
	    html += "<p>Treatment over control gene expression<br> fold change: "+data.fc+"</p>";
	}
	if(data.pvl&&nd==3) {
	    html += "<p>Gene differential<br>expression p-value: "+data.pvl+"</p>";
	}
	if(data.rank&&nd==3) {
	    html += "<p>Expression fold change rank: "+data.rank+"</p>";
	}
        //if(data.gns) {
        //  html += "Genes: " + data.gns + "<br />";
        //}
        tip.innerHTML =  html; 
      }  
    },
    //Implement this method for retrieving a requested  
    //subtree that has as root a node with id = nodeId,  
    //and level as depth. This method could also make a server-side  
    //call for the requested subtree. When completed, the onComplete   
    //callback method should be called.  
    request: function(nodeId, level, onComplete){  
      var tree = eval('(' + json + ')');  
      var subtree = $jit.json.getSubtree(tree, nodeId);  
      $jit.json.prune(subtree, 1);  
      onComplete.onComplete(nodeId, subtree);  
    },
    //Add the name of the node in the corresponding label
    //This method is called once, on label creation and only for DOM labels.
    onCreateLabel: function(domElement, node){
        domElement.innerHTML = node.name;
	  }
  });
  
  var pjson = eval('(' + json + ')');  
  $jit.json.prune(pjson, 1);
  
  tm.loadJSON(pjson);
  tm.refresh();
  //end
  var sq = $jit.id('r-sq'),
      st = $jit.id('r-st'),
      sd = $jit.id('r-sd');
  var util = $jit.util;
  util.addEvent(sq, 'change', function() {
    if(!sq.checked) return;
    util.extend(tm, new $jit.Layouts.TM.Squarified);
    tm.refresh();
  });
  util.addEvent(st, 'change', function() {
    if(!st.checked) return;
    util.extend(tm, new $jit.Layouts.TM.Strip);
    tm.layout.orientation = "v";
    tm.refresh();
  });
  util.addEvent(sd, 'change', function() {
    if(!sd.checked) return;
    util.extend(tm, new $jit.Layouts.TM.SliceAndDice);
    tm.layout.orientation = "v";
    tm.refresh();
  });
  //add event to the back button
  var back = $jit.id('back');
  $jit.util.addEvent(back, 'click', function() {
    tm.out();
  });
}
