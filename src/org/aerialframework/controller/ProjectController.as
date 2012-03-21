package org.aerialframework.controller
{
	import com.mysql.workbench.model.Schema;

	import flash.filesystem.File;

	public class ProjectController
	{
		private static var _instance:ProjectController;
		
		private var _schema:Schema;
		private var _tables:Array;

		{
			_instance = new ProjectController();
		}

		public function ProjectController()
		{
			if(_instance) throw new Error("Cannot reinitialize Singleton");
		}

		public static function get instance():ProjectController
		{
			return _instance;
		}

		public function open(file:File):void
		{

		}

		/*public function generate(type:String, schema:Schema, tables:Array):void
		{
			_schema = schema;
			_tables = tables;
			
			var evaluator = new ActionScriptEvaluator();
			evaluator.onSuccess.addOnce(handleSuccess);
			evaluator.onFailure.addOnce(handleFailure);
			evaluator.load(loadContents());
		}

		private function loadContents():String
		{
			var contents:String;

			const fileStream:FileStream = new FileStream();
			try
			{
				const file:File = File.applicationDirectory.resolvePath('CodeGen.tmpl.as');
				fileStream.open(file, FileMode.READ);
				contents = fileStream.readMultiByte(file.size, File.systemCharset);
			}
			catch (error:Error)
			{
				contents = null;
			}
			finally
			{
				fileStream.close();
			}

			return contents;
		}

		private function handleSuccess():void
		{
			codeGen(_schema, _tables);
		}

		private function codeGen(schema:Schema, tables:Array):void
		{
			const definition:Class = getDefinition("CodeGen");

			var doctrine:* = new definition(schema);
			doctrine.modelPackage = "com.test.vo";
			doctrine.servicePackage = "com.test.services";
			doctrine.generateModels(tables);
		}

		private function handleFailure(e:*):void
		{
			trace(e);
		}*/
	}
}