package org.aerialframework.controller
{
	import com.codeazur.utils.StringUtils;
	import com.mysql.workbench.model.Schema;

	import flash.filesystem.File;
	import flash.system.ApplicationDomain;
	import flash.utils.getDefinitionByName;

	import mx.utils.ObjectUtil;

	import org.aerialframework.abstract.AbstractPlugin;

	import org.as3commons.lang.ClassUtils;

	import org.osflash.eval.ActionScriptEvaluator;
	import org.osflash.eval.getDefinition;

	import org.aerialframework.abstract.AbstractPlugin; AbstractPlugin;
	import com.betabong.xml.e4x.E4X;					E4X;

	public class PluginController
	{
		private static var _instance:PluginController;
		
		private var evaluator:ActionScriptEvaluator;
		
		public var schema:Schema;
		public var relations:XML;

		{
			_instance = new PluginController();
		}

		public function PluginController()
		{
			evaluator = new ActionScriptEvaluator();
			evaluator.onSuccess.add(handleSuccess);
			evaluator.onFailure.add(handleFailure);
		}

		private function handleSuccess():void
		{
			const definition = getDefinition("Bob");
			
//			new definition(schema, null, relations).generate();
			
			var bob:AbstractPlugin = ClassUtils.newInstance(definition);
			bob.schema = schema;
			bob.relationships = relations;
			
			bob.initialize();
			
			bob.generate();
		}

		private function handleFailure(e:*):void
		{
			trace(ObjectUtil.toString(e));
		}

		public static function get instance():PluginController
		{
			return _instance;
		}

		public function registerPlugins():Array
		{
			var pluginDir:File = File.applicationDirectory.resolvePath("plugins/src");
			if(!pluginDir.exists)
				throw new Error("No plugins present");

			var list:Array = scanDirectory(pluginDir);
			var plugins:Array = [];

			for each(var file:File in list)
			{
				if(!file)
					continue;

				var contents:String = FileIOController.read(file);
				if(contents.indexOf("extends AbstractPlugin") < 0)
					continue;

				contents = convertImportsToNamespaces(contents);
				
				
//				contents = FileIOController.read(File.desktopDirectory.resolvePath("test.as"));
				
				trace(contents + "\n" + StringUtils.repeat(50, "-"));
				
				plugins.push({file:file, data:contents});
				register(file, contents);
				break;
			}

			return plugins;
		}

		private function getFQDN(filename:String, contents:String):String
		{
			var matchPackage:RegExp = /\bpackage\s?(.+)?(\s+)?\{/g;

			var matches:Array = contents.match(matchPackage);
			if(!matches || matches.length < 1)
				return null;

			var packageStr:String = StringUtils.trim(matches[0]);
			if(!packageStr || packageStr.length < "package".length)
				return null;

			packageStr = StringUtils.trim(packageStr.replace("package", ""));
			packageStr = StringUtils.trim(packageStr.replace("{", ""));
			return packageStr + "::" + filename.substring(0, filename.indexOf("."));
		}

		private function register(file:File, contents:String):void
		{
			trace(">>> loading: " + file.nativePath);
			evaluator.load(contents);
		}

		private function convertImportsToNamespaces(classFile:String):String
		{
			if(!classFile)
				return null;

			var matchImportsRegex:RegExp = /\s+?import\s([a-zA-Z0-9.*]+);/g;
			var imports:Array = classFile.match(matchImportsRegex);

			var namespaces:Array = [];
			for each(var importStatement:String in imports)
			{
				importStatement = StringUtils.trim(importStatement);

				if(!importStatement)
					continue;

				importStatement = importStatement.replace("import ", "");

				var pieces:Array = importStatement.split(".");
				if(!pieces || pieces.length <= 0)
					continue;

				var lastPiece:String = pieces[pieces.length - 1];

				var namespaceFake:String;

				if(lastPiece != "*")
					namespaceFake = "use namespace \"" + pieces.slice(0, pieces.length - 1).join(".") + "\";";
				else
					namespaceFake = "use namespace \"" + pieces.slice(0, pieces.length - 2).join(".") + "\";";

				if(namespaces.indexOf(namespaceFake) < 0)
					namespaces.push(namespaceFake);
			}

			classFile = namespaces.join("\n") + "\n\n" + classFile;
			classFile = classFile.replace(matchImportsRegex, "");

			// replace super() with super$init() in accordance with Tamarin constraint
			classFile = classFile.replace(/[^"]\bsuper\(/g, "super$init(");

			// remove package definition
			classFile = classFile.replace(/[^"]\bpackage\s?(.+)?(\s+)?\{/g, "");
			classFile = classFile.substring(0, classFile.lastIndexOf("}"));

			return classFile;
		}

		private function scanDirectory(directory:File):Array
		{
			if(!directory || !directory.isDirectory)
				return null;

			var files:Array = [];

			var list:Array = directory.getDirectoryListing();
			for each(var item:File in list)
			{
				if(item.isDirectory)
				{
					files = files.concat(scanDirectory(item));
					continue;
				}

				files.push(item);
			}

			return files;
		}
	}
}