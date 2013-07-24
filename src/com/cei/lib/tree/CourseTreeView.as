package com.cei.lib.tree
{
	import br.ederlima.ui.List;
	import br.ederlima.ui.ListItem;
	import br.ederlima.ui.TreeView;
	import br.ederlima.ui.events.ListItemEvent;
	import br.ederlima.ui.events.TreeItemEvent;
	import br.ederlima.ui.events.TreeViewEvent;
	import br.ederlima.ui.icons.IconClosedFolder;
	import br.ederlima.ui.icons.IconItem;
	import br.ederlima.ui.styles.FolderItemStyle;
	import br.ederlima.ui.styles.ListItemStyle;
	import br.ederlima.ui.types.ListItemType;
	
	import fl.containers.ScrollPane;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.printing.PrintJob;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import org.as3commons.collections.LinkedMap;
	import org.as3commons.collections.fx.LinkedMapFx;
	
	public class CourseTreeView extends MovieClip
	{
		
		private var list:List = new List();
		private var _xmloader:URLLoader = new URLLoader();
		private var st:ListItemStyle = new ListItemStyle();
		private var tree:TreeView = new TreeView();
		private var pane:ScrollPane = new ScrollPane();
		private var bgSprite:Sprite = new Sprite();
		
		public var visitedList:LinkedMapFx;		
		private var progress:TreeLoadProgress;
		private var timer:Timer = new Timer(800);
		private var isParsed:Boolean = false;
		
		public function CourseTreeView()
		{
			super();
		}
		
		
		public function populateTree(xml:String,list:LinkedMapFx):void 
		{
			
			
			tree.visitedList = list;
			this.visitedList = list;
			trace("---------------------->   "+this.visitedList.keysToArray().toString())
			tree.dataProvider = XML(xml);
			tree.listStyle = new ListItemStyle(new TextFormat("Arial", "12", 0x000000, false, false), "FFFFFF", "F0F0F0");
			tree.folderStyle = new FolderItemStyle(new TextFormat("Arial", "12", 0x333333, true, false), "FFFFFF", "FFFFFF");
			//tree.margin = 5;
			tree.itemWidth = 850;
			tree.itemHeight = 522;
			tree.addEventListener(TreeItemEvent.ITEM_CLICK_PLAY, itemClicked);
			tree.addEventListener(TreeItemEvent.ITEM_CLICK, itemClick);
			/*tree.addEventListener(TreeItemEvent.ITEM_ROLL_OVER, itemOver);
			tree.addEventListener(TreeItemEvent.ITEM_ROLL_OUT, itemOut);
			
			
			tree.addEventListener(TreeItemEvent.FOLDER_ROLL_OVER, folderOver);
			tree.addEventListener(TreeItemEvent.FOLDER_ROLL_OUT, folderOut);
			tree.addEventListener(TreeItemEvent.FOLDER_CLICK, folderClick);*/
			
			tree.addEventListener(TreeViewEvent.SEARCH_SUCCESS, onSearch);
			tree.addEventListener(TreeViewEvent.SEARCH_ERROR, onSearchError);
			tree.addEventListener(TreeViewEvent.EXPAND_TREE,onExpand);
			tree.addEventListener(TreeViewEvent.CREATION_COMPLETE,onComplete);
			
			addChild(tree);
			//tree.findItem("03_03_01_01");
			//bb.addEventListener(MouseEvent.CLICK, onStageClick);
			//tree.expandAll();
		}
		
		private function onComplete(event:TreeViewEvent):void	{
			//trace("Completed!!");
			//tree.expandAll();
			progress = new TreeLoadProgress();
			this.addChild(progress);
			timer.addEventListener(TimerEvent.TIMER,onTimerComplete);
			timer.start();
			isParsed = false;
		}
		private function onTimerComplete(event:TimerEvent):void	{
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER,onTimerComplete);
			timer = null;
			tree.expandAll();
			
		}
		private function onExpand(event:TreeViewEvent):void	{
			if(!isParsed)	{
				this.removeChild(progress);
			}
			isParsed = true;
		}
		
		private function setBg():void	{
			bgSprite = new Sprite();
			bgSprite.graphics.beginFill(0xFFEEDD,1);
			bgSprite.graphics.drawRect(0,0,850,600);
			bgSprite.graphics.endFill();
			this.addChild(bgSprite)
		}
		
		public function expandAll():void	{
			tree.expandAll();
		}
		public function collapseAll():void	{
			tree.collapseAll();
		}
		public function setVisited(list:LinkedMapFx):void	{
			tree.visitedList = list;
			trace(list.keysToArray().toString())
		}
		public function get coursejson():String	{
			return tree.courseJson;
		}
		public function move(x:Number,y:Number):void	{ this.x = x; this.y = y;}
		
		public function printCourse():void	{
			tree.printTree();
		}
		private function itemClicked(event:TreeItemEvent):void		{			
			this.dispatchEvent(event);
		}
		private function onSearchError(event:TreeViewEvent):void 	{			/*trace("Não existe");*/		}
		
		private function onSearch(event:TreeViewEvent):void 		{			trace(event.currentItem.label);		}
		//actions sobre os folders
		private function folderClick(event:TreeItemEvent):void 		{			trace( "click folder");		}
		private function folderOut(event:TreeItemEvent):void 		{			trace( "out folder");		}
		
		private function folderOver(event:TreeItemEvent):void 		{			trace( "over folder");		}
		//actions sobre os itens
		private function itemClick(event:TreeItemEvent):void 		{			/*trace(":::::::::::::::::::"+event.currentItem)*/	}
		private function itemOut(event:TreeItemEvent):void 			{			trace( "out item");		}
		
		private function itemOver(event:TreeItemEvent):void 		{			trace( "over item");		}
		
		private function onStageClick(event:MouseEvent):void 		{			tree.findItem("03_03_01_01");		}
	}
}