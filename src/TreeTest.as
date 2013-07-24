package  
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
	
	import com.cei.lib.tree.CourseTreeView;
	
	import fl.containers.ScrollPane;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextFormat;
	
	import flashx.textLayout.container.ScrollPolicy;
	
	import org.as3commons.collections.fx.LinkedMapFx;
	
	/**
	 * ...
	 * @author Eder Lima
	 */
	public class TreeTest extends Sprite
	{
		private var list:List = new List();
		private var _xmloader:URLLoader = new URLLoader();
		private var st:ListItemStyle = new ListItemStyle();
		private var tree:TreeView = new TreeView();
		private var pane:ScrollPane = new ScrollPane();
		private var ctree:CECourseTreeView;
		
		public var bbb:MovieClip;
		public var bb:MovieClip;
		
		public function TreeTest() 
		{
			_xmloader.addEventListener(Event.COMPLETE, xmlComplete);
			_xmloader.load(new URLRequest("data.xml"));
			//TweenPlugin.activate([TintPlugin, RemoveTintPlugin]);
		}
		
		private function xmlComplete(event:Event):void 
		{
			var list:LinkedMapFx = new LinkedMapFx();
			list.add("1.1",{})
			list.add("1.2",{})
			list.add("2.1",{})
			ctree = new CECourseTreeView();
			ctree.populateTree(event.target.data,list);
			
			
			/*tree.dataProvider = XML(event.target.data);
			tree.listStyle = new ListItemStyle(new TextFormat("Arial", "12", 0x000000, false, false), "FFFFFF", "F0F0F0");
			tree.folderStyle = new FolderItemStyle(new TextFormat("Arial", "12", 0x333333, true, false), "FFFFFF", "FFFFFF");
			tree.margin = 5;
			tree.itemWidth = 850;
			tree.itemHeight = 600;*/
			/*tree.addEventListener(TreeItemEvent.ITEM_ROLL_OVER, itemOver);
			tree.addEventListener(TreeItemEvent.ITEM_ROLL_OUT, itemOut);
			tree.addEventListener(TreeItemEvent.ITEM_CLICK, itemClick);
			
			tree.addEventListener(TreeItemEvent.FOLDER_ROLL_OVER, folderOver);
			tree.addEventListener(TreeItemEvent.FOLDER_ROLL_OUT, folderOut);
			tree.addEventListener(TreeItemEvent.FOLDER_CLICK, folderClick);*/
			
			/*tree.addEventListener(TreeViewEvent.SEARCH_SUCCESS, onSearch);
			tree.addEventListener(TreeViewEvent.SEARCH_ERROR, onSearchError);
			
			addChild(tree);
			
			bb.addEventListener(MouseEvent.CLICK, onStageClick);*/
			
			this.addChild(ctree);
			//ctree.printCourse();
			bbb.addEventListener(MouseEvent.CLICK, printPage);
			bb.addEventListener(MouseEvent.CLICK, scrollPage);
			
			//trace("::::::::::"+ctree.coursejson)
		}
		private var count:Number = 0;
		private function scrollPage(event:MouseEvent):void {
			tree.scrollTree(count*522);
			count++;
		}
		private function printPage(event:MouseEvent):void {
			ctree.printCourse();
		}
		private function onSearchError(event:TreeViewEvent):void 
		{
			trace("Não existe");
		}
		
		private function onSearch(event:TreeViewEvent):void 
		{
			trace(event.currentItem.label);
		}
		//actions sobre os folders
		private function folderClick(event:TreeItemEvent):void 
		{
			trace( "click folder");
		}
		private function folderOut(event:TreeItemEvent):void 
		{
			trace( "out folder");
		}
		
		private function folderOver(event:TreeItemEvent):void 
		{
			trace( "over folder");
		}
		//actions sobre os itens
		private function itemClick(event:TreeItemEvent):void 
		{
			trace( "click item");
		}
		
		private function itemOut(event:TreeItemEvent):void 
		{
			trace( "out item");
		}
		
		private function itemOver(event:TreeItemEvent):void 
		{
			
			trace( "over item");
		}
		
		
		private function onStageClick(event:MouseEvent):void 
		{
			tree.findItem("03_03_01_01");
		}
		
		
		
	}
	
}