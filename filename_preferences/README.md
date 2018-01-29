### filename_preferences
Flutter class to store and retrieve preference files by name

    FileNamePreferences fileNamePreferences = FileNamePreferences.getInstance();
    await fileNamePreferences.readPreferencesFile('scores.xml');
    int topScore = globals.fileNamePreferences.getInt("topscore");
    String name  = globals.fileNamePreferences.getString("name");
    
    fileNamePreferences.setBool("success", true);
    # File is not written until commit
    fileNamePreferences.commit();
    
Files are stored in android preferences format to the default flutter documents directory.

Note: Has not been tried in ios.

    
