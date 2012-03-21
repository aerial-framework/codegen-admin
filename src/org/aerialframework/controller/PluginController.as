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
	import org.osflash.signals.Signal;

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

		private var _loadedPlugins:Array = [];
		public var pluginsLoaded:Signal;

		{
			_instance = new PluginController();
		}

		public function PluginController()
		{
			pluginsLoaded = new Signal(Array);
		}

		private function handleSuccess():void
		{
			try
			{
				var descriptor:Object = this.domains.hasOwnProperty(currentPackage)
												?	this.domains[currentPackage]
												:	null;
	
				var domain:ApplicationDomain = descriptor.domain;
				if(!domain)
					domain = new ApplicationDomain(ApplicationDomain.currentDomain);
				
				const definition = getDefinition(currentClassName, domain);
				if(!definition)
					return;
				
				var model:AbstractPlugin = ClassUtils.newInstance(definition);
				model.schema = this.schema;
				model.relationships = this.relations;
				
				_loadedPlugins.push({instance:model, "package":currentPackage, domain:domain});
			}
			catch(e:Error)
			{
				trace(ObjectUtil.toString(e));
			}
			
			nextEval();
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
			_loadedPlugins = [];
			evalIndex = 0;

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

				this.plugins.push({file:file, data:contents, "package":packageStr});
			}

			nextEval();
		}

		private function nextEval():void
		{
			var plugin:Object = this.plugins[evalIndex];
			evalIndex++;

			if(!plugin)
			{
				completeEval();
				return;
			}

			currentClassName = plugin.file.name.substr(0, -3);
			currentPackage = plugin["package"];

			register(plugin.file, plugin.data);
		}

		private function completeEval():void
		{
			this.pluginsLoaded.dispatch(this._loadedPlugins);
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

		public function get loadedPlugins():Array
		{
			return _loadedPlugins;
		}
	}
}