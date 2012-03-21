package org.aerialframework.controller
{
	import com.codeazur.utils.StringUtils;
	import com.mysql.workbench.model.Schema;

	import flash.filesystem.File;
	import flash.system.ApplicationDomain;
	import flash.system.System;
	import flash.utils.getTimer;

	import mx.utils.ObjectUtil;

	import org.aerialframework.abstract.AbstractPlugin;
	import org.as3commons.lang.ClassUtils;

	import org.osflash.eval.ActionScriptEvaluator;
	import org.osflash.eval.getDefinition;

	public class PluginController
	{
		private static var _instance:PluginController;

		public var schema:Schema;
		public var relations:XML;

		private var domains:Object = {};
		private var plugins:Array = [];
		private var evalIndex:int = 0;
		private var currentClassName:String;
		private var currentPackage:String;
		private var startTime:int;

		{
			_instance = new PluginController();
		}

		public function PluginController()
		{
		}

		private function handleSuccess():void
		{
			var descriptor:Object = this.domains.hasOwnProperty(currentPackage)
											?	this.domains[currentPackage]
											:	null;

			var domain:ApplicationDomain = descriptor.domain;
			if(!domain)
				domain = new ApplicationDomain(ApplicationDomain.currentDomain);
			else
			{
				trace(">found domain for " + currentPackage);
			}
			
			const definition = getDefinition(currentClassName, domain);
			trace(">>> " + currentClassName + definition + "\nPackage: " + currentPackage);
			var model:AbstractPlugin = ClassUtils.newInstance(definition);
			trace(currentClassName + " > > " + model.fileType);
			
			nextEval();

			/*trace(ObjectUtil.toString(domains));

			 var model:AbstractPlugin = ClassUtils.newInstance(definition);
			 model.schema = schema;
			 model.relationships = relations;

			 model.initialize();

			 var models:Array = model.generate();
			 trace(models.length);*/
		}

		private function handleFailure(e:*):void
		{
			trace(ObjectUtil.toString(e));
		}

		public static function get instance():PluginController
		{
			return _instance;
		}

		public function registerPlugins():void
		{
			startTime = getTimer();
			
			var pluginDir:File = File.applicationDirectory.resolvePath("plugins/src");
			if(!pluginDir.exists)
				throw new Error("No plugins present");

			var list:Array = scanDirectory(pluginDir);

			for each(var file:File in list)
			{
				if(!file)
					continue;

				var relativePath:String = pluginDir.getRelativePath(file, true).substr(0, -file.name.length - 1);
				var packageStr:String = relativePath.replace(/[\/\\]/g, ".");
				if(!domains)
					domains = {};

				if(!domains.hasOwnProperty(packageStr))
				{
					var domain:ApplicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
					var evaluator:ActionScriptEvaluator = new ActionScriptEvaluator(domain);

					domains[packageStr] = {domain:domain, classes:[], eval:evaluator};
					evaluator.onSuccess.add(handleSuccess);
					evaluator.onFailure.add(handleFailure);
				}

				domains[packageStr].classes.push(file.name.substr(0, -3));

				var contents:String = FileIOController.read(file);
				if(contents.indexOf("extends AbstractPlugin") < 0)
					continue;

				contents = convertImportsToNamespaces(contents);
				trace(contents);

				this.plugins.push({file:file, data:contents, "package":packageStr});
			}

			evalIndex = 0;
			nextEval();
		}

		private function nextEval():void
		{
			var plugin:Object = this.plugins[evalIndex];
			evalIndex++;

			if(!plugin)
			{
				trace(">>> complete in " + (getTimer() - startTime));
				return;
			}

			currentClassName = plugin.file.name.substr(0, -3);
			currentPackage = plugin["package"];

			register(plugin.file, plugin.data);
		}

		// use `domains` fqdn and application domain to get definition

		private function getFQDN(filename:String, contents:String):String
		{
			var matchPackage:RegExp = /[^"']\bpackage\s?(.+)?(\s+)?\{/g;

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
			var descriptor:Object = this.domains.hasOwnProperty(currentPackage)
														?	this.domains[currentPackage]
														:	null;

			trace(">>> loading: " + file.nativePath);
			descriptor.eval.load(contents);
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
			classFile = classFile.replace(/[^"']\bsuper\(/g, "super$init(");

			// remove package definition
			classFile = classFile.replace(/[^"']\bpackage\s?(.+)?(\s+)?\{/g, "");
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