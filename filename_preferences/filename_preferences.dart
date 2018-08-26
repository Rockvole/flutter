import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart' as xml;
import 'package:xml/xml/nodes/node.dart' show XmlNode;

class FileNamePreferences {
  static final String C_DEFAULT_FILENAME = "SharedPreferences.xml";

  Map<String, Map> _preferenceCache;

  bool getBool(String key, [bool defaultReturn]) {
    if (_preferenceCache != null && _preferenceCache.containsKey(key)) {
      if (_preferenceCache[key]['value'] == 'true') {
        return true;
      } else
        return false;
    }
    return defaultReturn;
  }

  int getInt(String key, [int defaultReturn]) {
    if (_preferenceCache != null && _preferenceCache.containsKey(key)) {
      return int.parse(_preferenceCache[key]['value']);
    }
    return defaultReturn;
  }

  double getDouble(String key, [double defaultReturn]) {
    if (_preferenceCache != null && _preferenceCache.containsKey(key)) {
      return double.parse(_preferenceCache[key]['value']);
    }
    return defaultReturn;
  }

  String getString(String key, [String defaultReturn]) {
    if (_preferenceCache != null && _preferenceCache.containsKey(key)) {
      return _preferenceCache[key]['value'];
    }
    return defaultReturn;
  }

  List<String> getKeys() {
    return _preferenceCache.keys.toList();
  }

  void setBool(String key, bool value) => _setValue('boolean', key, value);
  void setInt(String key, int value) => _setValue('integer', key, value);
  void setDouble(String key, double value) => _setValue('double', key, value);
  void setString(String key, String value) => _setValue('string', key, value);

  void _setValue(String valueType, String key, Object value) {
    if (value == null) {
      remove(key);
      return;
    }
    if (!_preferenceCache.containsKey(key)) {
      _preferenceCache[key] = new Map<String, String>();
    }
    _preferenceCache[key]["type"] = valueType;
    _preferenceCache[key]["value"] = value.toString();
  }

  void remove(String key) {
    if(_preferenceCache.containsKey(key)) _preferenceCache.remove(key);
  }

  void clear() {
    if (_preferenceCache != null) _preferenceCache.clear();
  }

  Future<String> readPreferencesFile(String fileName) async {
    if (fileName == null) fileName = C_DEFAULT_FILENAME;
    _preferenceCache = new Map<String, Map>();
    try {
      File file = await _getLocalFile(fileName);
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

  Future<File> _getLocalFile(String fileName) async {
    // get the path to the document directory.
    String dir = (await getApplicationDocumentsDirectory()).path;
    File f = new File('$dir/$fileName');
    return f;
  }

  Future<Null> _writeFile(Future<File> file, String contents) async {
    await (await file).writeAsString(contents);
  }

  apply(String fileName) {
    _writeFile(_getLocalFile(fileName),
        prefsMapToXmlDocument().toXmlString(pretty: true, indent: '\t'));
  }

  static Map<String, Map> _xmlToPrefsMap(String xmlString) {
    Map<String, Map> prefsMap = new Map<String, Map>();
    var document = xml.parse(xmlString);
    //print("rtt="+document.runtimeType.toString());
    var prefsXml = document.findElements("map").elementAt(0);
    //print("px="+prefsXml.toString());
    Iterable<XmlNode> tst = prefsXml.descendants;
    Iterator iter = tst.iterator;
    while (iter.moveNext()) {
      //print("iter="+iter.current.toString()+" ("+iter.current.runtimeType.toString()+")");
      if (iter.current is xml.XmlElement) {
        xml.XmlElement element = iter.current;
        //print("--------- XmlElement=="+element.name.toString());
        String value = element.getAttribute("value");
        String name = element.getAttribute("name");
        if (!prefsMap.containsKey(name)) {
          prefsMap[name] = new Map<String, String>();
        }
        prefsMap[name]["type"] = element.name.toString();
        prefsMap[name]["value"] = value.toString();
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
