import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart' as xml;
import 'package:xml/xml/nodes/node.dart' show XmlNode;

class FileNamePreferences {
  static FileNamePreferences _instance;
  static final String C_DEFAULT_FILENAME = "SharedPreferences.xml";

  FileNamePreferences() {
    readPreferencesFile(C_DEFAULT_FILENAME);
  }

  static FileNamePreferences getInstance() {
    if(_instance==null) {
      _instance = new FileNamePreferences();
    }
    return _instance;
  }

  Map<String, Map> _preferenceCache;
  String _filename;

  bool getBool(String key) {
    if(_preferenceCache!=null && _preferenceCache.containsKey(key)) {
      if(_preferenceCache[key]['value']=='true') {
        return true;
      } else return false;
    }
    return null;
  }

  int getInt(String key) {
    if(_preferenceCache!=null && _preferenceCache.containsKey(key)) {
      return int.parse(_preferenceCache[key]['value']);
    }
    return null;
  }

  double getDouble(String key) {
    if(_preferenceCache!=null && _preferenceCache.containsKey(key)) {
      return double.parse(_preferenceCache[key]['value']);
    }
    return null;
  }

  String getString(String key) {
    if(_preferenceCache!=null && _preferenceCache.containsKey(key)) {
      return _preferenceCache[key]['value'];
    }
    return null;
  }

  void setBool(String key, bool value) => _setValue('boolean', key, value);
  void setInt(String key, int value) => _setValue('integer', key, value);
  void setDouble(String key, double value) => _setValue('double', key, value);
  void setString(String key, String value) => _setValue('string', key, value);

  void _setValue(String valueType, String key, Object value) {
    if(!_preferenceCache.containsKey(key)) {
      _preferenceCache[key]=new Map<String, String>();
    }
    _preferenceCache[key]["type"]=valueType;
    _preferenceCache[key]["value"]=value.toString();
  }

  void clear() {
    _filename=C_DEFAULT_FILENAME;
    if(_preferenceCache!=null) _preferenceCache.clear();
  }

  Future<String> readPreferencesFile(String filename) async {
    _filename = filename;
    _preferenceCache = new Map<String, Map>();
    try {
      File file = await _getLocalFile(_filename);
      // read the variable as a string from the file.
      String xmlString = await file.readAsString();
      _preferenceCache = _xmlToPrefsMap(xmlString);
      //print("map="+_preferenceCache.toString());
      return xmlString;
    } on FileSystemException {
      return null;
    }
  }

  // --------------------------------------------------------------------------- PRIVATE FUNCTIONS

  Future<File> _getLocalFile(String filename) async {
    // get the path to the document directory.
    String dir = (await getApplicationDocumentsDirectory()).path;
    File f = new File('$dir/$filename');
    return f;
  }

  Future<Null> _writeFile(Future<File> file, String contents) async {
    await (await file).writeAsString(contents);
  }

  commit() {
    _writeFile(_getLocalFile(_filename), prefsMapToXmlDocument().toXmlString(pretty: true, indent: '\t'));
  }

  static Map<String, Map> _xmlToPrefsMap(String xmlString) {
    Map<String, Map> prefsMap = new Map<String, Map>();
    xml.XmlDocument document = xml.parse(xmlString);
    var prefsXml = document.findElements("map").elementAt(0);
    //print("px="+prefsXml.toString());
    Iterable<XmlNode> tst = prefsXml.descendants;
    Iterator iter = tst.iterator;
    while(iter.moveNext()) {
      //print("iter="+iter.current.toString()+" ("+iter.current.runtimeType.toString()+")");
      if(iter.current is xml.XmlElement) {
        xml.XmlElement element = iter.current;
        //print("--------- XmlElement=="+element.name.toString());
        String value=element.getAttribute("value");
        String name=element.getAttribute("name");
        if(!prefsMap.containsKey(name)) {
          prefsMap[name]=new Map<String, String>();
        }
        prefsMap[name]["type"]=element.name.toString();
        prefsMap[name]["value"]=value.toString();
      }
    }
    return prefsMap;
  }

  xml.XmlDocument prefsMapToXmlDocument() {
    var sortedKeys = _preferenceCache.keys.toList()..sort();
    var builder = new xml.XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('map', nest: () {
      sortedKeys.forEach((key) {
        builder.element(_preferenceCache[key]["type"], nest: () {
          builder.attribute("name", key);
          builder.attribute("value", _preferenceCache[key]["value"]);
        });
      });

    });
    var xmlDoc = builder.build();
    //print(xmlDoc.toXmlString(pretty: true, indent: '\t'));
    return xmlDoc;
  }
}

