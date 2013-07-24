package br.ederlima.ui 
{
	import br.ederlima.ui.events.ListEvent;
	import br.ederlima.ui.events.ListItemEvent;
	import br.ederlima.ui.events.TreeItemEvent;
	import br.ederlima.ui.events.TreeViewEvent;
	import br.ederlima.ui.icons.IconClosedFolder;
	import br.ederlima.ui.icons.IconItem;
	import br.ederlima.ui.icons.IconOpenFolder;
	import br.ederlima.ui.styles.FolderItemStyle;
	import br.ederlima.ui.styles.ListItemStyle;
	import br.ederlima.ui.types.ListItemState;
	import br.ederlima.ui.types.ListItemType;
	
	import fl.containers.ScrollPane;
	import fl.controls.ScrollBarDirection;
	import fl.events.ScrollEvent;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.printing.PrintJob;
	import flash.printing.PrintJobOptions;
	import flash.printing.PrintJobOrientation;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	
	import org.as3commons.collections.fx.LinkedMapFx;
	
	/**
	 * 
	 * @author Eder Lima
	 */
	public class TreeView extends MovieClip 
	{
		private var _dataProvider:XML = new XML();
		private var _margin:int = 5;
		private var _marked:ListItem = null;
		private var _tempColor:String = "";
		private var _genericList:Dictionary = new Dictionary();
		private var _listStyle:ListItemStyle = new ListItemStyle();
		private var _folderStyle:FolderItemStyle = new FolderItemStyle();
		private var _itemWidth:Number = 250;
		private var _itemHeight:Number = 380;
		private var _treeContainer:MovieClip = new MovieClip();
		private var pane:ScrollPane = new fl.containers.ScrollPane();
		private var pages:Array = new Array();
		public var visitedList:LinkedMapFx;
		public  var slNo:Number = 0;
		
		public var courseJson:String = "";
		
		/**
		 * Construtor da Classe TreeView
		 * <br>É necessário adicionar um componente "ScrollPane" à biblioteca antes de utilizar esta Classe.
		 */		
		public function TreeView() 
		{
			this.addEventListener(Event.ADDED_TO_STAGE, initList);
		}
		/**
		 * Localizar um item na TreeView
		 * <br>Dispara os eventos TreeViewEvent.SEARCH_SUCCESS, retornando o objeto localizado e o evento TreeViewEvent.SEARCH_ERROR, 
		 * <br>quando não localizado, não retornando o mesmo item.
		 * <br>Ao localizar o item, ele é focado na TreeView
		 * @param	uniqueID Identificador único do item (String), é o parâmetro "id" utilizado em cada item no XML
		 */
		
		public function findItem(uniqueID:String):void
		{
			if (_genericList[uniqueID] != null)
			{
				openLists(genericList[uniqueID]);
				markItem(genericList[uniqueID]);
				this.dispatchEvent(new ListEvent(ListEvent.LIST_OPEN));
				this.dispatchEvent(new TreeViewEvent(TreeViewEvent.SEARCH_SUCCESS, _genericList[uniqueID] as ListItem));
			}
			else
			{
				this.dispatchEvent(new TreeViewEvent(TreeViewEvent.SEARCH_ERROR, null));
			}
		}
		

		
		/**
		 * Expande todos os itens da TreeView
		 */
		public function expandAll():void
		{
			var _root:List = _treeContainer.getChildByName("listItensContainer") as List;
			openList(_root);
			//createPages();
			
		}
		/**
		 * Fecha todos os itens abertos da TreeView
		 */
		public function collapseAll():void
		{
			var _root:List = _treeContainer.getChildByName("listItensContainer") as List;
			closeList(_root);
		}
		private function closeList(list:List):void
		{
			for each(var item:ListItem in list.itens)
			{
				if (item.type == ListItemType.TYPE_FOLDER)
				{
					if (item.state == ListItemState.OPEN)
					{
						closeItem(item);
					}
					if (item.containerList != null)
					{
						closeList(item.containerList);
					}
					refreshTreeView(list);
					pane.update();
				}
			}
		}
		private function openList(list:List):void
		{
			for each(var item:ListItem in list.itens)
			{
				if (item.type == ListItemType.TYPE_FOLDER)
				{
					if (item.state == ListItemState.CLOSED)
					{
						openItem(item);
					}
					
					if (item.containerList != null)
					{
						openList(item.containerList);
					}
					refreshTreeView(list);
					pane.update();
					this.dispatchEvent(new TreeViewEvent(TreeViewEvent.EXPAND_TREE,null,true));
				}
			}
			
			
		}
		private function openItem(item:ListItem):void
		{
			item.containerList.y = item.height;
			item.addChild(item.containerList);
			refreshTreeView(item.parentList);
			item.state = ListItemState.OPEN;
		}
		
		private function closeItem(item:ListItem):void
		{
			item.removeChild(item.containerList);
			item.state = ListItemState.CLOSED;
		}
		/********
		 * 
		 * 
		 * */
		
		private function initList(event:Event):void
		{
		
			
			this.removeEventListener(Event.ADDED_TO_STAGE, initList);
			pane.verticalScrollPolicy = "auto";
			pane.horizontalScrollPolicy = "off";
			pane.setSize(_itemWidth, _itemHeight);
			trace("initList"+this.visitedList.keysToArray().toString())
			createList(_dataProvider.children(), _treeContainer);
			pane.source = _treeContainer;
			pane.verticalLineScrollSize = 29;
			pane.verticalPageScrollSize = 29;
			pane.scrollDrag = false
			addChild(pane);
			pane.addEventListener(ScrollEvent.SCROLL, scrollHandler);
			this.dispatchEvent(new TreeViewEvent(TreeViewEvent.CREATION_COMPLETE,null));
		}
		
		function scrollHandler(event:ScrollEvent):void {
			switch (event.direction) {
				case ScrollBarDirection.HORIZONTAL:
					//trace("horizontal scroll", event.position, "of", event.currentTarget.maxHorizontalScrollPosition);
					break;
				case ScrollBarDirection.VERTICAL:
					
					
					event.stopImmediatePropagation();
					pane.removeEventListener(ScrollEvent.SCROLL, scrollHandler);
					pane.verticalScrollPosition += (event.position%29) ;
					pane.addEventListener(ScrollEvent.SCROLL, scrollHandler);
					break;
			}
		}
		
		private function createList(xmlList:XMLList, target:MovieClip):void
		{
			
			var list:List = new List();
			list.name = "listItensContainer";
			var inc:int = 0;
			for each(var item:XML in xmlList)
			{
				var listItem:ListItem;
				this.slNo ++;
				if (item.item.length() > 0)
				{
					_folderStyle.primaryIcon = cloneIcon(_folderStyle.primaryIcon);
					_folderStyle.secondaryIcon = cloneIcon(_folderStyle.secondaryIcon);
					listItem = new ListItem(ListItemType.TYPE_FOLDER, _listStyle, _folderStyle,{id:item.@id,duration:'',slNo:slNo});
				}
				else
				{
					_listStyle.primaryIcon = cloneIcon(_listStyle.primaryIcon);
					listItem = new ListItem(ListItemType.TYPE_ITEM,_listStyle, _folderStyle,{id:item.@id,duration:item.@duration,widget:item.@widget,slNo:slNo});
				}
				courseJson += "{\"Node_id\":\""+item.@id+"\",\"Node_name\":\""+String(item.@name).replace("\"","'")+"\",\"slNo\":\""+slNo+"\",\"type\":\""+listItem.type+"\"},";
				listItem.itemWidth = _itemWidth;
				listItem.parentList = list;
				/*listItem.alternateColor = "FFEEDD";
				listItem.backgroundColor = "DDEEFF";*/
					//
				listItem.uniqueId = item.@id;
				listItem.id = inc;
				listItem.label = item.@name;
				listItem.name = item.@id;
				listItem.isVisited = visitedList.hasKey(listItem.name);
				//trace(listItem.name+"::::::::::::::::"+listItem.isVisited)
				listItem.primaryValue = item.@primaryValue;
				listItem.secondaryValue = item.@secondaryValue;
				_genericList[listItem.uniqueId] = listItem;
				list.addItem(listItem);
				listItem.setAttempted()
				if (item.item.length() > 0)
				{
					createList(item.children(), listItem);
				}
				else
				{
					listItem.buttonMode = true;
				}
				listItem.addEventListener(ListItemEvent.LIST_ITEM_CLICK, itemClickHandler);
				listItem.addEventListener(ListItemEvent.LIST_ITEM_CLICKPLAY, itemPlayClickHandler);
				listItem.addEventListener(ListItemEvent.LIST_ITEM_OVER, itemOverHandler);
				listItem.addEventListener(ListItemEvent.LIST_ITEM_OUT, itemOutHandler);
				inc++;
				
			}
			
			if (target.numChildren > 0)
			{
				list.y = MovieClip(target.getChildAt(0)).y + MovieClip(target.getChildAt(0)).height;
				list.x = _margin;
				list.parentListItem = target as ListItem;
				ListItem(target).containerList = list as List;
			}
			else 
			{
				list.y = 0;
				target.addChild(list);
			}
			this.addEventListener(ListEvent.LIST_OPEN, onOpenList);
			
			
		}
		private function cloneIcon(icon:MovieClip):MovieClip
		{
			var r:MovieClip = null;
			if (icon != null)
			{
				var className:String = getQualifiedClassName(icon);
				var NewIcon:Class = getDefinitionByName(className) as Class;
				r = new NewIcon();
			}
			return r;
			
		}
		
		private function onOpenList(event:ListEvent = null):void 
		{
			refreshTreeView(_treeContainer.getChildByName("listItensContainer") as List);
			pane.update();
		}
		private function refreshTreeView(list:List):void
		{
			for each(var item:ListItem in list.itens)
			{
				item.parentList.refreshList();
				if (item.containerList !=null)
				{
					item.containerList.refreshList();
					refreshTreeView(item.containerList);
				}
			}
		}
		private function itemPlayClickHandler(event:ListItemEvent):void 	{
			if(event.currentItem.type == ListItemType.TYPE_ITEM)	{
				dispatchEvent(new TreeItemEvent(TreeItemEvent.ITEM_CLICK_PLAY, event.currentItem));
			}
		}
		private function itemClickHandler(event:ListItemEvent):void 
		{
			switch(event.currentItem.type)
			{
				case (ListItemType.TYPE_FOLDER) : 
				if (event.currentItem.state == ListItemState.OPEN)
				{
					event.currentItem.containerList.y = event.currentItem.height;
					event.currentItem.addChild(event.currentItem.containerList);
				}
				else
				{
					event.currentItem.removeChild(event.currentItem.containerList);
				}
				dispatchEvent(new TreeItemEvent(TreeItemEvent.FOLDER_CLICK, event.currentItem));
				break;
				case(ListItemType.TYPE_ITEM) :
				markItem(event.currentItem);
				dispatchEvent(new TreeItemEvent(TreeItemEvent.ITEM_CLICK, event.currentItem));
				break;
				
			}
			this.dispatchEvent(new ListEvent(ListEvent.LIST_OPEN));
		}
		private function itemOutHandler(event:ListItemEvent):void 
		{
			switch(event.currentItem.type)
			{
				case(ListItemType.TYPE_FOLDER) :
				dispatchEvent(new TreeItemEvent(TreeItemEvent.FOLDER_ROLL_OUT, event.currentItem));
				break;
				case(ListItemType.TYPE_ITEM) :
				dispatchEvent(new TreeItemEvent(TreeItemEvent.ITEM_ROLL_OUT, event.currentItem));
				break;
			}
		}
		
		private function itemOverHandler(event:ListItemEvent):void 
		{
			switch(event.currentItem.type)
			{
				case(ListItemType.TYPE_FOLDER) :
				dispatchEvent(new TreeItemEvent(TreeItemEvent.FOLDER_ROLL_OVER, event.currentItem));
				break;
				case(ListItemType.TYPE_ITEM) :
				dispatchEvent(new TreeItemEvent(TreeItemEvent.ITEM_ROLL_OVER, event.currentItem));
				break;
			}
		}
		private function markItem(listItem:ListItem):void 
		{
			_tempColor = listItem.backgroundColor;
			if (_marked != null) 
			{
				_marked.backgroundColor = _tempColor;
				_marked.active = false;
			}
			listItem.backgroundColor = listItem.alternateColor;
			_marked = listItem;
			_marked.active = true;
		}
		private function openLists(listItem:ListItem):void
		{
			if (listItem.parentList != null)
			{
				if (listItem.parentList.parentListItem != null)
				{
					if (listItem.parentList.parentListItem.state == ListItemState.CLOSED)
					{
						listItem.parentList.parentListItem.state = ListItemState.OPEN;
						listItem.parentList.parentListItem.addChild(listItem.parentList.parentListItem.containerList);
						if (listItem.parentList.parentListItem != null)
						{
							openLists(listItem.parentList.parentListItem);
						}
						listItem.parentList.parentListItem.parentList.refreshList();
					}
				}
			}
		}
		
		public function createPages():void	{
			pages = new Array();
			var bitData:BitmapData
			var printHeight:Number = 522;
			var scrollCount:Number = pane.content.height/printHeight;
			
			for(var i:Number = 0; i<scrollCount; i++)	{
				pane.verticalScrollPosition = printHeight*i;
				bitData = new BitmapData(850,552);
				bitData.draw(this);
				pages.push(bitData);
			}
			//pane.verticalScrollPosition = 0;
		}
		
		public function printTree():void	{
			var print:PrintJob = new PrintJob();
			var option:PrintJobOptions = new PrintJobOptions(true);
			try	{
				if(print.start() )	{
					for(var i:Number = 0; i<5; i++)	{
						print.addPage(getPages(pages[i],i),new Rectangle(0,0,850,pane.content.height),option);
					}
				}
			}
			catch(error:Error)	{
				trace ("Had problem adding the page to print job: " + error);
			}
			
			try {
				print.send();
			}
			catch (e:Error) {
				trace ("Had problem printing: " + e);    
			}
			
		}
		
		private function getPages(bit:BitmapData,ypos:Number):Sprite	{
			var sp:Sprite = new Sprite();
			sp.graphics.beginBitmapFill(bit,null,true,false);
			sp.graphics.drawRect(0,0,850,552);
			sp.graphics.endFill();
			sp.scaleX = sp.scaleY = .7
			trace(ypos*522)
			return sp;
		}
		public function scrollTree(pos:Number):void	{
			trace(pos)
			pane.verticalScrollPosition = 100;
			
		}
		/**
		 * DataProvider da Treeview
		 * Objeto XML com os dados para a TreeView
		 */
		public function get dataProvider():XML 
		{
			return _dataProvider;
		}
		
		public function set dataProvider(value:XML):void 
		{
			_dataProvider = value;
		}
		/**
		 * Margin de identação das Lists e ListItens
		 */
		public function get margin():int 
		{
			return _margin;
		}
		
		public function set margin(value:int):void 
		{
			_margin = value;
		}
		/**
		 * Lista genérica com todos os itens internos da TreeView (Exclui as pastas)
		 */
		public function get genericList():Dictionary 
		{
			return _genericList;
		}
		
		public function set genericList(value:Dictionary):void 
		{
			_genericList = value;
		}
		/**
		 * Estilo do Item (ListItemStyle);
		 */
		public function get listStyle():ListItemStyle 
		{
			return _listStyle;
		}
		
		public function set listStyle(value:ListItemStyle):void 
		{
			_listStyle = value;
		}
		/**
		 * Estilo do Folder (FolderItemStyle);
		 */
		public function get folderStyle():FolderItemStyle 
		{
			return _folderStyle;
		}
		
		public function set folderStyle(value:FolderItemStyle):void 
		{
			_folderStyle = value;
		}
		/**
		 * Largura da TreeView e dos Itens internos (folder e item)
		 */
		public function get itemWidth():Number { return _itemWidth; }
		
		public function set itemWidth(value:Number):void 
		{
			_itemWidth = value;
		}
		/**
		 * Altura da TreeView 
		 */
		public function get itemHeight():Number { return _itemHeight; }
		
		public function set itemHeight(value:Number):void 
		{
			_itemHeight = value;
		}
		/**
		 * ScrollPane da TreeView
		 */
		//public function get ScrollPane():ScrollPane { return pane; }
		
		/*public function set ScrollPane(value:ScrollPane):void 
		{
			pane = value;
		}*/
		
		
		

		
	}

}