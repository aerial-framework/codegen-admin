package org.aerialframework.controller
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;

	public class MenuController
	{
		private static var _instance:MenuController;
		
		{
			_instance = new MenuController();
		}
		
		public function MenuController()
		{
			if(_instance) throw new Error("Cannot reinitialize Singleton");
		}
		
		public static function get instance():MenuController
		{
			return _instance;
		}
		
		public function createNewProject():void
		{
			
		}
		
		/**
		 * Browse to an existing .aerial file
		 */
		public function openExistingProject():void
		{
			var existingProject:File = new File();
			existingProject.addEventListener(Event.SELECT, existingProjectSelectionHandler);
			
			existingProject.browseForOpen("Open a .aerial project file",
				[new FileFilter("Aerial Project file", "*.aerial")]);
		}
		
		public function existingProjectSelectionHandler(event:Event):void
		{
			var existingProject:File = event.currentTarget as File;
			
			ProjectController.instance.open(existingProject);
		}
		
		/**
		 * Closes the project
		 */
		public function closeProject():void
		{
		}
		
		public function closeApplication(event:Event = null):void
		{
			if(event)
				event.preventDefault();
			
			Alert.show("Are you sure you want to close the application?", "Close Application",
				Alert.YES | Alert.NO | Alert.CANCEL, null, function(event:CloseEvent):void
				{
					if(event.detail == Alert.YES)
						NativeApplication.nativeApplication.exit();
				});
		}
	}
}