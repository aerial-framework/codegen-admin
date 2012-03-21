package org.aerialframework.controller
{
	import com.codeazur.utils.StringUtils;
	import com.mysql.workbench.model.Document;
	import com.mysql.workbench.model.Schema;

	import flash.filesystem.File;
	import flash.utils.ByteArray;

	import org.aerialframework.error.ConfigError;

	public class ConfigController
	{
		private static var _instance:ConfigController;

		/**
		 * /
		 */
		public static const CONFIG_PATH:String = "config";
		public static const OUTPUT_BASE_PATH:String = "output-base";

		/**
		 * /types
		 */
		public static const PHP_OUTPUT_PATH:String = "php";
		public static const FLEX_OUTPUT_PATH:String = "flex";
		public static const FLASH_OUTPUT_PATH:String = "flash";

		private var _configXML:XML;
		private var _basePath:File;

		{
			_instance = new ConfigController();
		}

		public function ConfigController()
		{
			if(_instance)
				throw new Error("Cannot re-initialize a Singleton class");
		}

		public static function get instance():ConfigController
		{
			return _instance;
		}

		public function get configXML():XML
		{
			return _configXML;
		}
		
		public function parseConfigFile(xml:XML):void
		{
			_configXML = xml;
			
			validate();
		}

		private function validate():void
		{
			if(!_configXML)
				throw new Error(ConfigError.BLANK_CONFIG);
		}

		public function getConfig(element:String, isPath:Boolean=true):Object
		{
			validate();

			var data:String;
			switch(element)
			{
				case CONFIG_PATH:
				case OUTPUT_BASE_PATH:
					data = _configXML[element].toString();
					break;
				case PHP_OUTPUT_PATH:
				case FLEX_OUTPUT_PATH:
				case FLASH_OUTPUT_PATH:
					data = _configXML.types[element].toString();
					break;
			}

			if(isPath)
			{
				// validate that the requested path exists, if not - create it
				data = validatePath(data);

				try
				{
					var path:File = new File(data);
					trace(path.url);

					if(path && !path.exists)
						path.createDirectory();
				}
				catch(e:Error)
				{
					throw new Error(ConfigError.UNWRITABLE_PATH);
				}
			}
			
			return data;
		}

		private function validatePath(data:String):String
		{
			if(!basePath)
				throw new Error(ConfigError.INVALID_BASE);
			
			if(!data)
				data = File.separator;

			var relative:Boolean = (data.charAt(0) != "/" && data.charAt(0) != "\\");
			
//			if(data.indexOf(basePath.nativePath) >= 0)
//				data = data.substring(basePath.nativePath.length) + File.separator;
			
			if(StringUtils.trim(data) == "")
				data = File.separator;

			var relPath:String = basePath.getRelativePath(new File(basePath.url + File.separator + data));
			try
			{
				var f:File = new File(File.separator + relPath);
//				trace(f.nativePath, relative);
				if(!relative)
					return f.url;

				return new File(basePath.url + File.separator + data).url;
			}
			catch(e:Error)
			{
				return new File(basePath.url + File.separator + data).url;
			}
			
			return "";
		}

		public function processMWB(mwbFile:File):Schema
		{
			if(!mwbFile.exists)
				throw new Error("MWB file does not exist");
			
			var doc:Document = new Document();
			doc.loadByteArray(FileIOController.read(mwbFile, false, ByteArray));
			
			if(doc.schemas && doc.schemas.length > 0)
				return doc.schemas[0];

			return null;
		}

		public function get basePath():File
		{
			return _basePath;
		}

		public function set basePath(value:File):void
		{
			_basePath = value;
			
			try
			{
				if(!value.exists)
					value.createDirectory();
			}
			catch(e:Error)
			{
				throw new Error(ConfigError.UNWRITABLE_PATH);
			}
		}
	}
}