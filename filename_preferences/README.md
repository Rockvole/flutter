### filename_preferences
Flutter class to store and retrieve preference files by name

    FileNamePreferences fileNamePreferences=new FileNamePreferences();
    await fileNamePreferences.readPreferencesFile('scores.xml');
    int topScore = globals.fileNamePreferences.getInt("topscore");
    String name  = globals.fileNamePreferences.getString("name");
    
    fileNamePreferences.setBool("success", true);
    # File is not written until commit
    fileNamePreferences.apply("scores.xml");
    
Files are stored in android preferences format to the default flutter documents directory

### Comparison of flutter preference libraries

Comparison | filename_preferences | shared_preferences
------------ | ------------- | --------------------
Can store multiple prefs by filename | Yes * | No
Requires plugin for native bridge | No | Yes
Stores prefs in native prefs format | Android format used for all platforms | Yes

<nowiki>*</nowiki> Ios does not have the facility to store preferences by filename built-in, so this is an improvement even over native
