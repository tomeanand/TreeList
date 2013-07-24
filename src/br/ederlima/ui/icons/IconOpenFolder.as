package br.ederlima.ui.icons 
{
	import flash.display.MovieClip;
	/**
	 * IconOpenFolder
	 * <br>Ícone padrão para Folders abertos
	 * @author Eder Lima
	 */
	public class IconOpenFolder extends MovieClip
	{
		/**
		 * Construtor da Classe
		 */
		public function IconOpenFolder() 
		{
			this.graphics.lineStyle(1, 0x7A7A7A, 1);
			this.graphics.beginFill(0x7A7A7A, 1);
			//this.graphics.drawRect(3, 3, 8, 8);
			this.graphics.drawCircle(46,5.5,5);
			this.graphics.endFill();
			
			this.graphics.lineStyle(0, 0, 0);
			this.graphics.beginFill(0xFFFFFF, 1);
			this.graphics.drawRect(44, 5, 4.8, 1);
		}
		
	}

}